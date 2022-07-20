# Глава 4 День 4 - Создание контракта NFT: передача, чеканка и заимствование (часть 2/3)

Давайте продолжать строить наш контракт NFT! :D

## Видео

Сегодня мы изучим материал с 20:35 - 31:20: https://www.youtube.com/watch?v=bQVXSpg6GE8

## Обзор на сегодняшний день

В прошлый день мы рассмотрели, как создавать NFT и хранить их в Коллекции. Причина, по которой мы создали Коллекцию, заключалась в том, что мы могли хранить все наши NFT в одном месте в хранилище аккаунта.

Но мы столкнулись с некоторой проблемой: должны ли мы *действительно* разрешить кому-либо создавать NFT? Это кажется немного странным. Что если мы хотим контролировать, кто может создавать NFT? Об этом мы и поговорим сегодня. 

## Передача

Прежде чем перейти к контролю над тем, кто может "чеканить" (или создавать) NFT, давайте поговорим о передаче. Как мы можем перевести NFT с одного аккаунта на другой?

Ну, если вы помните, только владелец Коллекции может `выводить` средства из своей Коллекции. Однако любой может "пополнить" счет другого человека. Это идеально подходит для нас, потому что это означает, что нам понадобится доступ только к одному AuthAccount: человеку, который будет переводить (выводить) NFT! Давайте создадим транзакцию для перевода NFT:

*Примечание: Это предполагает, что вы уже настроили оба аккаунта с помощью Collection.*

```cadence
import CryptoPoops from 0x01

// `id` is the `id` of the NFT
// `recipient` is the person receiving the NFT
transaction(id: UInt64, recipient: Address) {

  prepare(signer: AuthAccount) {
    // get a reference to the signer's Collection
    let signersCollection = signer.borrow<&CryptoPoops.Collection>(from: /storage/MyCollection)
                            ?? panic("Signer does not have a CryptoPoops Collection")

    // Get a reference to the `recipient`s public Collection
    let recipientsCollection = getAccount(recipient).getCapability(/public/MyCollection)
                                  .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>
                                  ?? panic("The recipient does not have a CryptoPoops Collection.")
    
    // withdraws the NFT with id == `id` and moves it into the `nft` variable
    let nft <- signersCollection.withdraw(withdrawID: id)

    // deposits the NFT into the recipient's Collection
    recipientsCollection.deposit(token: <- nft)
  }

}
```

Не так уж плохо, верно? Мы должны понимать все это после изучения вчерашнего материала. Вот шаги:
1. Сначала мы получаем ссылку на коллекцию подписывающего. Мы не используем возможности, потому что нам нужно заимствовать непосредственно из хранилища, так как нам нужно иметь возможность вызвать `withdraw`.
2. Затем мы получаем *публичную* ссылку на Коллекцию получателя. Мы получаем ее через публичную возможность, потому что у нас нет доступа к их AuthAccount, но это нормально, поскольку нам нужно только `deposit`.
3. Мы `выводим` NFT с `id` из Коллекции подписанта.
4. Мы `вносим` NFT в Коллекцию получателя.

## Чеканка

Хорошо, давайте придумаем, как предотвратить чеканку собственных NFT всем желающими. Теперь вопрос в том, кто же тогда должен иметь возможность чеканить? 

Прелесть Cadence в том, что мы можем решить это сами. Почему бы нам не начать с создания ресурса, который чеканит NFT? Тогда тот, кто владеет ресурсом, сможет чеканить NFT. Давайте построим контракт, который у нас было ранее:

```cadence
pub contract CryptoPoops {
  
  // ... other stuff here ...

  pub fun createEmptyCollection(): @Collection {
    return <- create Collection()
  }

  // New resource: Minter
  // Allows anyone who holds it to
  // mint NFTs
  pub resource Minter {

    // mints a new NFT resource
    pub fun createNFT(): @NFT {
      return <- create NFT()
    }
  }

  init() {
    self.totalSupply = 0
  }
}
```

Вот что было добавлено:
1. Мы создали новый ресурс под названием `Minter`.
2. Мы перенесли функцию `createNFT` в ресурс `Minter`.

Теперь любой, кто владеет ресурсом `Minter`, может чеканить NFT. Хорошо, это здорово и все такое, но кто теперь будет минтером?

Самое простое решение - автоматически передать `Minter` учетной записи, которая разворачивает контракт. Мы можем сделать это, сохранив ресурс `Minter` в хранилище аккаунта разворачивающего контракт аккаунта внутри функции `init`:

```cadence
pub contract CryptoPoops {
  
  // ... other stuff here ...

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

    // Save the `Minter` resource to account storage here
    self.account.save(<- create Minter(), to: /storage/Minter)
  }
}
```

Когда вы разворачиваете контракт, внутри функции `init` у вас фактически есть доступ к `AuthAccount` разворачивающего аккаунта! Поэтому мы можем сохранять данные в хранилище аккаунта.

Видите, что мы сделали в самом конце? Мы сохранили `Minter` в хранилище аккаунта. Отлично! Теперь только аккаунт, который развернул контракт, имеет возможность чеканить NFT, и поскольку нет никакой функции, позволяющей другим пользователям получить `Minter`, это совершенно безопасно! 

Давайте рассмотрим пример транзакции, когда `Minter` чеканит кому-то NFT. 

*Примечание: Предположим, что `signer` был тем, кто развернул контракт, поскольку только у него есть ресурс `Minter`.

```cadence
import CryptoPoops from 0x01

transaction(recipient: Address) {

  // Let's assume the `signer` was the one who deployed the contract, since only they have the `Minter` resource
  prepare(signer: AuthAccount) {
    // Get a reference to the `Minter`
    let minter = signer.borrow<&CryptoPoops.Minter>(from: /storage/Minter)
                    ?? panic("This signer is not the one who deployed the contract.")

    // Get a reference to the `recipient`s public Collection
    let recipientsCollection = getAccount(recipient).getCapability(/public/MyCollection)
                                  .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>
                                  ?? panic("The recipient does not have a Collection.")

    // mint the NFT using the reference to the `Minter`
    let nft <- minter.createNFT()

    // deposit the NFT in the recipient's Collection
    recipientsCollection.deposit(token: <- nft)
  }

}
```

Уууууууууууууууууууууууу! Мы успешно реализовали безопасную чеканку. Это очень важный паттерн, о котором следует знать в Cadence: возможность делегировать некоторые функции "администратора" определенному ресурсу, такому как `Minter` в данном случае. Это "Admin" чаще всего передается хранилищу аккаунта, который развернул контракт.

## Заимствование

Ладно, последнее. Помните, вчера мы говорили, что странно, что мы не можем прочитать наш NFT, буквально не изъяв его из Коллекции? Что ж, давайте добавим функцию внутри ресурса `Collection`, которая позволит нам взять NFT:

```cadence
pub contract CryptoPoops {
  pub var totalSupply: UInt64

  pub resource NFT {
    pub let id: UInt64

    // Added some more metadata here so we can
    // read from it
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

    // Added this function so now we can
    // read our NFT
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

  // ... other stuff here ...

  init() {
    self.totalSupply = 0
    self.account.save(<- create Minter(), to: /storage/Minter)
  }
}
```

Все очень просто! Мы даже добавили несколько дополнительных полей (или "метаданных") в наш NFT, чтобы мы могли читать информацию о нем, когда мы берем его ссылку из Коллекции. Чтобы получить ссылку, мы используем новую функцию `borrowNFT` внутри нашей `Collection`, чтобы вернуть ссылку на один из наших NFT, который хранится в нашем словаре `ownedNFTs`. Если мы развернем наш контракт, настроим наши аккаунты и запустим новую транзакцию для чеканки NFT:

```cadence
import CryptoPoops from 0x01

// name: "Jacob"
// favouriteFood: "Chocolate chip pancakes"
// luckyNumber: 13
transaction(recipient: Address, name: String, favouriteFood: String, luckyNumber: Int) {

  prepare(signer: AuthAccount) {
    // Get a reference to the `Minter`
    let minter = signer.borrow<&CryptoPoops.Minter>(from: /storage/Minter)
                    ?? panic("This signer is not the one who deployed the contract.")

    // Get a reference to the `recipient`s public Collection
    let recipientsCollection = getAccount(recipient).getCapability(/public/MyCollection)
                                  .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>
                                  ?? panic("The recipient does not have a Collection.")

    // mint the NFT using the reference to the `Minter` and pass in the metadata
    let nft <- minter.createNFT(name: name, favouriteFood: favouriteFood, luckyNumber: luckyNumber)

    // deposit the NFT in the recipient's Collection
    recipientsCollection.deposit(token: <- nft)
  }

}
```

Потрясающе! Мы отчеканили NFT на аккаунт получателя. Теперь давайте продолжим использовать нашу новую функцию `borrowNFT` в скрипте, чтобы прочитать метаданные NFT, которые были зачислены на аккаунт:

```cadence
import CryptoPoops from 0x01
pub fun main(address: Address, id: id) {
  let publicCollection = getAccount(address).getCapability(/public/MyCollection)
              .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>()
              ?? panic("The address does not have a Collection.")
  
  let nftRef: &CryptoPoops.NFT = publicCollection.borrowNFT(id: id) // ERROR: "Member of restricted type is not accessible: borrowNFT"
  log(nftRef.name)
  log(nftRef.favouriteFood)
  log(nftRef.luckyNumber)
}
```

ПОДОЖДИТЕ! Мы получаем ошибку! Почему? А, это потому, что мы забыли добавить `borrowNFT` к интерфейсу `CollectionPublic` внутри нашего контракта, поэтому он недоступен для всех! Давайте продолжим и исправим это:

```cadence
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
```

Теперь мы можем повторить попытку выполнения нашего скрипта (при условии, что вы заново отчеканили NFT):

```cadence
import CryptoPoops from 0x01
pub fun main(address: Address, id: id) {
  let publicCollection = getAccount(address).getCapability(/public/MyCollection)
              .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>()
              ?? panic("The address does not have a Collection.")
  
  let nftRef: &CryptoPoops.NFT = publicCollection.borrowNFT(id: id)
  log(nftRef.name) // "Jacob"
  log(nftRef.favouriteFood) // "Chocolate chip pancakes"
  log(nftRef.luckyNumber) // 13
}
```

Мы читаем наши метаданные NFT без необходимости изымать их из коллекции ;)

## Заключение

Теперь мы написали полноценный смарт-контракт NFT. Это очень круто. Мы также завершили Главу 4. 

В следующей главе мы закончим этот контракт и начнем изучать, то как сделать наш контракт более "официальным". То есть, как реализовать нечто, называемое интерфейсом контракта, чтобы другие приложения знали, что наш смарт-контракт NFT *на самом деле является смарт-контрактом NFT.

## Квесты

Поскольку нам было о чем поговорить в этой главе, я хочу, чтобы вы сделали следующее:

Возьмите наш контракт NFT и добавьте комментарии к каждому ресурсу или функции, объясняя, что они делают, своими словами. Примерно так:


```cadence
pub contract CryptoPoops {
  pub var totalSupply: UInt64

  // This is an NFT resource that contains a name,
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

  // This is a resource interface that allows us to... you get the point.
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