# Chapter 3 Day 4 - 资源/结构与接口


哟哟哟哟哟！我们又回来玩 Cadence 了。今天我们将学习资源接口。

## 视频

如果你想看相关的视频内容，请点击这里: https://www.youtube.com/watch?v=5wnn9qsCXgE

## 接口是什么


接口在传统编程语言中非常常见。接口有两个主要用途：
1. 它规定了要实现的一系列要求
2. 它只允许你把某些东西暴露给某些人

让我们看一些代码来理解我的意思。

<img src="../images/interfaces.png" />

## 使用接口作描述需求

在这一课中，我将只使用资源接口，然而，**结构接口是完全相同的东西，只适用于结构**。哈哈，记住这一点。
在 Cadence 中，资源/结构接口本质上是 “需求”，即从资源/结构中公开数据的方式。接口本身不起任何作用。他们就坐在那里。但当它们被“应用”到资源/结构时，就是它们做某事的时候。

资源接口是用 `resource interface` 关键字定义的（对于结构，它是 `struct interface`）：

```cadence
pub contract Stuff {

    pub resource interface ITest {

    }

    pub resource Test {
      init() {
      }
    }
}
```

在上面的例子中，你可以看到我们做了两件事：
1.我们定义了一个名为 `ITest` 的空 `resource interface`。
2.我们定义了一个名为 `Test` 的空 `resource`。
就我个人而言，我总是用前面的 “I” 来命名接口，因为这有助于我确定它实际上是什么。
在上面的例子中，`ITest` 实际上什么都不做。只是坐在那里。让我们给它添加一些东西。

```cadence
pub contract Stuff {

    pub resource interface ITest {
      pub let name: String
    }

    pub resource Test {
      init() {
      }
    }
}
```

现在，`ITest` 包含一个 `name` 字段。酷！但 ITest 仍然什么都没做。它只是坐在哪里。那么让我们让 `Test` *实现* `ITest` 资源接口。

```cadence
pub contract Stuff {

    pub resource interface ITest {
      pub let name: String
    }

    // ERROR: 
    // `资源 Stuff.Test 会报错
    // 缺少了Stuff.ITest` 中的 name 字段
    pub resource Test: ITest {
      init() {

      }
    }
}
```

注意我们刚才做了什么。我们通过添加 `: ITest` 语法使 `Test` 实现了 `ITest`。这意味着，“此资源在 `:` 之后实现资源接口”。
但你会注意到有一个错误：“resource Stuff.Test 不符合资源接口 Stuff.ITest”。还记得我们上面说的吗？资源接口是 *需求*。
如果资源实现了资源接口，那么它必须定义接口中的内容。我们来修正它吧。

```cadence
pub contract Stuff {

    pub resource interface ITest {
      pub let name: String
    }

    // It's good now :)
    pub resource Test: ITest {
      pub let name: String
      init() {
        self.name = "Spongebob" // 还有谁喜欢海绵宝宝?
      }
    }
}
```

现在没有错误了！哇哦！

## 使用接口公开特定内容

在上面的文章中，我们了解到资源接口使资源实现某些事情。但资源接口实际上比这重要得多。还记得他们做的第二件事吗？我们说：“它只允许你把某些东西暴露给某些人。”。这就是他们强大的原因。让我们看看下面：

```cadence
pub contract Stuff {

    pub resource interface ITest {
      pub let name: String
    }

    pub resource Test: ITest {
      pub let name: String
      pub let number: Int
      init() {
        self.name = "Spongebob"
        self.number = 1
      }
    }

    pub fun noInterface() {
      let test: @Test <- create Test()
      log(test.number) // 1

      destroy test
    }

    pub fun yesInterface() {
      let test: @Test{ITest} <- create Test()
      log(test.number) // ERROR: `无法访问受限类型的成员：number`

      destroy test
    }
}
```

好吧，发生了什么事。发生了很多事情：
1. 我们制作了一个名为 `noInterface` 的函数。此函数创建一个新资源（类型为 `@Test`），并记录其 `number` 字段。这很好用。
2. 我们制作了一个名为 `yesInterface` 的函数。此函数创建一个新的资源， **该资源仅限于 `ITest` 接口**（类型为 `@Test{ITest}`），并尝试输出 `number` 字段，但失败。


在 Cadence 中，你可以使用 `{resource_INTERFACE}` 符号来“限制”资源的类型。你可以使用`{}`括号，并将资源接口的名称放在中间。这意味着：“这种类型是一种资源 **只能使用接口** 公开的东西。”如果你理解这一点，那么你就非常了解资源接口。

那么，为什么登录yesInterface失败了呢？这是因为 `ITest` 不暴露 `number` 字段！因此，如果我们将 `test` 变量键入为 `@Test{ITest}`，我们将无法访问它。

## 复杂的例子

下面是一个更复杂的示例，其中还包括函数：

```cadence
pub contract Stuff {

    pub resource interface ITest {
      pub var name: String
    }

    pub resource Test: ITest {
      pub var name: String
      pub var number: Int

      pub fun updateNumber(newNumber: Int): Int {
        self.number = newNumber
        return self.number // 返回 newNumber
      }

      init() {
        self.name = "Spongebob"
        self.number = 1
      }
    }

    pub fun noInterface() {
      let test: @Test <- create Test()
      test.updateNumber(newNumber: 5)
      log(test.number) // 5

      destroy test
    }

    pub fun yesInterface() {
      let test: @Test{ITest} <- create Test()
      let newNumber = test.updateNumber(newNumber: 5) // ERROR: `无法访问受限类型的成员：updateNumber`
      log(newNumber)

      destroy test
    }
}
```

我想给你们展示另一个例子，告诉你们你们也可以选择不公开函数。你能做的事情太多了！:D 如果我们想修复此代码，我们会：

```cadence
pub contract Stuff {

    pub resource interface ITest {
      pub var name: String
      pub var number: Int
      pub fun updateNumber(newNumber: Int): Int
    }

    pub resource Test: ITest {
      pub var name: String
      pub var number: Int

      pub fun updateNumber(newNumber: Int): Int {
        self.number = newNumber
        return self.number // 返回 newNumber
      }

      init() {
        self.name = "Spongebob"
        self.number = 1
      }
    }

    pub fun noInterface() {
      let test: @Test <- create Test()
      test.updateNumber(newNumber: 5)
      log(test.number) // 5

      destroy test
    }

    // Works totally fine now! :D
    pub fun yesInterface() {
      let test: @Test{ITest} <- create Test()
      let newNumber = test.updateNumber(newNumber: 5)
      log(newNumber) // 5

      destroy test
    }
}
```


请注意，当我将函数添加到 `ITest` 时，我只添加了函数定义：`pub fun updateNumber(newNumber: Int): Int`。不能在接口中实现函数，只能定义它。

## 结论

完成今天的内容做得很好。当我们在第 4 章开始讨论帐户存储时，资源接口将非常重要。

## 任务

1. 用你自己的话解释资源接口可以用来做的两件事（我们在今天的内容中讨论了这两件事）
2. 定义自己的合约。创建自己的资源接口和实现该接口的资源。创建两个函数。在第一个函数中，显示一个不限制资源类型和访问其内容的示例。在第二个函数中，显示限制资源类型且无法访问其内容的示例。

3. 我们将如何修复此代码？

```cadence
pub contract Stuff {

    pub struct interface ITest {
      pub var greeting: String
      pub var favouriteFruit: String
    }

    // ERROR:
    // `structure Stuff.Test does not conform 
    // to structure interface Stuff.ITest`
    pub struct Test: ITest {
      pub var greeting: String

      pub fun changeGreeting(newGreeting: String): String {
        self.greeting = newGreeting
        return self.greeting // returns the new greeting
      }

      init() {
        self.greeting = "Hello!"
      }
    }

    pub fun fixThis() {
      let test: Test{ITest} = Test()
      let newGreeting = test.changeGreeting(newGreeting: "Bonjour!") // ERROR HERE: `member of restricted type is not accessible: changeGreeting`
      log(newGreeting)
    }
}
```