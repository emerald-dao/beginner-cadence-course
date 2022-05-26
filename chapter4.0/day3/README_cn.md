#第 4 章第 3 天 - 创建 NFT 合约-集合

----

​
到目前为止，您已经学到了很多东西。让我们应用你学到的一切来制作你自己的 NFT 合约。

##视频

在接下来的几章中，我们将完全按照我在本视频中所做的工作。今天，我们只会从 00:00 - 20:35 开始：[https ://www.youtube.com/watch?v=bQVXSpg6GE8](https://www.youtube.com/watch?v=bQVXSpg6GE8)

##回顾
<img src="../images/accountstorage1.PNG" />
<img src="../images/capabilities.PNG" />


##NFT (NonFungibleToken) 示例

让我们在接下来的几天里研究一个 NonFungibleToken 示例。我们将创建我们自己的 NFT 合约，称为 CryptoPoops。通过这种方式，您将复习到目前为止所学的所有概念，并实现您自己的 NFT！

让我们从开发合同开始：

```
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

我们开始：

1. 定义 a  `totalSupply` （最初设置为 0）

2. 创建 `NFT` 类型。我们给出 `NFT` 第一个1 字段： `id` .  `id` 设置为 `self.uuid` ，是每个资源在 Flow 上的唯一标识符。永远不会有两个资源具有相同的 `uuid` ，因此它可以完美地用作NFT的id，因为 NFT 是一个完全不同于任何其他代币的代币。

3. 创建一个 `createNFT` 返回资源的函数 `NFT` ，这样任何人都可以铸造自己的 NFT。

好吧，这相对容易。让我们在我们的帐户存储中存储一个 NFT，并使其对公众可读。

```
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

好的！由于上一章，您现在应该理解这一点。我们首先将 NFT 保存到帐户存储中，然后将对它的引用链接到公众，以便我们可以利用 `id` ，使用脚本读取其字段。好吧，让我们这样做吧！

```
import CryptoPoops from 0x01
pub fun main(address: Address): UInt64 {
  let nft = getAccount(address).getCapability(/public/MyNFT)
              .borrow<&CryptoPoops.NFT>()
              ?? panic("An NFT does not exist here.")
  
  return nft.id // 3525 (some random number, because it's the `uuid` of 
                // the resource. This will probably be different for you.)
}
```

非常好！我们正朝着。但是，让我们考虑一下。如果我们想在我们的帐户中存储 _另一个_ NFT 会发生什么？

```
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

看看发生了什么。我们出错了！为什么？因为 NFT 已经存在于该存储路径中。我们如何解决这个问题？好吧，我们可以指定一个不同的存储路径...

```
import CryptoPoops from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // Note we use `MyNFT02` as the path now
    signer.save(<- CryptoPoops.createNFT(), to: /storage/MyNFT02)
    
    signer.link<&CryptoPoops.NFT>(/public/MyNFT02, target: /storage/MyNFT02)
  }
}
```

这行得通，但不是很好。如果我们想拥有大量的 NFT，我们必须记住我们给它的所有存储路径，这非常烦人且效率低下。

第二个问题是没有人可以给我们 NFT。由于只有账户所有者可以直接在他们的账户存储中存储 NFT，所以没有人可以为我们铸造 NFT。那也不好。

###收藏品

解决这两个问题的方法是创建一个“集合”或将我们所有的 NFT 包装成一个容器。然后，我们可以将 Collection 存储在 1 个存储路径，并允许其他人“存款”到该 Collection。

```
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

非常好。我们已经定义了一个 `Collection` 资源集合来完成如下工作：

1. 存储一个名为 `ownedNFTs` 的字典，映射 `id` 到对应的 `NFT` 。

2. 定义一个 `deposit` 函数，能够存入 `NFT` 。

3. 定义一个 `withdraw` 函数，能够撤回 `NFT` 。

4. 定义一个 `getIDs` 函数，以便我们可以获取 Collection 中所有 NFT id 的列表。

5. 定义一个 `destroy` 函数。在 Cadence 中， __每当您在资源中拥有资源时，您必须声明一个使用关键字 `destroy` 的销毁函数，手动销毁那些“嵌套”的资源。__ 

我们还定义了一个 `createEmptyCollection` 函数，以便我们可以将 `Collection` 保存到我们的帐户存储中，以便我们可以更好地管理我们的 NFT。现在让我们这样做：

```
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

花几分钟来真正阅读该代码。它有什么问题？想想它的一些安全问题。为什么我们把 `&CryptoPoops.Collection` 向公众公开是不好的？

……

……

你有没有想过？原因就是， __任何人都可以提取我们的收藏！__ 这真的很糟糕。

但是，问题是我们确实希望公众能够将 `deposit` NFT 放入我们的 Collection 中，并且我们希望他们也能读取我们拥有的 NFT id。我们如何解决这个问题？

资源接口，哈哈哈！让我们定义一个资源接口来限制我们向公众公开的内容：

```
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

现在我们可以限制当我们将 Collection 保存到帐户存储时，公众可以看到的内容：

```
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

[![undefined](https://github.com/maris205/beginner-cadence-course/raw/main/chapter4.0/images/thanos.png)](https://github.com/maris205/beginner-cadence-course/blob/main/chapter4.0/images/thanos.png)

现在这……确实让我的脸上露出了笑容。让我们通过将 NFT 存入我们的帐户并提取它来进行实验。

```
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

太好了！一切都运行良好。现在让我们看看其他人是否可以存入我们的收藏而不是自己做：

```
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

非常好。我们存入了别人的账户，这是完全可能的，因为他们与可公共访问的 `&CryptoPoops.Collection{CryptoPoops.CollectionPublic}` 关联。这很好。谁在乎我们是否给某人免费的 NFT？棒极了！

现在，如果我们试图从某人的收藏中提取NFT会发生什么？

```
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

我们得到一个错误！完美，黑客无法窃取我们的 NFT :)

最后，让我们尝试使用脚本读取我们帐户中的 NFT：

```
import CryptoPoops from 0x01
pub fun main(address: Address): [UInt64] {
  let publicCollection = getAccount(address).getCapability(/public/MyCollection)
              .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>()
              ?? panic("The address does not have a Collection.")
  
  return publicCollection.getIDs() // [2353]
}
```

太棒了。完毕。

##结论

集合不仅适用于 NFT。您将看到在 Flow 生态系统中的任何地方都使用了 Collection 的概念。如果您希望用户存储一个资源，但他们可能拥有多个该资源，您几乎总是会使用 Collection 来包装它们，以便您可以将它们全部存储在一个地方。这是一个非常重要的概念，需要理解。

然后，给自己一个掌声。你实现了一个正常运行的 NFT 合约！你越来越好了，我的朋友！哎呀，你可能很快就会赶上我。开个玩笑，这是不可能的。我比你好多了。

##任务

1. 为什么我们要在这个合约中添加一个 Collection？列出两个主要原因。

2. 如果您将资源“嵌套”在另一个资源中，您该怎么办？（“嵌套资源”）

3. 集思广益，我们可能想在这份合同中添加一些额外的东西。想想这份合同可能有什么问题，以及我们该如何解决它。
- 想法 #1：我们真的希望每个人都能铸造 NFT 吗？🤔.
- 想法 2：如果我们想在 Collection 中读取有关 NFT 的信息，现在我们必须将其从 Collection 中取出。这样真好吗？
