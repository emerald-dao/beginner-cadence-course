# Chapter 5 Day 1 - 前置/后置条件和事件

今天，我们将学习2个概念，它们虽然很简单，但在Cadence中却很常见。

## 学习视频

Pre/Post Conditions (前置和后置条件): https://www.youtube.com/watch?v=WFqoCZY36b0

Events (事件): https://www.youtube.com/watch?v=xRHG6Kgkxpg

## 前置和后置条件

之前我们只学习了一种异常处理中止程序的方法：`panic`。`panic`是一个关键字，如果它被调用，会完全还原代码中发生的事情，并随之发送一条消息。例如:

```javascript
pub fun main(): String {
  let a: Int = 3

  if a == 3 {
    panic("This script will never work because it will always panic on this line.")
  }

  return "Will never get to this line."
}
```

这是一个愚蠢的例子，永远不会return，总是会调用`panic()`。

很多时候，我们希望以更清晰的方式处理错误，并实现一个称为“快速失败”的概念。在区块链上，操作非常昂贵，也需要支付昂贵的交易费用。“快速失败”是一种编程方式，这样如果出现问题，您的代码会尽快失败，这样您就不会无缘无故地浪费更多的执行时间。

Pre/Post 条件非常适合实现这一点。如果在调用函数之前（pre）或之后（post）出现问题，它们允许我们指定一种非常清晰的失败方式。例如:

```javascript
pub contract Test {

  pub fun logName(name: String) {
    pre {
      name.length > 0: "This name is too short."
    }
    log(name)
  }

}
```

在上面的例子中，我们在函数`logName`开始时定义了一个“前置条件”: “如果名称的长度不大于 0，则显示错误消息：'This name is too short.'”

前置条件和后置条件必须定义在函数最开始时，不能放在中间或末尾。为了使前置/后置条件通过，条件必须是`true`，否则它将`panic`与并报错后面的字符串。

后置条件是一样的，除了在函数的末尾检查它们（它们仍然必须在开始时定义。我知道，这很令人困惑，但你会习惯的）：

```javascript
pub contract Test {

  pub fun makePositiveResult(x: Int, y: Int): Int {
    post {
      result > 0: "The result is not positive."
    }
    return x + y
  }

}
```

您可能想知道：“这个`result`变量到底是什么？我们从未定义过它。” 是的！后置条件非常酷，因为它们已经默认带有一个`result`等于返回值的变量。因此，如果我们返回`x + y`,`result`将代表这它。如果没有返回值，result则不存在。

此外，您可以在后置条件中使用`before()`函数，在函数修改`self.number`之前访问`self.number`的值，即使值已经被修改过。

```javascript
pub contract Test {

  pub resource TestResource {
    pub var number: Int

    pub fun updateNumber() {
      post {
        before(self.number) == self.number - 1
      }
      self.number = self.number + 1
    }

    init() {
      self.number = 0
    }

  }

}
```

上面的代码将始终有效，因为满足后置条件。它说“在`updateNumber`函数运行后，确保更新的数字比函数运行前的值大 1。” 在这种情况下总是如此。

### Important Note

了解`panic`实际执行的操作或前置/后置条件非常重要。他们“中止”交易，这意味着实际上链上没有任何状态被改变。

例如:
```javascript
pub contract Test {

  pub resource TestResource {
    pub var number: Int

    pub fun updateNumber() {
      post {
        self.number == 1000: "Will always panic!" // when this panics after the function is run, `self.number` gets reset back to 0
      }
      self.number = self.number + 1
    }

    init() {
      self.number = 0
    }

  }

}
```

## 事件

事件是智能合约与外界沟通“某事发生”的一种方式。

例如，如果我们铸造 NFT，我们希望外界知道 NFT 被铸造了。当然，我们可以不断地检查合约，看看它是否`totalSupply`被更新或什么的，但这确实是低效的。为什么不让合约自己告诉我们？

以下是在 Cadence 中定义事件的方法：

```javascript
pub contract Test {

  // define an event here
  pub event NFTMinted(id: UInt64)

  pub resource NFT {
    pub let id: UInt64

    init() {
      self.id = self.uuid

      // broadcast the event to the outside world
      emit NFTMinted(id: self.id)
    }

  }

}
```

你可以看到我们定义了一个`NFTMinted`的事件：`pub event NFTMinted(id: UInt64)`. 请注意，事件总是`pub`/`access(all)`。然后我们使用关键字`emit`广播该事件，将其发送到区块链。

您还可以将参数传递给事件，以便向外界发送数据。在这种情况下，我们想告诉全世界一个具有特定 id 的 NFT 已被铸造，以便任何正在订阅我们事件的客户端都知道特定的 NFT 已被铸造。

这样做的目的是让客户（阅读我们合约的人）可以知道什么时候发生了什么事情，并相应地更新他们的代码。也许我们可以制作一个很酷的网站，每次铸造 NFT 时都会用我的脸来放烟花！:D

## 总结

这就是今天的全部内容！我希望你喜欢较短的课程。

## 作业

1. 描述什么是事件，以及为什么它非常有用。

2. 部署一个包含事件的合约，并在合约的其他地方发出事件，表明它发生了。

3. 使用步骤 2) 中的合约，在其中添加一些前置条件和后置条件，以习惯于将它们写出来。

4. 对于以下每个函数（`numberOne`、`numberTwo`、`numberThree`），请按照说明进行操作。

```javascript
pub contract Test {

  // TODO
  // 这里`log`函数是否会被执行？
  // name: 'Jacob'
  pub fun numberOne(name: String) {
    pre {
      name.length == 5: "This name is not cool enough."
    }
    log(name)
  }

  // TODO
  // 下面函数能正确返回吗？
  // name: 'Jacob'
  pub fun numberTwo(name: String): String {
    pre {
      name.length >= 0: "You must input a valid name."
    }
    post {
      result == "Jacob Tucker"
    }
    return name.concat(" Tucker")
  }

  pub resource TestResource {
    pub var number: Int

    // TODO
    // 下面函数能否正确的更新`self.number`变量？
    // 同时，`self.number`在执行之后的值是多少？
    pub fun numberThree(): Int {
      post {
        before(self.number) == result + 1
      }
      self.number = self.number + 1
      return self.number
    }

    init() {
      self.number = 0
    }

  }

}
```