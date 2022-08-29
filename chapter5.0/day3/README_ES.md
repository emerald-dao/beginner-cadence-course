# Capítulo 5 Día 3 - Creando un Contrato de NFT: Implementando Estándar de NonFungibleToken (Parte 3/3)

Terminamos nuestro contrato de NFT de CryptoPoops de Capítulo 4 usando nuestros nuevos conocimientos del estándar de NonFungibleToken. 

Para hoy vamos a reformarse nuestro contrato de NFT para adaptarse al estándar, encontrado aquí: https://github.com/onflow/flow-nft/blob/master/contracts/NonFungibleToken.cdc 

## Video

Hoy, vamos a cubrir 31:20 - El Fin: https://www.youtube.com/watch?v=bQVXSpg6GE8 

## Implementando el Estándar de NonFungibleToken

Hay mucho en el estándar de NonFungibleToken. Echemos un vistazo:

```cadence
/**
## El Estándar de Non-Fungible Token de Flow
*/

// La principal interfaz de contrato de NFT. Otras contratos va 
// importar y implementar este interfaz
//
pub contract interface NonFungibleToken {

    pub var totalSupply: UInt64

    pub event ContractInitialized()

    pub event Withdraw(id: UInt64, from: Address?)

    pub event Deposit(id: UInt64, to: Address?)

    pub resource interface INFT {
        // El ID único que cada NFT tiene
        pub let id: UInt64
    }

    pub resource NFT: INFT {
        pub let id: UInt64
    }

    pub resource interface Provider {
        pub fun withdraw(withdrawID: UInt64): @NFT {
            post {
                result.id == withdrawID: "The ID of the withdrawn token must be the same as the requested ID"
            }
        }
    }

    pub resource interface Receiver {
        pub fun deposit(token: @NFT)
    }

    pub resource interface CollectionPublic {
        pub fun deposit(token: @NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NFT
    }

    pub resource Collection: Provider, Receiver, CollectionPublic {

        // Un diccionario para guarda todo los NFTs en el Colección
        pub var ownedNFTs: @{UInt64: NFT}

        // withdraw quita un NFT de la colección y lo mueve al autor de la llamada
        pub fun withdraw(withdrawID: UInt64): @NFT

        // deposit toma un NFT y lo añade a un diccionario de la colección
        // and adds the ID to the id array
        pub fun deposit(token: @NFT)

        // getIDs devuelve un array de los IDs en la colección
        pub fun getIDs(): [UInt64]

        // Devuelve una referencia prestada a un NFT en la colección
        // así que la persona que llama puede leer los datos y llamar métodos de él 
        pub fun borrowNFT(id: UInt64): &NFT {
            pre {
                self.ownedNFTs[id] != nil: "NFT does not exist in the collection!"
            }
        }
    }

    pub fun createEmptyCollection(): @Collection {
        post {
            result.getIDs().length == 0: "The created collection must be empty!"
        }
    }
}
```

<img src="../images/homealone.jpg" />
Guau. Tengo miedo.
Las buenas noticias es que hemos implementado casi todo de esto. Lo creas o no, soy tan buen maestro que nos hice implementar el 75% de este contrato sin que tú lo supieras. Maldito, estoy bien! Veamos el contrato que escribimos hasta ahora:

```cadence
pub contract CryptoPoops {
  pub var totalSupply: UInt64

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

No tan mal, verdad? Pienso que estamos haciendo super bien. Recuerda, en orden para implementar una interfaz de contrato, tenemos que usar el sintaxi de: `{interfaz de contrato}`, así que hagamos eso aquí…

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...otras cosas...
}
```

*Nota: porque esos contratos son largos, voy a empezar abreviando ellos como lo hice arriba, y reemplazar el otro contenido que debe ser allí con “...otras cosas…”*

Recuerda del último capítulo que una interfaz de contrato especifica algunas cosas que necesitamos en nuestro contrato si queremos implementarlo. Vas a notar que conseguimos un MONTÓN de errores en nuestro contrato ahora que lo implementamos. No te preocupes, los arreglaremos. 

Los primeros cosas que veas en la interfaz de contrato de `NonFungibleToken` son estas cosas: 

```cadence
pub var totalSupply: UInt64

pub event ContractInitialized()

pub event Withdraw(id: UInt64, from: Address?)

pub event Deposit(id: UInt64, to: Address?)
```

Ya tenemos el `totalSupply`, pero tenemos que poner los eventos en nuestro contrato de `CryptoPoops` o se quejará de que faltan. Hagamos eso debajo: 

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  pub var totalSupply: UInt64

  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)

  // ...otras cosas...
}
```

¡Genial! La próxima cosas el estándar de NonFungibleToken dice que tenemos que hacer es tener un recurso de `NFT` con un campo de `id` y también tiene que implementar `NonFungibleToken.INFT`. Pues, ya lo hacemos las primera dos cosas, pero no implementa la interfaz de recurso de NonFungibleToken.INFT como lo hace en el estándar. Así que vamos a añadir este a nuestro contrato también. 

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  pub var totalSupply: UInt64

  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)

  // Lo único que agregamos aquí es
  // `: NonFungibleToken.INFT`
  pub resource NFT: NonFungibleToken.INFT {
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

  // ...otras cosas...
}
```

Genial. Estamos casi hemos terminado. 

La próxima cosas vas a ver dentro el estándar es estas tres interfaces de recursos: 

```cadence
pub resource interface Provider {
    pub fun withdraw(withdrawID: UInt64): @NFT {
        post {
            result.id == withdrawID: "The ID of the withdrawn token must be the same as the requested ID"
        }
    }
}

pub resource interface Receiver {
    pub fun deposit(token: @NFT)
}

pub resource interface CollectionPublic {
    pub fun deposit(token: @NFT)
    pub fun getIDs(): [UInt64]
    pub fun borrowNFT(id: UInt64): &NFT
}
``` 

Parece como mucho código, verdad? Las buenas noticias es que, si recuerdas de la última día, no tenemos que implementar los interfaces de los recursos dentro nuestro propio contrato que usa el estándar. Estas interfaces son solamente definidas así que nuestro recurso de `Collection` puede implementarlas. 

Antes de que hagamos que nuestra `Collection` se implemente estas interfaces de recursos, voy a explicar que ellos hacen: 

### Provider

Primero es el `Provider`. Se asegura de que cualquier cosa que lo implemente tiene la función de `withdraw` que toman un `withdrawID` y devuelve un `@NFT`. **IMPORTANTE: Nota el tipo de valor de devolver: `@NFT`.** ¿Cúal recurso de `NFT` es este hablando sobre? Estamos hablando sobre el tipo de `NFT` dentro nuestro contrato de `CryptoPoops`? ¡No! Se refiere a el tipo de contrato dentro la interfaz de contrato de `NonFungibleToken`. Entonces, cuando implementemos esas funciones ellos mismos, tenemos que asegurarnos que ponemos `@NonFungibleToken.NFT`, y no simplemente `@NFT`. Hablamos sobre esto en el último capítulo también.

Así que implementamos el `Provider` ahora en nuestra Collection: 

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...otras cosas...

  // Ahora Collection implementa NonFungibleToken.Provider
  pub resource Collection: NonFungibleToken.Provider {
    pub var ownedNFTs: @{UInt64: NFT}

    // Tenga en cuenta que ahora el tipo de devolver es `@NonFungibleToken.NFT`,
    // NO solo `@NFT`
    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
              ?? panic("This NFT does not exist in this Collection.")
      return <- nft
    }

    // ...otras cosas...

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  // ...otras cosas...
}
```

### Receiver

¡Genial! Pero qué sobre la interfaz de contrato de `Receiver`? Dice que cualquier cosa que implementan necesita tener una función de `deposit` que toma un parámetro de `token` que es del tipo de `@NonFungibleToken.NFT`. Vamos a añadir un `NonFungibleToken.Receiver` a nuestro Collection abajo: 

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...otras cosas...

  // Collection ahora implementa NonFungibleToken.Receiver
  pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver {
    pub var ownedNFTs: @{UInt64: NFT}

    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
              ?? panic("This NFT does not exist in this Collection.")
      return <- nft
    }

    // Tenga en cuenta que el tipo de parámetro de `token` ahora es
    // `@NonFungibleToken.NFT`, NO solo `@NFT`
    pub fun deposit(token: @NonFungibleToken.NFT) {
      self.ownedNFTs[token.id] <-! token
    }

    // ...otras cosas...

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  // ...otras cosas...
}
```

Bueno. Nuestra función de withdraw y deposit están funcionando ahora con los tipos correctos. Pero hay algunas cosas podemos añadir aquí: 
1. Emitimos (`emit`) el evento de `Withdraw` dentro la función de `withdraw`
2. Emitimos (`emit`) el evento de `Deposit` dentro la función de `deposit`
3. Así que nuestra `Collection` necesita adaptarse a la interfaz de contrato `NonFungibleToken`, necesitamos cambiar `ownedNFTs` para almacenar los tipos de token de `@NonFungibleToken.NFT`, no sólo los tipos `@NFT` de nuestro contrato. Si no lo hacemos, nuestra `Collection` no se ajustará correctamente al estándar.

Hagamos esas tres cambios abajo: 

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...other stuff...

  pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver {
    // 3. Cambiamos este a `@NonFungibleToken.NFT`
    pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
            ?? panic("This NFT does not exist in this Collection.")

      // 1. Emitir el evento de `Withdraw` 
      emit Withdraw(id: nft.id, from: self.owner?.address)

      return <- nft
    }

    pub fun deposit(token: @NonFungibleToken.NFT) {
      // 2. Emitir el evento de `Deposit` 
      emit Deposit(id: token.id, to: self.owner?.address)

      self.ownedNFTs[token.id] <-! token
    }

    // ...otras cosas...

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  // ...otras cosas...
}
```

Genial. Pero posiblemente hay una pregunta que tienes: 

**¿Qué es self.owner?.address?**

`self.owner` es un pedazo de código donde puedes ver dentro cualquier recurso que una cuenta está agarrando. Entonces un recurso de Collection vive en el almacenamiento de una cuenta, podemos usar `self.owner` para conseguir la cuenta actual que está almacenado eso Coleccion especificado dentro su almacenamiento. Este es super beneficioso para identificar quién está haciendo un acción, específicamente en el caso donde queramos comunicar quién estamos depositando y retirando de. `self.owner?.address` es simplemente la dirección del propietario. 

Ahora, pensar sobre qué es el tipo de `@NonFungibleToken.NFT`. Es como un tipo más genérico que `@NFT`. Técnicamente, cada NFT en Flow todos se ajustan al tipo `@NonFungibleToken.NFT`. Este tiene pros y contras, pero una contra definitiva es que ahora, cualquier persona puede deposit su propio tipo de NFT dentro nuestra Collection. Por ejemplo, si mi amigo define un contrato llamado `BoredApes`, ellos pueden técnicamente depositar eso en nuestra Colección porque tiene el tipo de `@NonFungibleToken.NFT`. Entonces, tenemos que añadir algo llamado un “force-cast(lanzado a la fuerza)” a nuestra función de `deposit`: 

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...otras cosas...

  pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver {
    pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
            ?? panic("This NFT does not exist in this Collection.")
      emit Withdraw(id: nft.id, from: self.owner?.address)
      return <- nft
    }

    pub fun deposit(token: @NonFungibleToken.NFT) {
      // Nos "force cast (lanzado a la fuerza)" el `token` a el tipo de `@NFT`
      // usando el sintaxi de `as!`. Este dice que:
      // “si `token` es un tipo de `@NFT`, mueve a el”
      // variable de `nft`. Si no es, pánico. 
      let nft <- token as! @NFT
      emit Deposit(id: nft.id, to: self.owner?.address)
      self.ownedNFTs[nft.id] <-! nft
    }

    // ...otras cosas...

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  // ...otras cosas...
}
```

Veas que usamos el operador de “force cast” `as!`. En el código de arriba, `@NonFungibleToken.NFT` es un tipo más genérico de `@NFT`. Así que, tenemos que usar `as!`, cúal básicamente “downcasts” nuestro tipo genérico (`@NonFungibleToken.NFT`) para ser un tipo más específico (`@NFT`). En este caso, `let nft <- token as! @NFT` dice que: “si token es un tipo de `NFT`, “downcast” y mueve a él variable de `nft`. Si no es, pánico.” Ahora podemos asegurar que solo podemos deposit CryptoPoops dentro nuestra Collection. 

### CollectionPublic

La última interfaz de recurso que necesitamos implementar es `CollectionPublic`, cúal parece como así: 

```cadence
pub resource interface CollectionPublic {
    pub fun deposit(token: @NFT)
    pub fun getIDs(): [UInt64]
    pub fun borrowNFT(id: UInt64): &NFT
}
```

Pues, ya tenemos `deposit`, pero necesitamos `getIDs` y `borrowNFT`. Vamos a añadir `NonFungibleToken.CollectionPublic` a nuestra Collection abajo: 

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...otras cosas...

  // Collection ahora implementa NonFungibleToken.CollectionPublic
  pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
    pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
            ?? panic("This NFT does not exist in this Collection.")
      emit Withdraw(id: nft.id, from: self.owner?.address)
      return <- nft
    }

    pub fun deposit(token: @NonFungibleToken.NFT) {
      let nft <- token as! @NFT
      emit Deposit(id: nft.id, to: self.owner?.address)
      self.ownedNFTs[nft.id] <-! nft
    }

    // Añadido esta función. Ya lo hicimos este antes.
    pub fun getIDs(): [UInt64] {
      return self.ownedNFTs.keys
    }

    // Añadido esta función. Ya lo hicimos este antes, pero
    // tenemos cambiar los tipos a `&NonFungibleToken.NFT` 
    // para adaptarse al estándar.
    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
      return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
    }

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  // ...otras cosas...
}
```

Genial! Añadido ambos `getIDs` (cual no cambian desde que teníamos previamente), y `borrowNFT`. Teníamos cambiar los tipos a `&NonFungibleToken.NFT` en lugar de sólo `&NFT` para adaptarse al estándar. 

¡Woooooooooooo! Estamos SUPER cerca de hacerse. La última cosa que el estándar quiere que implementemos es la función `createEmptyCollection`, ¡que ya tenemos! Vamos a agregarlo a continuación:

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...otras cosas...

  // Añadir el función de `createEmptyCollection`
  pub fun createEmptyCollection(): @NonFungibleToken.Collection {
    return <- create Collection()
  }

  // ...otras cosas...
}
```

Por supuesto, tenemos que hacer el tipo de devolución `@NonFungibleToken.Collection` también.

Por último, queremos utilizar el evento `ContractInitialized` dentro del `init` del contrato:

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...otras cosas...

  init() {
    self.totalSupply = 0
    emit ContractInitialized()
  }
}
```

Ahora que hemos implementado correctamente el estándar, agreguemos también nuestra funcionalidad de acuñación:

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  
  // ...otras cosas...

   // Define un recurso de Minter
   // así que podemos manejar como
   // los NFTs son creado
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
    emit ContractInitialized()

    // Guarda el minter a el almacenamiento de la cuenta:
    self.account.save(<- create Minter(), to: /storage/Minter)
  }
}
```

YYYYYYYY HEMOS TERMINADO!!!!!!!!!!!!!!!!! Miremos a todo el contrato ahora: 

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  pub var totalSupply: UInt64

  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)

  pub resource NFT: NonFungibleToken.INFT {
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

  pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
    pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
            ?? panic("This NFT does not exist in this Collection.")
      emit Withdraw(id: nft.id, from: self.owner?.address)
      return <- nft
    }

    pub fun deposit(token: @NonFungibleToken.NFT) {
      let nft <- token as! @NFT
      emit Deposit(id: nft.id, to: self.owner?.address)
      self.ownedNFTs[nft.id] <-! nft
    }

    pub fun getIDs(): [UInt64] {
      return self.ownedNFTs.keys
    }

    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
      return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
    }

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  pub fun createEmptyCollection(): @NonFungibleToken.Collection {
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
    emit ContractInitialized()
    self.account.save(<- create Minter(), to: /storage/Minter)
  }
}
```

## La Problema

Hay un error con este contrato de CryptoPoops. Si miras super cerca, vas a ver que hay un problema muy grande con cómo se escribe la función de `borrowNFT` dentro de la `Collection`. Devuelve un tipo de `&NonFungibleToken.NFT` en lugar de un tipo de `&NFT`. ¿Puedes ver que es malo sobre eso? 

El punto principal de `borrowNFT` es permitir nosotros a leer la metadata de los NFTs. Pero que se expone de el tipo de `&NonFungibleToken.NFT`? Solo el campo de `id`! Uh oh, no podemos leer las otras metadata de nuestro recurso de NFT. 

Para solucionarlo eso, necesitamos usar algo llamado una referencia de `auth`. Si recuerdas el operador de “force cast” `as!` de arriba, se “downcasts” un tipo genérico para ser un tipo más específico, y no funciona, se pánico. Con referencias, en orden a “downcast” tienes una “referencia autorizada” que es marcado con la palabra clave `auth`. Podemos hacer eso cómo así:  

```cadence
pub fun borrowAuthNFT(id: UInt64): &NFT {
  let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
  return ref as! &NFT
}
```

¿Ver lo que hicimos? Conseguimos una referencia autorizada a el tipo de `&NonFungibleToken.NFT` poniendo auth al frente de él, y entonces “downcasted” el tipo usando `as!` a el tipo de `&NFT`. Cuando usando referencias, si quieres downcast, tienes que tener una referencia de `auth`. 

Si `ref` no era un tipo de `&NFT`, pánico, pero sabemos que siempre funcione porque en nuestra función de deposit nos aseguramos de que estamos guardados los tipos de `@NFT`. 

¡Yaaaaay! Ahora podemos leer la metadata de nuestro NFTs usando la función de `borrowAuthNFT`. Pero hay una otra problema: `borrowAuthNFT` no es accesible al público, porque no es dentro `NonFungibleToken.CollectionPublic`. Vas a solucionar este problema en tus búsquedas. 

## En Conclusión

Ha completado con éxito su propio contrato de NFT. Y lo que es aún mejor, ahora es oficialmente un contrato NonFungibleToken, lo que significa que puede utilizarlo donde quiera y las aplicaciones sabrán que están trabajando con un contrato NFT. Increíble.

Además, ha completado oficialmente la primera sección principal del curso. ¡Puedes llamarte desarrollador de Cadence! Sugeriría pausar este curso e implementar algunos de sus propios contratos, porque ahora tiene los conocimientos necesarios para hacerlo. En el siguiente capítulo, aprenderemos a implementar nuestro contrato en Flow Testnet e interactuar con él.

## Búsquedas

1. ¿Con qué se hace el "force casting" con as! hacer? ¿Por qué es útil en nuestra Colección?

2. ¿Qué hace auth? ¿Cuándo lo usamos?

3. Esta última búsqueda va a ser la más difícil hasta ahora. Toma este contrato: 

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  pub var totalSupply: UInt64

  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)

  pub resource NFT: NonFungibleToken.INFT {
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

  pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
    pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
            ?? panic("This NFT does not exist in this Collection.")
      emit Withdraw(id: nft.id, from: self.owner?.address)
      return <- nft
    }

    pub fun deposit(token: @NonFungibleToken.NFT) {
      let nft <- token as! @NFT
      emit Deposit(id: nft.id, to: self.owner?.address)
      self.ownedNFTs[nft.id] <-! nft
    }

    pub fun getIDs(): [UInt64] {
      return self.ownedNFTs.keys
    }

    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
      return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
    }

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  pub fun createEmptyCollection(): @NonFungibleToken.Collection {
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
    emit ContractInitialized()
    self.account.save(<- create Minter(), to: /storage/Minter)
  }
}
```

Y añadir una función llamado `borrowAuthNFT` como hicimos en la sección llamado “The Problem” de arriba. Entonces, encontrar una manera para que sea públicamente accesible a otras personas para que puedan leer los metadatos de nuestro NFT. Entonces, ejecutar un guión para exponer las metadata de los NFTs para un `id` cierto. 

Tienes que escribir todas las transacciones para configurar las cuentas, mint (crea) los NFTs, y entonces los guiones para leer la metadata de los NFTs. Hicimos la mayor parte de este en los últimos capítulos, así que puedes buscar ayuda allí :)
