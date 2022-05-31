# Chapter 5 Day 2 - 合约接口

今天，我们将学习NFT智能合约中的最后一个概念。

## 学习视频

合约接口: https://www.youtube.com/watch?v=NHMBE6iRyfY

## 合约接口

好消息是今天的课程非常容易，因为您已经了解了其中大部分内容，只是您还不知道；）

合约接口与资源接口非常相似，只是它们是用于合约的。但是有一些区别，比如“我们如何定义合约接口？” 让我们看看下面：

```javascript
pub contract interface IHelloWorld {

}
```

合约接口与合约类似，它们是需要部署的。它们不在合同之内，而是完全独立的。

你部署一个合约接口就像你做一个普​​通的合约一样。唯一的区别是它们是用`contract interface`关键字声明的，就像上面的例子一样。

与资源接口类似，您不能初始化任何变量或定义任何函数。例如：

```javascript
pub contract interface IHelloWorld {
  pub var greeting: String
  
  pub fun changeGreeting(newGreeting: String)
}
```

我们可以在实际合约中实现它：

```javascript
import IHelloWorld from 0x01
pub contract HelloWorld: IHelloWorld {

}
```

您会注意到我们使用语法`: {接口名}`来实现它，就像我们使用资源一样。

您还会注意到我们收到一些编译错误：“合约`HelloWorld`不符合合约接口`IHelloWorld`”。为什么会这样？因为我们还没有实现接口里的东西！

```javascript
import IHelloWorld from 0x01
pub contract HelloWorld: IHelloWorld {
  pub var greeting: String
  
  pub fun changeGreeting(newGreeting: String) {
    self.greeting = newGreeting
  }

  init() {
    self.greeting = "Hello, Jacob!"
  }
}
```

OK，现在没问题了。

### 前/后置条件

我们昨天了解了前置/后置条件。它们的好处是我们实际上可以在资源接口或合约接口中使用它们，如下所示：

```javascript
pub contract interface IHelloWorld {
  pub var greeting: String
  
  pub fun changeGreeting(newGreeting: String) {
    post {
      self.greeting == newGreeting: "We didn't update the greeting appropiately."
    }
  }
}
```


我们仍然没有实现具体的函数，但我们在接口中强制做了一些限制：实现此合约接口的帐户必须执行以下操作：
1. 定义一个`greeting`字符串
2. 定义一个`changeGreeting`函数
3. 此外，由于后置条件，它们必须`greeting`正确地被`newGreeting`更新。

这是我们确保人们遵守我们的规则的好方法。

### 合约接口中的资源接口

让我们在合约接口中添加一个资源和一个资源接口：

```javascript
pub contract interface IHelloWorld {
  pub var greeting: String
  
  pub fun changeGreeting(newGreeting: String) {
    post {
      self.greeting == newGreeting: "We didn't update the greeting appropiately."
    }
  }

  pub resource interface IGreeting {
    pub var favouriteFood: String
  }

  pub resource Greeting: IGreeting {
    pub var favouriteFood: String
  }
}
```

我们在合约接口中定义了一个名为`Greeting`的资源和一个名为`IGreeting`的资源接口。这就是说：“无论什么合约实现了这个合约接口，它都必须有一个`Greeting`资源去专门实现`IHelloWorld.IGreeting`。”

理解这一点非常重要。如果我们定义合约来定义自己的`IGreeting`，就像这样：

```javascript
import IHelloWorld from 0x01
pub contract HelloWorld: IHelloWorld {
  pub var greeting: String
  
  pub fun changeGreeting(newGreeting: String) {
    self.greeting = newGreeting
  }

  pub resource interface IGreeting {
    pub var favouriteFood: String
  }

  // ERROR: resource `HelloWorld.Greeting` is missing a declaration to 
  // required conformance to resource interface `IHelloWorld.IGreeting`
  pub resource Greeting: IGreeting {
    pub var favouriteFood: String

    init() {
      self.favouriteFood = "Chocolate chip pancakes." // soooooo good
    }
  }

  init() {
    self.greeting = "Hello, Jacob!"
  }
}
```

我们会得到一个错误。原因是因为我们的合约接口明确说明我们的Greeting资源必须实现`IHelloWorld.IGreeting`接口，而不是其他人定义的`IGreeting`接口。合约应该是：

```javascript
import IHelloWorld from 0x01
pub contract HelloWorld: IHelloWorld {
  pub var greeting: String
  
  pub fun changeGreeting(newGreeting: String) {
    self.greeting = newGreeting
  }

  pub resource Greeting: IHelloWorld.IGreeting {
    pub var favouriteFood: String

    init() {
      self.favouriteFood = "Chocolate chip pancakes." // soooooo good
    }
  }

  init() {
    self.greeting = "Hello, Jacob!"
  }
}
```

现在都正确了:)

**注意：如果合约接口定义了资源接口，实现合约时不需要再次定义该资源接口。**

## 标准合约接口

<img src="../images/nftpicforcourse.png" />

合约接口允许你在实现合约上指定一些要求，此外，还可以为某些合约的外观创建“标准”。

如果我们可以在不实际阅读其代码的情况下将合约合理化为“NFT 合约”，这不是很有帮助吗？好吧，它已经存在了！`NonFungibleToken` 合约接口（也称为 `NonFungibleToken` 标准）是定义 NFT 合约必须实现的合约接口。这很有帮助，因此像 Marketplace DApp 这样的客户可以了解他们正在查看的内容，最重要的是，不必为每个 NFT 合约实现不同的功能。

标准化非常有益，因此使用多个合约的客户可以通过单一方式与所有这些合约进行交互。例如，所有 NFT 合约都有一个名为 Collection 的资源，该资源具有`deposit`和`withdraw`函数。这样，即使客户端 DApp 与 100 个 NFT 合约交互，它也只需要导入 `NonFungibleToken` 标准来调用这些函数，因为它们都属于一种通用类型。

你可以在这里了解更多的信息：https://github.com/onflow/flow-nft

## 总结

合约接口与资源接口非常相似，因为它们要求您实现某些事情并允许您对允许执行的操作实施严格的限制。此外，它们允许您设置“标准”，这对于合理化或确保合约符合我的要求非常有帮助。

巧合的是，合约接口（在我看来）是 Flow 上争论最激烈的话题。这是因为，例如，`NonFungibleToken` 合约接口（定义在这里：https://github.com/onflow/flow-nft/blob/master/contracts/NonFungibleToken.cdc ）相对较旧。如果你在 Flow Discord中，你会看到我们不停地争论它；）

## 作业

1. 解释为什么标准对 Flow 生态系统有益。

2. 你最喜欢什么食物？

3. 请修复下面的代码（提示：有两处错误）：

The contract interface:
```javascript
pub contract interface ITest {
  pub var number: Int
  
  pub fun updateNumber(newNumber: Int) {
    pre {
      newNumber >= 0: "We don't like negative numbers for some reason. We're mean."
    }
    post {
      self.number == newNumber: "Didn't update the number to be the new number."
    }
  }

  pub resource interface IStuff {
    pub var favouriteActivity: String
  }

  pub resource Stuff {
    pub var favouriteActivity: String
  }
}
```

The implementing contract:
```javascript
pub contract Test {
  pub var number: Int
  
  pub fun updateNumber(newNumber: Int) {
    self.number = 5
  }

  pub resource interface IStuff {
    pub var favouriteActivity: String
  }

  pub resource Stuff: IStuff {
    pub var favouriteActivity: String

    init() {
      self.favouriteActivity = "Playing League of Legends."
    }
  }

  init() {
    self.number = 0
  }
}
```