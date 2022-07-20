# Глава 4 День 3 - Создание контракта NFT: Коллекции (часть 1/3)

Вы уже многому научились. Давайте применим все, что вы узнали, чтобы создать свой собственный NFT контракт.

## Video

В следующих нескольких главах мы будем делать то же самое, что я делаю в этом видео. Сегодня мы посмотрим только с 00:00 до 20:35: https://www.youtube.com/watch?v=bQVXSpg6GE8

## Обзор

<img src="../images/accountstorage1.PNG" />
<img src="../images/capabilities.PNG" />

## Пример NFT (NonFungibleToken)

Давайте проведем следующие несколько дней, работая над примером NonFungibleToken. Мы создадим наш собственный контракт NFT под названием CryptoPoops. Таким образом, вы рассмотрите все предыдущие концепции, которые вы изучили до сих пор, и реализуете свой собственный NFT!

Давайте начнем с создания контракта:

```cadence
pub contract CryptoPoops {
  pub var totalSupply: UInt64

  pub resource NFT {
    pub let id: UInt64

    init() {
      // NOTE: every resource on Flow has it's own unique `uuid`. There
      // will never be resources with the same `uuid`.
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

Начнем с того, что:
1. Определение `totalSupply` (первоначальное значение 0)
2. Создание типа `NFT`. Мы задаем `NFT` одно поле: `id`. В качестве `id` используется `self.uuid`, который является уникальным идентификатором, который есть у каждого ресурса на Flow. Никогда не будет двух ресурсов с одинаковым `uuid`, поэтому он отлично подходит в качестве `id` для NFT, так как NFT - это токен, который полностью уникален по сравнению с любым другим токеном.
3. Создание функции `createNFT`, которая возвращает ресурс `NFT`, чтобы каждый мог создать свой собственный NFT.

Хорошо, это просто. Давайте сохраним NFT в нашем хранилище аккаунта и сделаем его общедоступным для чтения.

```cadence
import CryptoPoops from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // store an NFT to the `/storage/MyNFT` storage path
    signer.save(<- CryptoPoops.createNFT(), to: /storage/MyNFT)
    
    // link it to the public so anyone can read my NFT's `id` field
    signer.link<&CryptoPoops.NFT>(/public/MyNFT, target: /storage/MyNFT)
  }
}
```

Отлично! Теперь вы должны понять это благодаря предыдущей главе. Сначала мы сохраним NFT в хранилище аккаунта, а затем свяжем ссылку на него с общим доступом, чтобы мы могли прочитать его поле `id` с помощью скрипта. Что ж, давайте сделаем это!

```cadence
import CryptoPoops from 0x01
pub fun main(address: Address): UInt64 {
  let nft = getAccount(address).getCapability(/public/MyNFT)
              .borrow<&CryptoPoops.NFT>()
              ?? panic("An NFT does not exist here.")
  
  return nft.id // 3525 (some random number, because it's the `uuid` of 
                // the resource. This will probably be different for you.)
}
```

Потрясающе! Мы сделали несколько хороших вещей. Но давайте подумаем об этом на секунду. Что произойдет, если мы захотим хранить *еще один* NFT на нашем аккаунте?

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

Смотрите, что случилось. Мы получили ошибку! Почему? Потому что NFT уже существует на этом пути хранения. Как мы можем это исправить? Ну, мы можем просто указать другой путь хранения...

```cadence
import CryptoPoops from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // Note we use `MyNFT02` as the path now
    signer.save(<- CryptoPoops.createNFT(), to: /storage/MyNFT02)
    
    signer.link<&CryptoPoops.NFT>(/public/MyNFT02, target: /storage/MyNFT02)
  }
}
```

Это работает, но не очень хорошо. Если бы мы хотели иметь тонну NFT, нам пришлось бы запоминать ВСЕ пути хранения, которые мы ему задали, а это очень раздражает и неэффективно.

Вторая проблема заключается в том, что никто не может дать нам NFT. Поскольку только владелец аккаунта может хранить NFT непосредственно в хранилище своего аккаунта, никто не может передать нам NFT. Это тоже не очень хорошо.

### Коллекции

Способ решить обе эти проблемы - создать "Коллекцию", или контейнер, который объединяет все наши НФТ в один. Затем мы можем хранить коллекцию на одном пути хранения, а также разрешить другим "вносить депозиты" в эту коллекцию.

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
    // Maps an `id` to the NFT with that `id`
    //
    // Example: 2353 => NFT with id 2353
    pub var ownedNFTs: @{UInt64: NFT}

    // Allows us to deposit an NFT
    // to our Collection
    pub fun deposit(token: @NFT) {
      self.ownedNFTs[token.id] <-! token
    }

    // Allows us to withdraw an NFT
    // from our Collection
    //
    // If the NFT does not exist, it panics
    pub fun withdraw(withdrawID: UInt64): @NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
              ?? panic("This NFT does not exist in this Collection.")
      return <- nft
    }

    // Returns an array of all the NFT ids in our Collection
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

Замечательно. Мы определили ресурс `Collection`, который делает несколько вещей:
1. Хранит словарь `ownedNFTs`, который сопоставляет `id` с `NFT` с этим `id`.
2. Определяет функцию `deposit` для возможности пополнения счета `NFT`.
3. Определяет функцию `withdraw` для возможности вывода `NFT`.
4. Определяет функцию `getIDs`, чтобы мы могли получить список всех идентификаторов NFT в нашей Коллекции.
5. Определяет функцию `destroy`. В Cadence, **когда у вас есть ресурсы внутри ресурсов, вы ДОЛЖНЫ объявить функцию `destroy`, которая вручную уничтожает эти "вложенные" ресурсы с помощью ключевого слова `destroy`.**.

Мы также определили функцию `createEmptyCollection`, чтобы мы могли сохранить `коллекцию` в хранилище нашего аккаунта, чтобы мы могли лучше управлять нашими NFT. Давайте сделаем это сейчас:

```cadence
import CryptoPoops from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // Store a `CryptoPoops.Collection` in our account storage.
    signer.save(<- CryptoPoops.createEmptyCollection(), to: /storage/MyCollection)
    
    // Link it to the public.
    signer.link<&CryptoPoops.Collection>(/public/MyCollection, target: /storage/MyCollection)
  }
}
```

Потратьте несколько минут, чтобы действительно прочитать этот код. Что в нем не так? Подумайте о некоторых проблемах безопасности, связанных с ним. Почему плохо, что мы выкладываем `&CryptoPoops.Collection` в открытый доступ?

....

....

Вы уже подумали об этом? Причина в том, что теперь **любой может вывести NFT из нашей Коллекции!** Это очень плохо. 

Проблема, однако, заключается в том, что мы хотим, чтобы общественность могла `вносить` NFT в нашу Коллекцию, и мы хотим, чтобы они также могли читать идентификаторы NFT, которыми мы владеем. Как мы можем решить эту проблему?

Интерфейсы ресурсов, вуп-вуп! Давайте определим интерфейс ресурса, чтобы ограничить то, что мы выставляем в открытый доступ:

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

  // Only exposes `deposit` and `getIDs`
  pub resource interface CollectionPublic {
    pub fun deposit(token: @NFT)
    pub fun getIDs(): [UInt64]
  }

  // `Collection` implements `CollectionPublic` now
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

Теперь мы можем ограничить то, что могут видеть все, когда мы сохраняем нашу Коллекцию в хранилище аккаунта:

```cadence
import CryptoPoops from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // Store a `CryptoPoops.Collection` in our account storage.
    signer.save(<- CryptoPoops.createEmptyCollection(), to: /storage/MyCollection)
    
    // NOTE: We expose `&CryptoPoops.Collection{CryptoPoops.CollectionPublic}`, which 
    // only contains `deposit` and `getIDs`.
    signer.link<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>(/public/MyCollection, target: /storage/MyCollection)
  }
}
```

<img src="../images/thanos.png" />
Вот это... вызывает улыбку на моем лице. Давайте поэкспериментируем, положим NFT на наш аккаунт и выведем его.

```cadence
import CryptoPoops from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // Get a reference to our `CryptoPoops.Collection`
    let collection = signer.borrow<&CryptoPoops.Collection>(from: /storage/MyCollection)
                      ?? panic("The recipient does not have a Collection.")
    
    // deposits an `NFT` to our Collection
    collection.deposit(token: <- CryptoPoops.createNFT())

    log(collection.getIDs()) // [2353]

    // withdraw the `NFT` from our Collection
    let nft <- collection.withdraw(withdrawID: 2353) // We get this number from the ids array above
  
    log(collection.getIDs()) // []

    destroy nft
  }
}
```

Потрясающе! Итак, все работает хорошо. Теперь давайте посмотрим, сможет ли кто-то другой пополнить НАШУ коллекцию, вместо того чтобы делать это самому:

```cadence
import CryptoPoops from 0x01
transaction(recipient: Address) {

  prepare(otherPerson: AuthAccount) {
    // Get a reference to the `recipient`s public Collection
    let recipientsCollection = getAccount(recipient).getCapability(/public/MyCollection)
                                  .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>()
                                  ?? panic("The recipient does not have a Collection.")
    
    // deposits an `NFT` to our Collection
    recipientsCollection.deposit(token: <- CryptoPoops.createNFT())
  }

}
```

Отлично. Мы пополнили чужой аккаунт, что вполне возможно, потому что они связаны `&CryptoPoops.Collection{CryptoPoops.CollectionPublic}` с общим доступом. И это нормально. Кого волнует, если мы дадим кому-то бесплатный NFT? Это же круто! 

Что произойдет, если мы попытаемся вывести NFT из чьей-то Коллекции?

```cadence
import CryptoPoops from 0x01
transaction(recipient: Address, withdrawID: UInt64) {

  prepare(otherPerson: AuthAccount) {
    // Get a reference to the `recipient`s public Collection
    let recipientsCollection = getAccount(recipient).getCapability(/public/MyCollection)
                                  .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>()
                                  ?? panic("The recipient does not have a Collection.")
    
    // ERROR: "Member of restricted type is not accessible: withdraw"
    recipientsCollection.withdraw(withdrawID: withdrawID)
  }

}
```

Мы получаем ошибку! Отлично, хакер не может украсть наши NFT :)

Наконец, давайте попробуем считать NFT на нашем аккаунте с помощью скрипта:

```cadence
import CryptoPoops from 0x01
pub fun main(address: Address): [UInt64] {
  let publicCollection = getAccount(address).getCapability(/public/MyCollection)
              .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>()
              ?? panic("The address does not have a Collection.")
  
  return publicCollection.getIDs() // [2353]
}
```

Бум. Готово.

## Заключение

Коллекции предназначены не только для NFT. В экосистеме Flow концепция коллекции используется повсеместно. Если вы хотите, чтобы пользователи хранили ресурс, но у них может быть несколько таких ресурсов, вы почти всегда будете использовать Коллекцию, чтобы обернуть их, чтобы хранить их все в одном месте. Это очень важная концепция, которую необходимо понять.

И поаплодируйте себе. Вы внедрили действующий контракт NFT! Ты становишься лучше, мой друг! Черт возьми, скоро ты сможешь догнать меня. Шучу, это невозможно. Я намного лучше тебя.

## Квесты

1. Почему мы добавили Коллекцию в этот контракт? Перечислите две основные причины.

2. Что нужно делать, если у вас есть ресурсы, "вложенные" внутрь другого ресурса? ("Вложенные ресурсы")

3. Проведите мозговой штурм дополнительных пунктов, которые мы могли бы добавить в этот контракт. Подумайте, что может быть проблематичным в этом контракте и как мы могли бы это исправить.

    - Идея №1: Действительно ли мы хотим, чтобы каждый мог чеканить NFT? 🤔. 

    - Идея №2: Если мы хотим прочитать информацию о наших NFT внутри нашей Коллекции, сейчас мы должны вынуть ее из Коллекции, чтобы сделать это. Хорошо ли это?