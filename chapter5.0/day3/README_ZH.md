# Chapter 5 Day 3 - 创建 NFT 合约：实现 NonFungibleToken 标准 (Part 3/3)

让我们使用对 NonFungibleToken 标准的新知识来完成第 4 章中的 CryptoPoops NFT 合约。

我们将花一整天的时间来改善我们的 NFT 合约以符合标准，可在此处找到：https://github.com/onflow/flow-nft/blob/master/contracts/NonFungibleToken.cdc

## 学习视频

今天的内容： 结语: https://www.youtube.com/watch?v=bQVXSpg6GE8

## 实现 NonFungibleToken 标准

NonFungibleToken 标准中有很多内容。让我们来看看它：

```javascript
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

我们实际上已经实现了其中的大部分内容。让我们看看到目前为止我们写的合约：

```javascript
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

还不错吧！？记住，为了实现一个合约接口，我们必须使用`: {contract interface}`语法，所以让我们在这里做......

```javascript
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...other stuff...
}
```

**注意：因为这些合约越来越长，我将开始像上面一样缩写它们，并将应该存在的其他内容替换为“......其他东西......”**

请记住，在上一章中，如果我们想实现它，合约接口指定了我们在合约中需要的一些东西。您会注意到，在我们实现合约后，我们的合约中出现了大量错误。不用担心，我们会修复它们。

在合约接口`NonFungibleToken`中看到的第一件事是：

```javascript
pub var totalSupply: UInt64

pub event ContractInitialized()

pub event Withdraw(id: UInt64, from: Address?)

pub event Deposit(id: UInt64, to: Address?)
```

我们已经有了`totalSupply`，但是我们需要将这些事件放入我们的`CryptoPoops`合约中，否则它会抱怨它们丢失了。下面这样做：

```javascript
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  pub var totalSupply: UInt64

  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)

  // ...other stuff...
}
```

`NonFungibleToken` 标准要求我们做的下一件事是去包含一个带有id字段的NFT资源，并且它还必须实现`NonFungibleToken.INFT`。好吧，我们已经做了前两件事，但是它没有像标准中那样实现`NonFungibleToken.INFT`资源接口。因此，让我们也将其添加到合约中。

```javascript
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

可以！我们已经完成了一半。

下面讨论的是在标准中的三个资源接口：

```javascript
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

看起来代码很多，对吧？好消息是，如果您还记得前一天的课程，我们不必在使用该标准的自己的合约中重新实现此资源接口。这些接口仅被定义以便我们的`Collection`资源可以实现它们。

在我们`Collection`实现这些资源接口之前，我将解释它们的作用：

### Provider
首先是`Provider`。 它确保实现任何实现该接口的资源必须带有一个`withdraw`函数，接收`withdrawID`并返回`@NFT`。**请注意返回值的类型是：`@NFT`。** 是指什么 NFT 资源？ 它是在谈论我们的“CryptoPoops”合约中的“NFT”类型吗？ 不！ 它指的是 `NonFungibleToken` 合约接口内部的类型。 因此，当我们自己实现这些函数时，我们必须确保我们放置了`@NonFungibleToken.NFT`，而不仅仅是`@NFT`。 我们在上一章也谈到了这一点。

现在让我们在 Collection 上实现 `Provider`：

```javascript
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
Cool! `Receiver` 合约接口怎么样？它说任何实现它的资源都需要一个 `deposit` 函数，该函数接受一个 `@NonFungibleToken.NFT` 类型的 `token` 参数。 让我们将 `NonFungibleToken.Receiver` 添加到下面的集合中：

```javascript
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

我们的 `withdraw` 函数和 `deposit` 函数现在可以使用正确的类型。 但是我们可以在这里添加一些额外东西：
1. 让我们在 `withdraw` 函数中`emit(发出)` `Withdraw` 事件
2. 让我们在 `deposit` 函数中`emit (发出)` `Deposit` 事件
3. 由于我们的 `Collection` 需要适配 `NonFungibleToken` 合约接口，我们需要更改 `ownedNFTs` 以存储 `@NonFungibleToken.NFT` 代币类型，而不仅仅是我们合约中的 `@NFT` 类型。 如果我们不这样做，我们的 `Collection` 将不符合标准。

让我们在下面进行这三个更改：

```javascript
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

现在可能遇到一个问题：

**什么是 `self.owner?.address`?**

 `self.owner` 是一段代码，您可以在帐户持有的任何资源中使用。 由于 Collection 资源将存在于帐户的存储中，因此我们可以使用“self.owner”来获取在其存储中持有该特定 Collection 的当前帐户。 这对于识别谁在执行操作非常有帮助，尤其是在我们想要传达我们正在向谁存款和取款的情况下。 `self.owner?.address` 只是所有者的地址。

接下来，想想 `@NonFungibleToken.NFT` 类型是什么。 它是一种比 `@NFT` 更通用的类型。 从字面上看，Flow 上的任何 NFT 都适合`@NonFungibleToken.NFT` 类型。 这有利有弊，但一个明确的缺点是，现在，任何人都可以将自己的 NFT 类型存入我们的 Collection。 例如，如果我的朋友定义了一个名为 `BoredApes` 的合约，他们可以在技术上将其存入我们的 Collection，因为它具有`@NonFungibleToken.NFT` 类型。 因此，我们必须在我们的 `deposit` 函数中添加一个称为“强制转换”的东西：

```javascript
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

你会看到我们使用“强制转换”操作符 `as!`。 在上面的代码中，`@NonFungibleToken.NFT` 是比 `@NFT` 更通用的类型。 **所以，我们必须使用 `as!`，它基本上将我们的泛型类型（`@NonFungibleToken.NFT`）“向下转换”为更具体的类型（`@NFT`）。** 在这种情况下，`let nft <- token as! @NFT` 是指：“如果 `token` 是 `@NFT` 类型，则将其“向下转换”并将其移动到 `nft` 变量中。如果不是，请报错。” 现在我们可以确定我们只能将 CryptoPoops 存入我们的 Collection。

### CollectionPublic
我们需要实现的最后一个资源接口是 `CollectionPublic`，如下所示：

```javascript
pub resource interface CollectionPublic {
    pub fun deposit(token: @NFT)
    pub fun getIDs(): [UInt64]
    pub fun borrowNFT(id: UInt64): &NFT
}
```

我们已经有了 `deposit`，但我们需要 `getIDs` 和 `borrowNFT`。 让我们将 `NonFungibleToken.CollectionPublic` 添加到下面的Collection中：

```javascript
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
      return &self.ownedNFTs[id] as &NonFungibleToken.NFT
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

Cool! 我们添加了`getIDs`（与我们之前的内容没有变化）和`borrowNFT`。 我们必须将类型更改为 `&NonFungibleToken.NFT` 而不仅仅是 `&NFT` 以符合标准。

已经快要完成了！标准希望我们实现的最后一件事是我们已经拥有的 `createEmptyCollection` 函数！ 让我们在下面添加它：

```javascript
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

当然，我们还必须将返回类型设为 `@NonFungibleToken.Collection`。

最后，我们想在合约的 `init` 中使用 `ContractInitialized` 事件：

```javascript
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...other stuff...

  init() {
    self.totalSupply = 0
    emit ContractInitialized()
  }
}
```

现在我们已经正确实现了标准，让我们也添加回我们的铸币功能：

```javascript
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

我们全部完成了!!!! 现在让我们看一下整个合约：

```javascript
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
      return &self.ownedNFTs[id] as &NonFungibleToken.NFT
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

## 问题

这份 CryptoPoops 合约存在一个问题。 如果你仔细观察，你会发现 `borrowNFT` 函数在 `Collection` 内部的编写方式存在很大的问题。 它返回一个 `&NonFungibleToken.NFT` 类型而不是 `&NFT` 类型。 你能看出这有什么不好吗？

“borrowNFT”的全部意义在于允许我们读取 NFT 的元数据。但是 `&NonFungibleToken.NFT` 类型暴露了什么？ 只有“id”字段！ 哦哦，我们不能再读取我们 NFT 资源的其他元数据了。

为了解决这个问题，我们需要使用一个叫做 `auth` 的引用。 如果您还记得上面的“强制转换”运算符 `as!`，它会将泛型类型“向下转换”为更具体的类型，如果它不起作用，它就会出现错误。 对于引用，为了“向下转换”，您需要一个标有 `auth` 关键字的“授权引用”。 我们可以这样做：

```javascript
pub fun borrowAuthNFT(id: UInt64): &NFT {
  let ref = &self.ownedNFTs[id] as auth &NonFungibleToken.NFT
  return ref as! &NFT
}
```

看看我们做了什么？ 通过将 `auth` 放在前面，我们获得了对 `&NonFungibleToken.NFT` 类型的授权引用，然后使用 `as!` 将类型“向下转换”为 `&NFT` 类型。 使用引用时，如果你想向下转换，你**必须**有一个 `auth` 引用。

如果 `ref` 不是 `&NFT` 类型，它会报错，但我们知道它总是会起作用，因为在我们的存款函数中，我们确保我们存储的是 `@NFT` 类型。

啊啊啊！现在我们可以使用 `borrowAuthNFT` 函数读取我们的 NFT 元数据。 但是还有一个问题：`borrowAuthNFT` 不能被公众访问，因为它不在 `NonFungibleToken.CollectionPublic` 中。 你将在你的作业中解决这个问题。

## 总结

你已经成功完成了你自己的 NFT 合约。更好的是，它现在正式成为一个 NonFungibleToken 合约，这意味着你可以在任何你想要的地方使用它，并且应用程序会知道他们正在使用 NFT 合约。这是惊人的。

此外，您已正式完成课程的第一个主要部分。您可以称自己为 Cadence 开发人员！ 我建议暂停这门课程并实施一些你自己的合约，因为你现在有这样做的知识。在接下来的章节中，我们将进入更高级的主题，以便您真正开始成为真正的Jacob。

## Quests

1. 使用 `as!` 的“强制转换”有什么作用？ 为什么它在我们的Collection中有用？

2. `auth` 有什么作用？ 我们什么时候使用它？

3. 这最后一个作业将是你迄今为止最困难的。 阅读这个合约：

```javascript
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
      return &self.ownedNFTs[id] as &NonFungibleToken.NFT
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

并添加一个名为 `borrowAuthNFT` 的函数，就像我们在上面的“问题”一节中所做的那样。然后，找到一种方法让其他人可以公开访问它，以便他们可以阅读我们 NFT 的元数据。然后，运行一个脚本来显示某个“id”的 NFT 元数据。

您必须编写所有交易来设置账户、铸造 NFT，然后编写脚本来读取 NFT 的元数据。 到目前为止，我们已经在各章中完成了大部分工作，因此您可以在那里寻求帮助 :)