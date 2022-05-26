#第 4 章第 4 天 - 创建 NFT 合约：转移、铸造和借款

----

让我们继续构建我们的 NFT 合约！啦啦啦

##视频

今天，我们将介绍 20:35 - 31:20：https: [//www.youtube.com/watch?v= bQVXSpg6GE8](https://www.youtube.com/watch?v=bQVXSpg6GE8)

##内容回顾

在最后一天，我们讨论了如何创建 NFT 并将它们存储在 Collection 中。我们制作集合的原因是我们可以将所有 NFT 存储在我们帐户存储的一个位置。

但是我们给自己留下了一个问题：我们 _真的_ 应该允许任何人创建 NFT 吗？这似乎有点奇怪。如果我们想控制谁可以铸造 NFT 怎么办？这就是我们今天要讨论的内容。

##转移

在我们开始控制谁可以“铸造”（或创建）NFT 之前，让我们先谈谈转移。我们如何将 NFT 从一个账户转移到另一个账户？

好吧，如果你还记得的话，只有 Collection 的所有者才能通过 `withdraw` 从他们的 Collection 中提取NFT。但是，任何人都可以 `deposit`  存储NFT到另一个人的收藏。这对我们来说是完美的，因为这意味着我们只需要访问 1 个 AuthAccount：也就是希望进行转移NFT 的账号！让我们启动一个交易来转移 NFT：

 _注意：这是假设您已经使用集合初始化设置了两个帐户。_ 

```
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

还不错吧？在学习了昨天的内容之后，我们应该明白这是怎么回事。以下是步骤：

1. 我们首先获得对签名者集合的引用。我们不使用能力，是因为我们需要直接从存储中借用，因为我们需要能够调用 `withdraw` .

2. 然后，我们得到一个对接收者集合的 _公共引用。_ 我们通过公共功能获得，因为我们无权访问他们的 AuthAccount，但这很好，因为我们只需要 `deposit` .

3. 我们使用 `withdraw` 将  `id`  对应的NFT 从签名者的集合中提取出来。

4. 我们使用 `deposit` 将 NFT 放入提取人的 Collection 中。

##铸币

好吧，让我们弄清楚如何防止每个人铸造自己的 NFT。现在的问题是，那么，谁应该有能力造币？

Cadence 的美妙之处在于我们可以自己决定很多事情。为什么我们不从创建铸造 NFT 的资源开始呢？然后，拥有该资源的任何人都可以拥有铸造 NFT 的能力。让我们在之前的合约之上构建如下合约代码：

```
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

以下是添加的内容：

1. 我们创建了一个新资源，名为 `Minter` 

2. 我们将 `createNFT` 函数移到 `Minter` 资源中

现在，任何持有该 `Minter` 资源的人都可以铸造 NFT。好的，这很酷，但现在谁来拥有铸币机？

最简单的解决方案是 `Minter` 自动将其提供给正在部署合约的帐户。我们可以通过将资源保存到函数 `Minter` 合约账户的存储中来做到这一点：具体看 `init` 函数：

```
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

当您部署合约时，在 `init` 函数内部，您实际上可以访问部署帐户的 `AuthAccount` ! 所以我们可以将内容保存到那里的帐户存储中。

看看我们最后做了什么？我们保存 `Minter` 到了帐户存储中。太完美了！现在，只有部署了合约的账户才能铸造 NFT，而且由于没有让其他用户获得 NFT 的 `Minter` 功能，它是完全安全的！

让我们看一个使用 `Minter` 为某人铸造 NFT 的示例交易。

 _注意：假设 `signer` 是部署合约的人，因为只有他拥有 `Minter` 资源_ 

```
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

啦啦啦！我们成功实施了安全铸币。这是在 Cadence 中需要注意的一个非常重要的模式：将一些“管理”功能委托给某个资源的能力，例如 `Minter` 在本例中的，其“管理员”通常是部署合约的帐户。

##借用

好吧，最后一件事。还记得昨天我们说过，如果不从集合中提取我们的 NFT，我们就无法读取它，这很奇怪吗？好吧，让我们在 `Collection` 资源中添加一个函数，让我们借用 NFT：

```
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
      return &self.ownedNFTs[id] as &NFT
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

超级简单吧！我们甚至在 NFT 中添加了一些额外的字段（或“元数据”），这样当我们从 Collection 中借用它的引用时，我们就可以读取有关它的信息。为了获取引用，我们使用 `Collection` 新函数 `borrowNFT` ，在 `ownedNFTs` 字典中获得一个 NFT 的引用。我们重新部署我们的合约，设置我们的账户，并运行一个新的交易来铸造一个 NFT：

```
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

太厉害了！我们将 NFT 铸造到收件人的帐户中。现在让我们继续在脚本中，使用新函数 `borrowNFT` 来读取存入帐户的 NFT 元数据：

```
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

稍等！我们得到一个错误！这是为什么？啊，是因为我们忘记在合约里面添加 `borrowNFT` 接口 `CollectionPublic` 了，所以不能对外开放！让我们继续解决这个问题：

```
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

现在，我们可以重试我们的脚本（假设你重新铸造了 NFT）：

```
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

啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊！！！我们读取我们的 NFT 元数据，而无需将其从集合中提取；）

##结论

我们现在已经编写了一个成熟的 NFT 智能合约。真是太酷了。我们也完成了第 4 章。

在下一章中，我们完整这份合约的完整版本，并开始学习如何让我们的合约更加“正式”。也就是说，如何实现一个叫做合约接口的东西，让其他应用程序知道我们的 NFT 智能合约 _实际上_ 是一个真正的” NFT 智能合约“。

##任务

因为在本章中我们有很多话题要讨论，所以我希望你做到以下几点：

以目前的合约为准，为我们的合约并每个资源或功能添加评论，用你自己的话解释它在做什么。类似这样的：

```
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
      return &self.ownedNFTs[id] as &NFT
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

​​
