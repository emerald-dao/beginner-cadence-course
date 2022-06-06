# 第 4 章第 2 天 - 能力

在昨天的章节中，我们谈到/storage/了账户的存储路径。今天我们将讨论/public/和/private/路径，以及什么是能力。

注意：本章可能会非常混乱。如果你一路迷路，我会给你一个虚拟的大大的拥抱。我保证，如果你读了几遍，你最终会明白的。

## Video

你可以从14:45看这个视频到最后（我们最后一天看了上半场）：https ://www.youtube.com/watch?v=01zvWVoDKmU

## 昨天的回顾

<img src="../images/accountstorage1.PNG" />

快速回顾：

1./storage/只有账户主人能直接访问。我们用.save()，.load()和.borrow()函数来与其交互。

2./public/每个人都可以访问。

3./private/只有账户主人和被账户主人赋权的用户可以访问。

这一章内容我们继续沿用上一章的合约代码：


```javascript
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

并且我们通过以下代码已经将资源存入了用户存储空间中：

```javascript
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

好的，我们准备好了。


## `/public/` path

在之前，当我们往账户存储中保存了一些东西之后，只有账户主人可以访问它，这是因为它被保存到了/storage/路径下。但如果我希望其他人能够读取我资源中的name字段该怎么实现呢？你可能已经猜到了，让我们通过如下代码使资源可以被大家访问把。

```javascript 
import Stuff from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // Links our resource to the public so other people can now access it
    signer.link<&Stuff.Test>(/public/MyTestResource, target: /storage/MyTestResource)
  }

  execute {

  }
}
```

在上面这个例子中，我们使用.link()函数来将我们的资源“链接”到/public/路径下。简单来说，我们从/storage/MyTestResource取来了这样资源，并暴露了一个资源引用（&Stuff.Test）给公众，这样任何人便可以通过这一引用来读取它。

.link()的调用需要两个输入参数：

1.一个/public/或/private/路径

2.一个指向你需要链接的数据的/storage/路径

现在所有人都可以通过运行一个脚本（script）来读取我们资源中的name字段了。后面会教你如何具体编写这一脚本，不过在此之前我们需要为你介绍一些其他知识点。

## Capabilities

当你将一些数据链接到/public/或/private/路径时，实际上你是创建了一个叫做capability的东西。/public/或/private/路径并没有真正地存放任何数据，它们实际上还是被保存在/storage/中。然而，我们可以把capabilities看作是像指针一样的东西，它从一个/public/或/private/路径指向了与其相关联的/storage/路径。下面这个框图可能有助于你进一步理解这一点：

<img src="../images/capabilities.PNG" />

在Cadence编程中非常炫的一个特点就是你可以对/public/或/private/路径下的capabilities的可用性进行自定义的某些约束，这样就可以限制除你以外的其它人可以对这些资源进行哪些操作，又或者不能进行哪些操作。

## `PublicAccount` vs. `AuthAccount`

前面提到过使用AuthAccount使你可以对该账户进行任何操作；另一方面，使用PublicAccount可以获得读取权限，从而读取账户主人暴露出来的所有数据内容。你可以通过使用getAccount函数来获得一个PublicAccount类型：

```javascript
let account: PublicAccount = getAccount(0x1)
// `account` now holds the PublicAccount of address 0x1
```

值得注意的是，使用PublicAccount是唯一获得/public/中capability的途径；另一方面，AuthAccount是唯一获得/private/中capability的途径。

##  回到 `/public/`

好的，我们已经把我们的资源链接到/public/中了，接下来我们写一个脚本来读取它：

```javascript
import Stuff from 0x01
pub fun main(address: Address): String {
  // gets the public capability that is pointing to a `&Stuff.Test` type
  let publicCapability: Capability<&Stuff.Test> =
    getAccount(address).getCapability<&Stuff.Test>(/public/MyTestResource)

  // Borrow the `&Stuff.Test` from the public capability
  let testResource: &Stuff.Test = publicCapability.borrow() ?? panic("The capability doesn't exist or you did not specify the right type when you got the capability.")

  return testResource.name // "Jacob"
}
```

上面代码中我们从/public/路径中读取了资源的name字段，步骤如下：

1.获得地址的PublicAccount：getAccount(address)

2.从/public/MyTestResource路径下获取指向&Stuff.Test类型的capability：getCapability<&Stuff.Test>(/public/MyTestResource)

3.从capability中借来真正的资源引用：let testResource: &Stuff.Test = publicCapability.borrow() ?? panic("The capability is invalid")

4.返回name字段：return testResource.name

你可能在疑惑，为啥我们在调用.borrow()时不需要指定引用类型呢？这是因为&Stuff.Test类型已经在capability中指定了，因此它默认返回该类型的引用。如果你尝试取借用其他引用类型，或者之前获取的capability直接就不存在，则会返回nil或者报错。

## 使用公共Capability来约束类型

OK，那么我们接下来这个主题就是搞明白如何对资源引用的一部分进行约束，使其他人不能对我们的数据为所欲为！

下面再定义一个合约：

```javascript
pub contract Stuff {

  pub resource Test {
    pub var name: String

    pub fun changeName(newName: String) {
      self.name = newName
    }

    init() {
      self.name = "Jacob"
    }
  }

  pub fun createTest(): @Test {
    return <- create Test()
  }

}
```

其中，我们添加了一个changeName函数用来改变资源的name字段。那么假如我们不希望其他人能够调用这个函数该咋办呢？

```javascript
import Stuff from 0x01
transaction(address: Address) {

  prepare(signer: AuthAccount) {

  }

  execute {
    let publicCapability: Capability<&Stuff.Test> =
      getAccount(address).getCapability<&Stuff.Test>(/public/MyTestResource)

    let testResource: &Stuff.Test = publicCapability.borrow() ?? panic("The capability doesn't exist or you did not specify the right type when you got the capability.")

    testResource.changeName(newName: "Sarah") // THIS IS A SECURITY PROBLEM!!!!!!!!!
  }
}
```

发现上述代码中的问题了么？由于我们将资源链接到了/public/，任何人都可以调用callName函数来改变name字段。这显然不是我们想要的！

解决这个问题的手段是：

1.定义了一个只暴露了name字段出来的资源接口（Interface），但不暴露changeName函数

2.当我们用.link()函数将资源连接到/public/路径时，我们使用上一步中的定义的接口来引用这个资源

接下来让我们在合约中添加这个资源接口：

```javascript
pub contract Stuff {

  pub resource interface ITest {
    pub var name: String
  }

  // `Test` now implements `ITest`
  pub resource Test: ITest {
    pub var name: String

    pub fun changeName(newName: String) {
      self.name = newName
    }

    init() {
      self.name = "Jacob"
    }
  }

  pub fun createTest(): @Test {
    return <- create Test()
  }

}
```

好的，现在我们编写了一个Test资源的接口ITest，通过这个接口你只能访问资源中的name字段。接下来我们将我们的资源链接到/public/中：

```javascript 
import Stuff from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // Save the resource to account storage
    signer.save(<- Stuff.createTest(), to: /storage/MyTestResource)

    // See what I did here? I only linked `&Stuff.Test{Stuff.ITest}`, NOT `&Stuff.Test`.
    // Now the public only has access to the things in `Stuff.ITest`.
    signer.link<&Stuff.Test{Stuff.ITest}>(/public/MyTestResource, target: /storage/MyTestResource)
  }

  execute {

  }
}
```

现在我们尝试访问一下这个引用：

```javascript
import Stuff from 0x01
transaction(address: Address) {
  prepare(signer: AuthAccount) {

  }

  execute {
    let publicCapability: Capability<&Stuff.Test> =
      getAccount(address).getCapability<&Stuff.Test>(/public/MyTestResource)

    // ERROR: "The capability doesn't exist or you did not 
    // specify the right type when you got the capability."
    let testResource: &Stuff.Test = publicCapability.borrow() ?? panic("The capability doesn't exist or you did not specify the right type when you got the capability.")

    testResource.changeName(newName: "Sarah")
  }
}
```

EMMM，报了个错误！因为我们尝试取借来&Stuff.Test引用，但我们前面只把&Stuff.Test{Stuff.ITest}链接到了/public/，也就是我们只能访问到资源接口的引用。

那再试试看下面这段代码呢：

```javascript
import Stuff from 0x01
transaction(address: Address) {

  prepare(signer: AuthAccount) {

  }

  execute {
    let publicCapability: Capability<&Stuff.Test{Stuff.ITest}> =
      getAccount(address).getCapability<&Stuff.Test{Stuff.ITest}>(/public/MyTestResource)

    // This works...
    let testResource: &Stuff.Test{Stuff.ITest} = publicCapability.borrow() ?? panic("The capability doesn't exist or you did not specify the right type when you got the capability.")

    // ERROR: "Member of restricted type is not accessible: changeName"
    testResource.changeName(newName: "Sarah")
  }
}
```

诶呀，又报错了！尽管这回我们借用的是正确的类型了（资源接口引用），但我们不能调用changeName函数，因为这个函数并没有被暴露在这个ITest接口中。

好了，下面这段代码绝对可以了：

```javascript
import Stuff from 0x01
pub fun main(address: Address): String {
  let publicCapability: Capability<&Stuff.Test{Stuff.ITest}> =
    getAccount(address).getCapability<&Stuff.Test{Stuff.ITest}>(/public/MyTestResource)

  let testResource: &Stuff.Test{Stuff.ITest} = publicCapability.borrow() ?? panic("The capability doesn't exist or you did not specify the right type when you got the capability.")

  // This works because `name` is in `&Stuff.Test{Stuff.ITest}`
  return testResource.name
}
```

果然，这回终于对了！

## 结论


可能大家注意到了，我们并没有深入讨论/private/相关的内容。这是由于在实际操作中，/private/路径确实很少使用到，我们就不把问题搞得那么复杂了！

而且，嗯……我饿了。所以我要去吃饭了。也许我稍后会将它添加到本章中；）


## 任务

请用您选择的语言回答。

1. `.link()` 是干什么的?

2. 用你自己的话（没有代码），解释我们如何使用资源接口只向/public/路径公开某些东西.

3. 部署包含实现资源接口的资源的合约。然后，执行以下操作：

    1) 在交易中，将资源保存到存储中，并通过限制性接口将其链接到公共. 

    2) 运行一个脚本，尝试访问资源界面中未公开的字段，并看到错误弹出.

    3) 运行脚本并访问您可以读取的内容。从脚本中返回它.
