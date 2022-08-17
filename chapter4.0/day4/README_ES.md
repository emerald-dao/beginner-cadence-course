# Capítulo 4 Día 4 - Creando un Contrato de NFT: Transfiriendo, Minting, y Los Préstamos

¡Sigamos construyendo nuestro contrato de NFT! :D

## Video

Hoy, vamos a cubrir 20:35 - 31:20: https://www.youtube.com/watch?v=bQVXSpg6GE8

## Resumen Hasta Ahora

En el último día, cubrimos cómo crear los NFTs y guardarlos dentro un Colección. La razón porque creamos una Colección era que podíamos tener todo nuestra NFTs solo en un lugar en el almacenamiento de nuestra cuenta. 

Pero teníamos una problema: ¿debemos permitir a cualquier persona crear un NFT? Parece un poco raro. ¿Qué pasa si queremos controlar quién puede crear un NFT? Eso es lo que vamos a hablar hoy. 

## Transfiriendo

Antes de hablar sobre quién puede “mint” (o crear) un NFT, hablemos sobre transfiriendo. ¿Cómo podemos transferir un NFT de una cuenta a otra?

Pues, si recuerdas, solo el propietario de una Colección puede `withdraw` de su Colección. Sin embargo, cualquier persona puede `deposit` en la Colección de otra persona. Esto es perfecto para nosotros, porque significa que solo necesitamos acceso a 1 AuthAccount: la persona quien van a transferir (o técnicamente retirando) el NFT! Hacemos una transacción para transferir un NFT: 

*Nota: Esto es asumiendo que ya ha configurado ambas cuentas con una Colección.*

```cadence
import CryptoPoops from 0x01

// `id` es el `id` del NFT
// `recipient` es la persona recibiendo el NFT
transaction(id: UInt64, recipient: Address) {

  prepare(signer: AuthAccount) {
    // Consigue una referencia a la Colección del firmante 
    let signersCollection = signer.borrow<&CryptoPoops.Collection>(from: /storage/MyCollection)
                            ?? panic("Firmante no tienes un Colección de CryptoPoops.")

    // Consigue una referencia a la Colección publico del recipiente 
    let recipientsCollection = getAccount(recipient).getCapability(/public/MyCollection)
                                  .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>
                                  ?? panic("El recipiente no tienes un Colección de CryptoPoops.")
    
    // Retira el NFT con id == `id` y lo mueve dentro el variable de `nft`
    let nft <- signersCollection.withdraw(withdrawID: id)

    // Deposita el NFT dentro la Colección del recipiente 
    recipientsCollection.deposit(token: <- nft)
  }

}
```

No está mal ¿verdad? Debemos entender todo esto después de aprender el contenido de ayer. Aquí son los pasos:
1. Primero, conseguimos una referencia a la Colección del firmante. No usamos una capacidad porque necesitamos pedir prestado directamente del almacenamiento ya que necesitamos ser capaces de llamar `withdraw`. 
2. Entonces, conseguimos una referencia *pública* a la Colección del firmante. Conseguimos esto a través de una capacidad pública porque no tenemos acceso a su AuthAccount, pero esto está bien porque solo necesitamos depositar (`deposit`). 
3. Retiramos (`withdraw`) el NFT con `id` fuera de la Colección del firmante. 
4. Depositamos (`deposit`) el NFT dentro la Colección del recipiente. 

## Minting

Bueno, averigüemos cómo prevenir a todas las personas de minting sus propios NFTs. La pregunta ahora es, pues, entonces ¿QUIÉN debes tener la habilidad de mint? 

La belleza de Cadence es que podemos decidir por nosotros mismos. Por qué no empezamos haciendo un Recurso que mints (crear) NFTs? Entonces, quién es el propietario del recurso puede tener la habilidad de mint un NFT. Construyamos sobre el contrato que teníamos anteriormente:

```cadence
pub contract CryptoPoops {
  
  //  ... otras cosas aquí ...

  pub fun createEmptyCollection(): @Collection {
    return <- create Collection()
  }

  // Nuevo Recurso: Minter
  // Permite cualquier persona que lo tiene
  // Mint(crear) NFTs
  pub resource Minter {

    // Crear un nuevo recurso de NFT
    pub fun createNFT(): @NFT {
      return <- create NFT()
    }
  }

  init() {
    self.totalSupply = 0
  }
}
```

Aquí son las cosas que se han añadido: 
1. Creamos un nuevo recurso llamado `Minter`
2. Mudamos la función de `createNFT` dentro el recurso de `Minter`

Ahora, cualquier persona que tiene el recurso de `Minter` tiene la habilidad de mint (crear) NFTs. Bueno, eso es genial y todo eso, pero ¿quién puede tener minter ahora?

La solucion mas facil es para dar el `Minter` automáticamente a la cuenta que es desplegando el contrato. Podemos hacerlo guardando el recurso de `Minter` a el almacenamiento de cuentas de la cuenta del implementador de contratos dentro la función de `init`:

```cadence
pub contract CryptoPoops {
  
  // ... otras cosas aquí ...

  pub fun createEmptyCollection(): @Collection {
    return <- create Collection()
  }

  pub resource Minter {

    pub fun createNFT(): @NFT {
      return <- create NFT()
    }

  }

  init() {
    self.totalSupply = 0

    // Guarda el recurso de `Minter` a el almacenamiento de la cuenta aquí
    self.account.save(<- create Minter(), to: /storage/Minter)
  }
}
```

Cuando estás desplegando el contrato, dentro la función de `init`, tienes que realmente acceder el `AuthAccount` de la cuenta de implementación! Así que podemos guardar cosas en el almacenamiento de la cuenta allí. 

¿Ves lo que hicimos al final? Salvamos el `Minter` en el almacenamiento de la cuenta. ¡Perfecto! Ahora, solo la cuenta que desplegó el contrato tiene la habilidad de mint (crear) NFTs, y ya que ninguna función permite a otros usuarios conseguir un `Minter`, ¡es completamente seguro! 

Miremos a un transacción de ejemplo de un `Minter` creyendo un NFT para alguien. 

*Nota: Supongamos que el `signer` era la persona que desplegó el contrato, entonces solo ellos tienen el recurso de `Minter`*

```cadence
import CryptoPoops from 0x01

transaction(recipient: Address) {

  // Supongamos que el `signer` era la persona que desplegó el contrato, entonces solo ellos tienen el recurso de `Minter`
  prepare(signer: AuthAccount) {
    // Get a reference to the `Minter`
    let minter = signer.borrow<&CryptoPoops.Minter>(from: /storage/Minter)
                    ?? panic("Este firmante no es quien implementó el contrato.")

    // Consigue una referencia a la Colección pública de el `recipient`
    let recipientsCollection = getAccount(recipient).getCapability(/public/MyCollection)
                                  .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>
                                  ?? panic("El recipiente no tiene una Colección.")

    // Mint el NFT usando la referencia a `Minter`
    let nft <- minter.createNFT()

    // Deposita el NFT en la Colección del recipiente
    recipientsCollection.deposit(token: <- nft)
  }

}
```

¡Woooooooooooooooooooooooo! Hemos implementado con éxito el minting seguro. Este es un patrón muy importante a tener en cuenta de Cadence: la habilidad de delegar alguna funcionalidad de “Admin” a un recurso cierto, como en este caso el `Minter`. Eso “Admin” se administra con mayor frecuencia a el almacenamiento de cuenta de la cuenta que desplegó el contrato.

## Los Préstamos

Bueno, la última cosa. Recuerda que ayer dijimos que es raro que no podamos leer nuestro NFT sin retirarlo de la Colección? Pues, sumemos una función dentro el recurso de `Collection` que nos permite pedir prestado el NFT: 

```cadence
pub contract CryptoPoops {
  pub var totalSupply: UInt64

  pub resource NFT {
    pub let id: UInt64

    // Añadido alguna metadata aqui asi que podemos
    // leer de el
    pub let name: String
    pub let favouriteFood: String
    pub let luckyNumber: Int

    init(_name: String, _favouriteFood: String, _luckyNumber: Int) {
      self.id = self.uuid

      self.name = _name
      self.favouriteFood = _favouriteFood
      self.luckyNumber = _luckyNumber
    }
  }

  pub resource interface CollectionPublic {
    pub fun deposit(token: @NFT)
    pub fun getIDs(): [UInt64]
  }

  pub resource Collection: CollectionPublic {
    pub var ownedNFTs: @{UInt64: NFT}

    pub fun deposit(token: @NFT) {
      self.ownedNFTs[token.id] <-! token
    }

    pub fun withdraw(withdrawID: UInt64): @NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
              ?? panic("This NFT does not exist in this Collection.")
      return <- nft
    }

    pub fun getIDs(): [UInt64] {
      return self.ownedNFTs.keys
    }

    // Añadido este función así que ahora podemos
    // leer nuestro NFT
    pub fun borrowNFT(id: UInt64): &NFT {
      return (&self.ownedNFTs[id] as &NFT?)!
    }

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  // ... otras cosas aquí  ...

  init() {
    self.totalSupply = 0
    self.account.save(<- create Minter(), to: /storage/Minter)
  }
}
```

¡Super fácil, verdad! También sumamos algunos campos adicionales (o “metadata”) a nuestro NFT así que podemos leer información sobre él, cuando nos prestamos sus referencias de la Colección. En orden a conseguir la referencia, usamos un nuevo función de `borrowNFT` dentro nuestra `Collection` para devolver una referencia a uno de nuestro NFTs que se almacena dentro nuestro diccionario de `ownedNFTs`. Si intentamos a desplegar nuestro contrato de nuevo, configurar nuestras cuentas, y ejecutar una nueva transacción para mint un NFT: 

```cadence
import CryptoPoops from 0x01

// name: "Jacob"
// favouriteFood: "Pancakes con chispas de chocolate"
// luckyNumber: 13
transaction(recipient: Address, name: String, favouriteFood: String, luckyNumber: Int) {

  prepare(signer: AuthAccount) {
    // Consigue una referencia al `Minter`
    let minter = signer.borrow<&CryptoPoops.Minter>(from: /storage/Minter)
                    ?? panic("Este firmante no es quien implementó el contrato.")

    // Consigue una referencia a la Colección pública de el `recipient`
    let recipientsCollection = getAccount(recipient).getCapability(/public/MyCollection)
                                  .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>
                                  ?? panic("El recipiente no tiene una Colección.")

    // Mint el NFT usando la referencia al `Minter` y pasar en el metadata
    let nft <- minter.createNFT(name: name, favouriteFood: favouriteFood, luckyNumber: luckyNumber)

    // Deposita el NFT en la Colección del recipiente 
    recipientsCollection.deposit(token: <- nft)
  }

}
```

¡Genial! Creamos un NFT y lo ponemos en la cuenta del recipiente. Ahora, usamos nuestra función de `borrowNFT` en un guión para leer el metadata de el NFT que era depositado en nuestra cuenta: 

```cadence
import CryptoPoops from 0x01
pub fun main(address: Address, id: id) {
  let publicCollection = getAccount(address).getCapability(/public/MyCollection)
              .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>()
              ?? panic("La dirección no tiene una Colección.")
  
  let nftRef: &CryptoPoops.NFT = publicCollection.borrowNFT(id: id) // ERROR: "Member of restricted type is not accessible: borrowNFT"
  log(nftRef.name)
  log(nftRef.favouriteFood)
  log(nftRef.luckyNumber)
}
```

¡ESPERA! ¡Conseguimos un error! ¿Por qué pasa eso? Ahh, es porque olvidamos añadir `borrowNFT` a la interfaz de `CollectionPublic````cadence
pub contract CryptoPoops {
  
  // ... other stuff here ...

  pub resource interface CollectionPublic {
    pub fun deposit(token: @NFT)
    pub fun getIDs(): [UInt64]
    // We added the borrowNFT function here
    // so it's accessible to the public
    pub fun borrowNFT(id: UInt64): &NFT
  }

  // ... other stuff here ...
}
``` dentro nuestro contrato, así que no es accesible al público. Arreglemos eso:

```cadence
pub contract CryptoPoops {
  
  // ... otras cosas aquí  ...

  pub resource interface CollectionPublic {
    pub fun deposit(token: @NFT)
    pub fun getIDs(): [UInt64]
    // Sumemos el función de borrowNFT aquí
    // así que es accesible al público
    pub fun borrowNFT(id: UInt64): &NFT
  }

  // ... otras cosas aquí  ...
}
```

Ahora, podemos intentar nuestra guión de nuevo (asumiendo que acuñas el NFT de nuevo):

```cadence
import CryptoPoops from 0x01
pub fun main(address: Address, id: id) {
  let publicCollection = getAccount(address).getCapability(/public/MyCollection)
              .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>()
              ?? panic("La dirección no tiene una Colección.")
  
  let nftRef: &CryptoPoops.NFT = publicCollection.borrowNFT(id: id)
  log(nftRef.name) // "Jacob"
  log(nftRef.favouriteFood) // "Pancakes con chispas de chocolate"
  log(nftRef.luckyNumber) // 13
}
```

¡Woooooooooooooooooooooooooooooooooo!!! Leemos la metadata de nuestro NFT sin tener que retirarlo de la colección ;)

## En Conclusión

Ahora hemos escrito un smart contract de NFT completo! Eso es super genial. También hemos completado Capítulo 4. 

En el siguiente capítulo, terminaremos este contrato y vamos a empezar a aprender como hacer nuestro contrato más “oficial.” Eso es, como implementar algo llamado una interfaz de contrato así que otras aplicaciones saben que nuestro smart contract de NFT *es* en realidad un smart contract de NFT. 

## Búsquedas

Porque teníamos MUCHO a hablar sobre durante este Capítulo, quiero que hagas el siguiente: 

Toma nuestro contrato de NFT hasta ahora y añade comentarios a cada recurso o función explicando lo que está haciendo en tus propias palabras. Algo como así: 

```cadence
pub contract CryptoPoops {
  pub var totalSupply: UInt64

  // Este es un recurso de NFT que contiene un name,
  // favouriteFood, and luckyNumber
  pub resource NFT {
    pub let id: UInt64

    pub let name: String
    pub let favouriteFood: String
    pub let luckyNumber: Int

    init(_name: String, _favouriteFood: String, _luckyNumber: Int) {
      self.id = self.uuid

      self.name = _name
      self.favouriteFood = _favouriteFood
      self.luckyNumber = _luckyNumber
    }
  }

  // Este es una interfaz de recurso que nos permite a… entiendes
  pub resource interface CollectionPublic {
    pub fun deposit(token: @NFT)
    pub fun getIDs(): [UInt64]
    pub fun borrowNFT(id: UInt64): &NFT
  }

  pub resource Collection: CollectionPublic {
    pub var ownedNFTs: @{UInt64: NFT}

    pub fun deposit(token: @NFT) {
      self.ownedNFTs[token.id] <-! token
    }

    pub fun withdraw(withdrawID: UInt64): @NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
              ?? panic("This NFT does not exist in this Collection.")
      return <- nft
    }

    pub fun getIDs(): [UInt64] {
      return self.ownedNFTs.keys
    }

    pub fun borrowNFT(id: UInt64): &NFT {
      return (&self.ownedNFTs[id] as &NFT?)!
    }

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  pub fun createEmptyCollection(): @Collection {
    return <- create Collection()
  }

  pub resource Minter {

    pub fun createNFT(name: String, favouriteFood: String, luckyNumber: Int): @NFT {
      return <- create NFT(_name: name, _favouriteFood: favouriteFood, _luckyNumber: luckyNumber)
    }

    pub fun createMinter(): @Minter {
      return <- create Minter()
    }

  }

  init() {
    self.totalSupply = 0
    self.account.save(<- create Minter(), to: /storage/Minter)
  }
}
```
