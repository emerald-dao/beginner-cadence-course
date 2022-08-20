# Capítulo 4 Día 3 - Creando un Contrato de NFT: Colecciones (Parte 1/3)

Aprendiste mucho hasta ahora. Apliquemos todo lo que has aprendido para hacer tu propio contrato de NFT. 

## Video

En los próximos capítulos, vamos a hacer exactamente lo que hago en este video. Hoy, vamos solamente desde 00:00 - 20:35: https://www.youtube.com/watch?v=bQVXSpg6GE8 

## Reviso

<img src="../images/accountstorage1.PNG" />
<img src="../images/capabilities.PNG" />

## Ejemplo de NFT(NonFungibleToken)

Gastemos los siguientes días trabajando a través de un ejemplo de NonFungibleToken. Vamos a crear nuestro propio contrato de NFT llamado CryptoPoops. Así que vas a revisar todo los conceptos que has aprendido hasta ahora, e implementar tu propio NFT!

Empecemos haciendo un contrato: 

```cadence
pub contract CryptoPoops {
  pub var totalSupply: UInt64

  pub resource NFT {
    pub let id: UInt64

    init() {
      // NOTA: Cada recurso en Flow tiene su propio `uuid`. Nunca
      // habrá recursos con lo mismo `uuid`.
      self.id = self.uuid
    }
  }

  pub fun createNFT(): @NFT {
    return <- create NFT()
  }

  init() {
    self.totalSupply = 0
  }
}
```

Empezamos por:
1. Definido un `totalSupply` (poniendo igual a 0)
2. Creando un tipo de `NFT`. Damos el `NFT` 1 campo: `id`. El `id` es igual a `self.uuid`, cual es un identificador único que cada recurso en Flow tiene. Nunca habrá dos recursos con la misma `uuid`, así que funciona perfectamente como un id para un NFT, puesto que un NFT es un token que es único completamente de cada otra token. 
3. Creando un funcion de `createNFT` que devuelve un recurso de `NFT`, así que cualquier persona puede crear su propia NFT. 

Bueno, eso es fácil. Guardamos un NFT en el almacenamiento de nuestra cuenta, y lo ponemos a disposición al público. 

```cadence
import CryptoPoops from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // Guarda un NFT al camino de almacenamiento de `/storage/MyNFT`
    signer.save(<- CryptoPoops.createNFT(), to: /storage/MyNFT)
    
    // Conecta a publico asi que cualquier persona puede leer el campo de `id` de mi NFT
    signer.link<&CryptoPoops.NFT>(/public/MyNFT, target: /storage/MyNFT)
  }
}
```

¡Genial! Debes entender esto ahora porque de la último capítulo. Primero guardamos el NFT en el almacenamiento de la cuenta, y conecta una referencia al público así que podemos leer los campos de `id` con un guión. Bueno, hagamos eso!

```cadence
import CryptoPoops from 0x01
pub fun main(address: Address): UInt64 {
  let nft = getAccount(address).getCapability(/public/MyNFT)
              .borrow<&CryptoPoops.NFT>()
              ?? panic("An NFT does not exist here.")
  
  return nft.id // 3525 (algún número al azar, porque es el `uuid`
                // del recurso. Esto probablemente va a ser diferente para ti.)
}
```

¡Genial! Hicimos algunas cosas buenas. Pero pensemos sobre esto por un momento. ¿Qué pasa si queremos guardar *otra* NFT en nuestra cuenta?

```cadence
import CryptoPoops from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // ERROR: "failed to save object: path /storage/MyNFT 
    // in account 0x1 already stores an object"
    signer.save(<- CryptoPoops.createNFT(), to: /storage/MyNFT)
    
    signer.link<&CryptoPoops.NFT>(/public/MyNFT, target: /storage/MyNFT)
  }
}
``` 

Mira que pasa. ¡Conseguimos un error! ¿Por qué? Porque ya existe un NFT en ese camino de almacenamiento. ¿Cómo podemos resolver esto? Pues, podemos especificar un camino diferente de almacenamiento…

```cadence
import CryptoPoops from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // Nota que usamos `MyNFT02` como el camino
    signer.save(<- CryptoPoops.createNFT(), to: /storage/MyNFT02)
    
    signer.link<&CryptoPoops.NFT>(/public/MyNFT02, target: /storage/MyNFT02)
  }
}
```

Esta manera funciona, pero no es buena. Si queremos tener un montón de NFTs, tenemos que recordar todos los caminos de almacenamiento, y eso es super molestando e ineficiente.

El segundo problema es que nadie puede darnos NFTs. Ya que solo el propietario de la cuenta puede guardar un NFT en el almacenamiento de su cuenta directamente, nadie puede crear un NFT para nosotros. Eso tampoco es bueno. 

## Colecciones

La manera para resolver ambas de esos problemas es crear una “Colección” o un contenedor que envuelve todas nuestras NFTs en uno.  Entonces, podemos guardar la colección a 1 camino de almacenamiento, y también permite otras para “depositar” en esa colección. 

```cadence
pub contract CryptoPoops {
  pub var totalSupply: UInt64

  pub resource NFT {
    pub let id: UInt64

    init() {
      self.id = self.uuid
    }
  }

  pub fun createNFT(): @NFT {
    return <- create NFT()
  }

  pub resource Collection {
    // Mapas un `id` a el NFT con eso `id`
    //
    // Ejemplo: 2353 => NFT con id 2353
    pub var ownedNFTs: @{UInt64: NFT}

    // Nos permite a depositar un NFT
    // a nuestro Colección
    pub fun deposit(token: @NFT) {
      self.ownedNFTs[token.id] <-! token
    }

    // Nos permite a retirar un NFT
    // de nuestro Colección 
    //
    //  Si el NFT no existe, pánico
    pub fun withdraw(withdrawID: UInt64): @NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
              ?? panic("Este NFT no existen en este Colección.")
      return <- nft
    }

    // Devuelve un array de todo los ids de los NFTs en nuestra Colección.
    pub fun getIDs(): [UInt64] {
      return self.ownedNFTs.keys
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

  init() {
    self.totalSupply = 0
  }
}
```

Genial. Definimos un recurso de `Collection` que hace algunas cosas:
1. Guarda un diccionario llamado `ownedNFTs` que mapa un `id` a el `NFT` con eso `id`. 
2. Define una función de `deposit` para depositar `NFTs`.
3. Define una función de `withdraw` para retirar `NFTs`.
4. Define una función de `getIDs` así que podemos conseguir una lista de todo los `id` de los `NFT` en nuestra Colección. 
5. Define una función de `destroy`. En Cadence, **cuando tiene recursos dentro recursos, TIENES que declarar una función de `destroy` que destruye manualmente esos recursos con la palabra clave `destroy`.**

También hemos definido una función de `createEmptyCollection` así que podemos guardar una `Collection` a el almacenamiento de nuestra cuenta así que podemos manejar nuestros NFTs mejor. Hagamos esto ahora: 

```cadence
import CryptoPoops from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // Guarda un `CryptoPoops.Collection` en el almacenamiento de nuestra cuenta
    signer.save(<- CryptoPoops.createEmptyCollection(), to: /storage/MyCollection)
    
    // Conecta al público 
    signer.link<&CryptoPoops.Collection>(/public/MyCollection, target: /storage/MyCollection)
  }
}
```

Toma unos momentos para leer este código. ¿Qué hay de malo en esto? Pensar sobre algunos de los problemas de seguridad que tiene. ¿Por qué es malo que expongamos `&CryptoPoops.Collection` al público?

....

....

¿Has pensado en ello todavía? La razón es porque ahora, **¡cualquier persona puede retirar de nuestra Colección!** Eso es muy malo. 

El problema, aunque, es qué queremos el público poder `deposit` NFTs en nuestra Colección, y queramos a también poder leer los ids de los NFTs que poseemos. 

Las interfaces de recursos, ¡woo! Definamos una interfaz de recurso para restring que exponemos al público: 

```cadence
pub contract CryptoPoops {
  pub var totalSupply: UInt64

  pub resource NFT {
    pub let id: UInt64

    init() {
      self.id = self.uuid
    }
  }

  pub fun createNFT(): @NFT {
    return <- create NFT()
  }

  // Solo expone `deposit` y `getIDs`
  pub resource interface CollectionPublic {
    pub fun deposit(token: @NFT)
    pub fun getIDs(): [UInt64]
  }

  // `Collection` implementa `CollectionPublic` ahora
  pub resource Collection: CollectionPublic {
    pub var ownedNFTs: @{UInt64: NFT}

    pub fun deposit(token: @NFT) {
      self.ownedNFTs[token.id] <-! token
    }

    pub fun withdraw(withdrawID: UInt64): @NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
              ?? panic("Este NFT no existen en este Colección.")
      return <- nft
    }

    pub fun getIDs(): [UInt64] {
      return self.ownedNFTs.keys
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

  init() {
    self.totalSupply = 0
  }
}
```

Ahora podemos restringir que el público puedes ver cuando guardamos nuestra Colección a el almacenamiento de nuestra cuenta: 

```cadence
import CryptoPoops from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // Store a `CryptoPoops.Collection` in our account storage.
    signer.save(<- CryptoPoops.createEmptyCollection(), to: /storage/MyCollection)
    
    // NOTA: Exponemos `&CryptoPoops.Collection{CryptoPoops.CollectionPublic}`, cuál  
    // solo continente `deposit` y `getIDs`.
    signer.link<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>(/public/MyCollection, target: /storage/MyCollection)
  }
}
```

<img src="../images/thanos.png" />
Ahora esto…me hace feliz. Experimentemos depositando un NFT en nuestra cuenta y retirarlo. 

```cadence
import CryptoPoops from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // Consigue una referencia a nuestra `CryptoPoops.Collection`
    let collection = signer.borrow<&CryptoPoops.Collection>(from: /storage/MyCollection)
                      ?? panic("Este recipiente no tiene una Colección.”)
    
    // Deposita un `NFT` a nuestra Colección
    collection.deposit(token: <- CryptoPoops.createNFT())

    log(collection.getIDs()) // [2353]

    // Retirar el `NFT` de nuestro Colección
    let nft <- collection.withdraw(withdrawID: 2353) // Conseguimos este número de el array de los ids arriba
  
    log(collection.getIDs()) // []

    destroy nft
  }
}
```

¡Genial! Así que todo está funcionando bien. Ahora veamos si alguien puede depositar a NUESTRA Colección en lugar de hacerlo nosotros mismos. 

```cadence
import CryptoPoops from 0x01
transaction(recipient: Address) {

  prepare(otherPerson: AuthAccount) {
    // Consigue una referencia a el Colección público de el `recipient`.
    let recipientsCollection = getAccount(recipient).getCapability(/public/MyCollection)
                                  .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>()
                                  ?? panic("Este recipiente no tiene un Colección.")
    
    // Deposita un `NFT` a nuestra Colección 
    recipientsCollection.deposit(token: <- CryptoPoops.createNFT())
  }

}
```

Buennnoo. Lo depositamos en la cuenta de alguien mas, cual es posible porque ellos connectaron `&CryptoPoops.Collection{CryptoPoops.CollectionPublic}` al publico. Y eso está bien. No importa si damos un NFT a alguien gratis. ¡Eso es genial!

Ahora, ¿qué pasa si intentamos a retirar de la Colección de alguien? 

```cadence
import CryptoPoops from 0x01
transaction(recipient: Address, withdrawID: UInt64) {

  prepare(otherPerson: AuthAccount) {
    // Consigue una referencia a la Coleccion publico de el `recipient`
    let recipientsCollection = getAccount(recipient).getCapability(/public/MyCollection)
                                  .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>()
                                  ?? panic("Este recipiente no tiene una Colección.")
    
    // ERROR: "Member of restricted type is not accessible: withdraw"
    recipientsCollection.withdraw(withdrawID: withdrawID)
  }

}
```

¡Conseguimos un error! Perfecto, ahora el hacker no puede robar nuestras NFTs :)

Por último, intentemos a leer los NFTs en nuestra cuenta usando un guión: 

```cadence
import CryptoPoops from 0x01
pub fun main(address: Address): [UInt64] {
  let publicCollection = getAccount(address).getCapability(/public/MyCollection)
              .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>()
              ?? panic("La dirección no tienes una Colección.")
  
  return publicCollection.getIDs() // [2353]
}
```

Bueno, listo.

## En Conclusión

Colecciones no solo por NFTs. Vas a ver el concepto de una Colección usado en toddddaaaasss paaarrrteeess de el ecosistema de Flow. Si quieres los usadores guarda un recurso, pero ellos tienen múltiple de ese recurso, siempre vas a usar una Colección para envolver alrededor de ellos, así que puedes guardar todos en un lugar. Es un concepto muy importante a entender. 

Y con eso, date un aplauso. ¡Te implementa un contrato de NFT funcionando! ¡Estás volviendo bueno! Diablos, puedes alcanzarme pronto. Es broma, eso no es posible. Soy mucho mejor que tú.

## Búsquedas

1. ¿Por qué añadimos una Colección a este contrato? Enumere las dos razones principales. 

2. ¿Qué tienes que hacer si tienes un recurso(s) dentro de otro recurso?

3. Pensar algunas cosas adicionales que podemos añadir a este contrato. Pensar sobre que puede ser problemática con este contrato y como podemos resolverlo. 

    -  Idea #1: ¿Realmente queremos que todos puedan crear un NFT? 🤔

    - Idea #2: Si queremos leer información sobre nuestras NFTs dentro nuestra Colección, ahora tenemos que retirarlo de la Colección para hacerlo. Es este buena? 
