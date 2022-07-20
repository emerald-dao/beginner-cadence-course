# Глава 5 День 3 - Создание контракта NFT: реализация стандарта NonFungibleToken (часть 3/3)

Давайте закончим наш контракт CryptoPoops NFT из главы 4, используя наши новые знания о стандарте NonFungibleToken.

Мы потратим весь этот день на то, чтобы переделать наш NFT-контракт в соответствии со стандартом, который можно найти здесь: https://github.com/onflow/flow-nft/blob/master/contracts/NonFungibleToken.cdc

## Video

Сегодня мы посмотрим видеоролик с 31:20 и до конца: https://www.youtube.com/watch?v=bQVXSpg6GE8

## Реализация стандарта NonFungibleToken

В стандарте NonFungibleToken много чего есть. Давайте рассмотрим его подробнее:

```cadence
/**
## The Flow Non-Fungible Token standard
*/

// The main NFT contract interface. Other NFT contracts will
// import and implement this interface
//
pub contract interface NonFungibleToken {

    pub var totalSupply: UInt64

    pub event ContractInitialized()

    pub event Withdraw(id: UInt64, from: Address?)

    pub event Deposit(id: UInt64, to: Address?)

    pub resource interface INFT {
        // The unique ID that each NFT has
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

        // Dictionary to hold the NFTs in the Collection
        pub var ownedNFTs: @{UInt64: NFT}

        // withdraw removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @NFT

        // deposit takes a NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        pub fun deposit(token: @NFT)

        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64]

        // Returns a borrowed reference to an NFT in the collection
        // so that the caller can read data and call methods from it
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
Ух ты. Мне страшно.

Хорошая новость заключается в том, что мы уже выполнили большую его часть. Хотите верьте, хотите нет, но я настолько хороший учитель, что я заставил нас выполнить 75% этого контракта без вашего ведома. Черт, я молодец! Давайте посмотрим на контракт, который мы написали на данный момент:

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

Неплохо, правда!? Помните, чтобы реализовать интерфейс контракта, мы должны использовать синтаксис `: {contract interface}`, так что давайте сделаем это...

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...other stuff...
}
```

*Примечание: поскольку эти контракты становятся длинными, я собираюсь начать сокращать их, как я сделал выше, и заменять некоторые строки, которые должны быть там, словами "...other stuff... "*.

Помните из прошлой главы, что интерфейс контракта определяет некоторые вещи, которые нам нужны в нашем контракте, если мы хотим его реализовать. Вы заметите, что теперь, когда мы реализуем этот интерфейс, в нашем контракте появляется огромное количество ошибок. Не волнуйтесь, мы их исправим. 

Первое, что вы увидите в интерфейсе контракта `NonFungibleToken`, это следующие вещи:

```cadence
pub var totalSupply: UInt64

pub event ContractInitialized()

pub event Withdraw(id: UInt64, from: Address?)

pub event Deposit(id: UInt64, to: Address?)
```

У нас уже есть `totalSupply`, но нам нужно поместить события в наш контракт `CryptoPoops`, иначе он будет жаловаться, что они отсутствуют. Давайте сделаем это ниже:

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  pub var totalSupply: UInt64

  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)

  // ...other stuff...
}
```

Отлично! Следующее, что стандарт NonFungibleToken говорит, что мы должны сделать, это иметь ресурс `NFT` с полем `id` и он также должен реализовать `NonFungibleToken.INFT`. Мы уже делаем первые две вещи, но он не реализует интерфейс ресурса `NonFungibleToken.INFT`, как это сделано в стандарте. Поэтому давайте добавим это в наш контракт.

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  pub var totalSupply: UInt64

  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)

  // The only thing we added here is:
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

  // ...other stuff...
}
```

Потрясающе. Мы прошли примерно половину пути.

Следующее, что вы увидите в стандарте, это три интерфейса ресурсов:

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

Кажется, что это очень много кода, верно? Хорошей новостью является то, что, если вы помните из прошлого дня, нам не нужно повторно реализовывать интерфейсы ресурсов внутри нашего собственного контракта, использующего стандарт. Эти интерфейсы определены только для того, чтобы наш ресурс `Collection` мог их реализовать.

Прежде чем мы заставим нашу `Collection` реализовать эти интерфейсы ресурсов, я объясню, что они делают:

### Provider
Первым является `Provider`. Он гарантирует, что все, что его реализует, имеет функцию `withdraw`, которая принимает `withdrawID` и возвращает `@NFT`. ** ВАЖНО: Обратите внимание на тип возвращаемого значения: `@NFT`.** О каком ресурсе NFT идет речь? Говорит ли это о типе `NFT` внутри нашего контракта `CryptoPoops`? Нет! Речь идет о типе внутри интерфейса контракта `NonFungibleToken`. Таким образом, когда мы реализуем сами эти функции, нам нужно убедиться, что мы помещаем `@NonFungibleToken.NFT`, а не просто `@NFT`. Мы говорили об этом и в предыдущей главе.

Итак, давайте теперь реализуем `Provider` в нашей Коллекции:

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...other stuff...

  // Collection now implements NonFungibleToken.Provider
  pub resource Collection: NonFungibleToken.Provider {
    pub var ownedNFTs: @{UInt64: NFT}

    // Notice that the return type is now `@NonFungibleToken.NFT`, 
    // NOT just `@NFT`
    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
              ?? panic("This NFT does not exist in this Collection.")
      return <- nft
    }

    // ...other stuff...

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  // ...other stuff...
}
```

### Receiver
Круто! А что насчет интерфейса контракта `Receiver`? Он говорит, что все, что его реализует, должно иметь функцию `deposit`, которая принимает параметр `token` типа `@NonFungibleToken.NFT`. Давайте добавим `NonFungibleToken.Receiver` в нашу Коллекцию ниже:

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...other stuff...

  // Collection now implements NonFungibleToken.Receiver
  pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver {
    pub var ownedNFTs: @{UInt64: NFT}

    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
              ?? panic("This NFT does not exist in this Collection.")
      return <- nft
    }

    // Notice that the `token` parameter type is now 
    // `@NonFungibleToken.NFT`, NOT just `@NFT`
    pub fun deposit(token: @NonFungibleToken.NFT) {
      self.ownedNFTs[token.id] <-! token
    }

    // ...other stuff...

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  // ...other stuff...
}
```

Отлично. Наши функции `withdraw` и `deposit` теперь работают с правильными типами. Но есть несколько вещей, которые мы можем добавить:
1. Давайте сделаем `emit` событие `Withdraw` внутри функции `withdraw`.
2. Давайте сделаем  `emit` событие `Deposit` внутри функции `deposit`.
3. Поскольку наша `коллекция` должна соответствовать интерфейсу контракта `NonFungibleToken`, нам нужно изменить `ownedNFTs`, чтобы хранить типы токенов `@NonFungibleToken.NFT`, а не только типы `@NFT` из нашего контракта. Если мы этого не сделаем, наша `Collection` не будет соответствовать стандарту.

Давайте сделаем эти три изменения ниже:

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...other stuff...

  pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver {
    // 3. We changed this to `@NonFungibleToken.NFT`
    pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
            ?? panic("This NFT does not exist in this Collection.")

      // 1. emit the `Withdraw` event
      emit Withdraw(id: nft.id, from: self.owner?.address)

      return <- nft
    }

    pub fun deposit(token: @NonFungibleToken.NFT) {
      // 2. emit the `Deposit` event
      emit Deposit(id: token.id, to: self.owner?.address)

      self.ownedNFTs[token.id] <-! token
    }

    // ...other stuff...

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  // ...other stuff...
}
```

Удивительно. У вас может возникнуть один вопрос:

**Что такое `self.owner?.address`?

 `self.owner` - это часть кода, которую вы можете использовать внутри любого ресурса, которым владеет аккаунт. Поскольку ресурс Collection будет находиться в хранилище аккаунта, мы можем использовать `self.owner`, чтобы получить текущий аккаунт, который держит эту конкретную коллекцию в своем хранилище. Это очень полезно для определения того, кто выполняет действие, особенно в случае, когда мы хотим сообщить, кому мы пополняем аккаунт и с кого снимаем. `self.owner?.address` - это просто адрес владельца.

Далее подумайте о том, что представляет собой тип `@NonFungibleToken.NFT`. Это более общий тип, чем просто `@NFT`. Технически, буквально любой NFT на Flow подходит под тип `@NonFungibleToken.NFT`. У этого есть плюсы и минусы, но один определенный минус заключается в том, что теперь любой может внести свой собственный тип NFT в нашу Коллекцию. Например, если мой друг определит контракт под названием `BoredApes`, то технически он может поместить его в нашу Коллекцию, поскольку у него есть тип `@NonFungibleToken.NFT`. Таким образом, мы должны добавить в нашу функцию `deposit` нечто, называемое "force cast":

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...other stuff...

  pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver {
    pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
            ?? panic("This NFT does not exist in this Collection.")
      emit Withdraw(id: nft.id, from: self.owner?.address)
      return <- nft
    }

    pub fun deposit(token: @NonFungibleToken.NFT) {
      // We "force cast" the `token` to a `@NFT` type
      // using the `as!` syntax. This says:
      // "if `token` is an `@NFT` type, move it to the 
      // `nft` variable. If it's not, panic."
      let nft <- token as! @NFT
      emit Deposit(id: nft.id, to: self.owner?.address)
      self.ownedNFTs[nft.id] <-! nft
    }

    // ...other stuff...

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  // ...other stuff...
}
```

Вы увидите, что мы используем оператор "принудительного приведения" `as!`. В приведенном выше коде `@NonFungibleToken.NFT` является более общим типом, чем `@NFT`. **Поэтому мы должны использовать `as!`, который, по сути, "понижает" наш общий тип (`@NonFungibleToken.NFT`) до более конкретного типа (`@NFT`).** В этом случае `let nft <- token as! @NFT` говорит: "Если `token` является типом `@NFT`, "опустите" его и переместите в переменную `nft`. Если это не так, то `panic`". Теперь мы можем быть уверены, что в нашу Коллекцию можно положить только CryptoPoops.


### CollectionPublic
Последний интерфейс ресурса, который нам нужно реализовать, это `CollectionPublic`, который выглядит следующим образом:

```cadence
pub resource interface CollectionPublic {
    pub fun deposit(token: @NFT)
    pub fun getIDs(): [UInt64]
    pub fun borrowNFT(id: UInt64): &NFT
}
```

Итак, у нас уже есть `deposit`, но нам нужны `getIDs` и `borrowNFT`. Давайте добавим `NonFungibleToken.CollectionPublic` в нашу Коллекцию ниже:

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...other stuff...

  // Collection now implements NonFungibleToken.CollectionPublic
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

    // Added this function. We already did this before.
    pub fun getIDs(): [UInt64] {
      return self.ownedNFTs.keys
    }

    // Added this function. We already did this before, but
    // We have to change the types to `&NonFungibleToken.NFT` 
    // to fit the standard.
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

  // ...other stuff...
}
```

CКруто! Мы добавили и `getIDs` (который не изменился по сравнению с тем, что мы имели ранее), и `borrowNFT`. Нам пришлось изменить типы на `&NonFungibleToken.NFT` вместо просто `&NFT`, чтобы соответствовать стандарту.

Мы очень близки к завершению. Последнее, что стандарт требует от нас реализовать, это функцию `createEmptyCollection`, которая у нас уже есть! Давайте добавим ее ниже:

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...other stuff...

  // Add the `createEmptyCollection` function.
  pub fun createEmptyCollection(): @NonFungibleToken.Collection {
    return <- create Collection()
  }

  // ...other stuff...
}
```

Конечно, мы должны сделать тип возврата `@NonFungibleToken.Collection`.

Наконец, мы хотим использовать событие `ContractInitialized` внутри `init` контракта:

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...other stuff...

  init() {
    self.totalSupply = 0
    emit ContractInitialized()
  }
}
```

Теперь, когда мы правильно реализовали стандарт, давайте добавим функциональность чеканки:

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  
  // ...other stuff...

   // Define a Minter resource
   // so we can manage how
   // NFTs are created
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

    // Save the minter to account storage:
    self.account.save(<- create Minter(), to: /storage/Minter)
  }
}
```

АААААА И МЫ ЗАКОНЧИЛИ!!!!!!!!!!!!!!!! Давайте теперь посмотрим на весь контракт:

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

## Проблема

Есть одна проблема с этим контрактом CryptoPoops. Если вы внимательно посмотрите, то заметите, что существует очень большая проблема с тем, как функция `borrowNFT` написана внутри `Collection`. Она возвращает тип `&NonFungibleToken.NFT` вместо типа `&NFT`. Вы видите, что в этом плохого?

Весь смысл `borrowNFT` в том, чтобы позволить нам читать метаданные NFT. Но что раскрывает тип `&NonFungibleToken.NFT`? Только поле `id`! Мы больше не можем читать другие метаданные нашего ресурса NFT.

Чтобы исправить это, нам нужно использовать нечто, называемое `auth` ссылкой. Если вы помните оператор "принудительного приведения" `as!` выше, он "приводит" общий тип к более конкретному типу, и если он не срабатывает, то возникает `panic`. В случае со ссылками для "приведения" вам нужна "авторизованная ссылка", которая помечена ключевым словом `auth`. Мы можем сделать это следующим образом:

```cadence
pub fun borrowAuthNFT(id: UInt64): &NFT {
  let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
  return ref as! &NFT
}
```

Видите, что мы сделали? Мы получили авторизованную ссылку на тип `&NonFungibleToken.NFT`, поставив перед ним `auth`, а затем  понизили" тип с помощью `as!` до типа `&NFT`. При использовании ссылок, если вы хотите выполнить нисходящую обработку, у вас **должна быть ссылка `auth`. 

Если бы `ref` не была типом `&NFT`, то произошла бы `panic`, но мы знаем, что это всегда будет работать, так как в нашей функции deposit мы убедились, что храним типы `@NFT`.

Ураааа! Теперь мы можем читать метаданные наших NFT с помощью функции `borrowAuthNFT`. Но есть еще одна проблема: `borrowAuthNFT` непубличная, потому что она не находится внутри `NonFungibleToken.CollectionPublic`. Вы решите эту проблему в своем задании.

## Заключение

Вы успешно создали свой собственный контракт NFT. И что еще лучше, теперь это официально контракт NonFungibleToken, то есть вы можете использовать его где угодно, и приложения будут знать, что они работают с контрактом NFT. Это потрясающе.

Кроме того, вы официально завершили первый основной раздел курса. Вы можете называть себя разработчиком Cadence! Я бы предложил прервать этот курс и реализовать несколько собственных контрактов, потому что теперь у вас есть знания для этого. В следующей главе мы узнаем, как развернуть наш контракт в Flow Testnet и взаимодействовать с ним.

## Квесты

1. Что делает "принудительное приведение" (force casting) с помощью `as!`? Почему это полезно в нашей Коллекции?

2. Что делает `auth`? Когда мы его используем?

3. Этот последний квест будет самым сложным для вас. Возьмите этот контракт:

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

и добавьте функцию `borrowAuthNFT`, как мы это делали в разделе "Проблема" выше. Затем найдите способ сделать ее общедоступной для других людей, чтобы они могли прочитать метаданные нашего NFT. Затем запустите скрипт для отображения метаданных NFT для определенного `id`.

Вам придется написать все транзакции для настройки учетных записей, создания NFT, а затем скрипты для чтения метаданных NFT. Мы сделали большую часть этого в главах до этого момента, так что вы можете искать подсказки там :)