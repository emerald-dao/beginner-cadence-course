# 第4章 Day 1 - 账户存储

进行的还不错。我们完成了 3 个章节。但是还有很多事情要做；）让我们继续。

## 视频

观看这个视频到14:45: https://www.youtube.com/watch?v=01zvWVoDKmU

其余部分留到下一个章节看

## flow链上中的账户（Accounts）

在福洛链中，一个账户可以存储属于它自己的数据。也就是说，如果我在福洛链上拥有一个NFT（Non-Fungible Token，非同质化代币），它是被存储在我自己的账户中。这和其它很多区块链（比如以太坊）完全不同。在以太坊中，你的NFT是被存储在智能合约中的。而在福洛链中很酷的一点就是账户本身就能存储数据它们自己的数据。不过该如何访问账户中的数据呢？我们可以通过AuthAccount类型实现对账户数据的访问。每当有用户（比方说我或者你）发送一个交易（transaction），你需要为这笔交易支付交易费，同时你需要为这笔交易进行“签名”（sign）。“签名”这个操作口语化一些来解释就是，你单击一个按钮说：“嘿，我要通过这笔交易”。当你“签名”了这笔交易，它便可以获得你的AuthAccount参数并访问你账户中的数据。

上述过程是在交易中的prepare部分中进行的，而且这就是prepare函数存在的全部意义了——即访问你账户中的信息/数据。另一方面，你不能在execute部分进行这一操作，但你可以在execute部分中进行函数的调用等操作来改变区块链上的数据。注意，实际上你可以永远不使用execute，并把所有的代码都塞进prepare部分，但这会使得代码不那么易懂、可读。所有还是把这两个逻辑部分分开比较好。

 
## 账户中到底有些啥?

<img src="../images/accountstorage1.PNG" />

就如前面提到过的那样，福洛链上的账户可以真正意义上地存储数据自己的数据。这意味着如果我有一个NTF资源，我可以把它存在我的账户中，但具体来说到底是存储在哪里呢？

参考上图！我们来谈谈一个账户中都有些啥：

1.合约代码 – 部署到这个账户名下的合约，注意一个账户名下可以有多个合约

2.账户存储 – 你的数据都保持在账户存储中

## 账户存储

那么什么是账户存储呢？你可以把账户存储理解成一个数据容器，其存储路径为/storage/。在一个福洛链账户中，可以从三个路径获取特定的数据：

1./storage/ - 只有账户的主人能访问（还好还好，不然其他人就能随便偷取你所有的数据了）。所有你的数据都保存在这。

2./public/ - 所有人都可以访问

3./private/ - 账户主人和主人给予了访问权的人可以访问

必须要牢记的一点是只有账户的主人可以访问/storage/，但如果有需要，他可以选择把数据放进/public/和/private/。比方说，如我我想把自己的NTF拿给你看，我可以放一个可读版的NFT到/public/路径下，这样可以严格约束其他人能“看“到我的NFT，但不能把它从我的账户中取走。

提示：你有没有意识到资源接口（Resource Interface）在这里可能起到的作用？

你可能在想：“唔，那我该怎么访问我自己的/storage/呢？”答案就是你的AuthAccount类型。如果你还记得的话，当你签字了一笔交易，签名人的AuthAccount被作为参数输入prepare部分，如下所示：

```cadence
transaction() {
  prepare(signer: AuthAccount) {
    // We can access the signer's /storage/ path here!
  }

  execute {

  }
}
```

从以上代码可以看到，我们可以在prepare部分访问签名人的/storage/。这意味着我们可以对签名人的账户做任何事情。

## 保持和加载函数

来练习一下在账户中保存些什么吧。首先定义一个合约：

```cadence
pub contract Stuff {

  pub resource Test {
    pub var name: String
    init() {
      self.name = "Jacob"
    }
  }

  pub fun createTest(): @Test {
    return <- create Test()
  }

}
```

我们定义了一个简单的合约，提供了一个允许你创建并返回一个@Test资源的方法。让我们在交易中调用这个合约：

```cadence
import Stuff from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    let testResource <- Stuff.createTest()
    destroy testResource
  }

  execute {

  }
}
```

这个交易中我们创建了一个@Test资源，然后销毁了它。那如果我们想把它保存在我们的账户中该怎么做呢？来看一下下面一段代码。

```cadence
import Stuff from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    let testResource <- Stuff.createTest()
    signer.save(<- testResource, to: /storage/MyTestResource) 
    // saves `testResource` to my account storage at this path:
    // /storage/MyTestResource
  }

  execute {

  }
}
```

首先我们需要有一个AcuthAccount来保存@Test资源，对应上面这个例子中signer变量。然后我们便可以调用signer.save(…)来将资源保存到/storage/目录中。

.save()的调用需要两个输入参数：

1.实际要保存的数据

2.一个“to”参数来指定要保存的路径（必须是一个/storage/开头的路径）

在上面例子中，我们把testResource资源（注意使用了<-标志）保存到了/storage/MyTestResource路径。那么现在，我们可以随时去该路径取用这个资源：

```cadence
import Stuff from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    let testResource <- signer.load<@Stuff.Test>(from: /storage/MyTestResource)
    // takes `testResource` out of my account storage

    destroy testResource
  }

  execute {

  }
}
```
在上面代码例子中，我们使用.load()函数来从账户存储中取回数据。

你可能注意到了一个怪东西：<@Stuff.Test>。当年你和某个账户存储互动的时候，你必须指定你在寻找的数据的类型。Cadence并不知道在存储路径下存储着一个@Stuff.Test资源。但作为编程者的我们是知道的，因此我们加上<@Stuff.Test>告诉程序我们想从存储路径下取出一个@Stuff.Test资源。

.load()的调用需要一个输入参数：

1.指定从哪里取用数据的“from”参数

需要注意的一点是，当你从存储中取用数据时，它返回的是一个不定项（optional）！所以testResource实际上是一个“@Stuff.Test?”类型的数据。返回不定项的原因是Cadence并不知道你取用的数据是不是真的存在，或者你提供的数据类型是不是真的正确。所以如果你使用了错误的存储路径，调用返回nil。请看下面这个例子：

```cadence
import Stuff from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    let testResource <- signer.load<@Stuff.Test>(from: /storage/MyTestResource)
    log(testResource.name) // ERROR: "value of type `Stuff.Test?` has no member `name`."

    destroy testResource
  }

  execute {

  }
}
```

看？它是可选的。要解决此问题，我们可以使用panic或!运算符。我喜欢使用panic，因为您可以指定错误消息。


```cadence
import Stuff from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    let testResource <- signer.load<@Stuff.Test>(from: /storage/MyTestResource)
                          ?? panic("A `@Stuff.Test` resource does not live here.")
    log(testResource.name) // "Jacob"

    destroy testResource
  }

  execute {

  }
}
```

## Borrow 函数

前面提到了如何往账户里保存数据或提取数据。但如果我们只是想查看一下账户中的某些数据呢？这就需要用到引用（references）和.borrow()函数了。

```cadence 
import Stuff from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // NOTICE: This gets a `&Stuff.Test`, not a `@Stuff.Test`
    let testResource = signer.borrow<&Stuff.Test>(from: /storage/MyTestResource)
                          ?? panic("A `@Stuff.Test` resource does not live here.")
    log(testResource.name) // "Jacob"
  }

  execute {

  }
}
```
你会发现我们通过borrow函数从存储中借来了一个指向资源的引用（而不是资源本身）。这也是我们标注类型为<&Stuff.Test>而不是<@Stuff.Test>的原因。

.load()的调用需要一个输入参数：

1.指定从哪里借来数据引用的“from”参数

注意，由于我们没有使用.load()函数，资源在整个过程中依旧原封不动地呆在账户存储中。

## 结论

再来看一次下面这幅图：

<img src="../images/accountstorage1.PNG" />

现在你应该能理解什么是/storage/了，下一章我们会来讨论一下/public/和/private/路径。

## 任务

1. 解释帐户内部的内容。

2. /storage/、/public/和/private/路径之间有什么区别？

3. .save()的作用？load()的作用？.borrow()的作用？

4. 解释为什么我们不能将某些内容保存到脚本内的帐户存储中。

5. 解释为什么我无法将某些内容保存到您的帐户中。

6. 定义一个合同，该合同返回一个至少包含 1 个字段的资源。然后，编写 2 个事务：

    1) 首先将资源保存到帐户存储，然后将其从帐户存储中加载，记录资源内的字段并销毁它的事务。

    2) 首先将资源保存到帐户存储，然后借用对它的引用，并在资源中记录一个字段的事务。
