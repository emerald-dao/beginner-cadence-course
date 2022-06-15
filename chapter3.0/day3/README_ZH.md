# Chapter 3 Day 3 - References

Flow 的小伙伴们，今天我们将要学习引用 —— Cadence 语言的另一个重要部分

## 视频

如果你想看相关的视频内容，请点击这里 : https://www.youtube.com/watch?v=mI3KC-5e81E

## 什么是引用

用最简单的术语来说，引用是一种与一段数据交互的方式，而实际上不必拥有该段数据。你可以马上想象这对资源有多大帮助。想象一下，在一个世界里，你不必为了查看或更新某个资源的字段而移动 1000 次。啊，那个世界确实存在！这里的引用是为了拯救这一天。

## Cadence 中的引用
在Cadence中，引用*几乎总是*用于结构或资源。引用字符串、数字或基本数据类型是没有意义的。但是，引用我们不想经常传递的东西肯定是合理的。

引用总是在前面使用 `&` 符号。让我们看一个例子：

```cadence
pub contract Test {

    pub var dictionaryOfGreetings: @{String: Greeting}

    pub resource Greeting {
        pub let language: String
        init(_language: String) {
            self.language = _language
        }
    }

    pub fun getReference(key: String): &Greeting {
        return (&self.dictionaryOfGreetings[key] as &Greeting?)!
    }

    init() {
        self.dictionaryOfGreetings <- {
            "Hello!": <- create Greeting(_language: "English"), 
            "Bonjour!": <- create Greeting(_language: "French")
        }
    }
}
```

在上面的示例中，您可以看到 `getReference` 返回一个 `Greeting` 类型，它的简单意思是对 `Greeting` 类型的引用, 在函数内部，发生了一些事情：
1.我们首先通过执行 `&self.dictionaryOfGreetings[key]` 来获取 `key`处的值的引用。
2.我们通过 `as &Greeting` 操作将引用类型转换


请注意，如果我们忘记了 `as &Greeting`，Cadence 会对我们大喊大叫，说"期待的转换表达式”这是因为在 Cadence 中，**在获得引用时必须进行转换**。类型转换是指你告诉 Cadence 你得到的引用值类型，这就是 `as &Greeting` 所做的。它的意思是 "获取此参考，这是一个 &Greeting 参考。" 否则，我们将中止该程序。

现在，您可能会想，“字典不返回可选类型吗？我们为什么不用一个 `!` 符号解封装 `&self.dictionaryOfGreetings[key]` 事实是，我们不必这么做。如果 `key` 处没有值，则可选项将无法转换成 `&Greeting` 类型。所以我们现在可以忽略可选案例。

现在我们可以获得引用，我们可以在事务或脚本中获得引用，如下所示：

```cadence
import Test from 0x01

pub fun main(): String {
  let ref = Test.getReference(key: "Hello!")
  return ref.language // returns "English"
}
```

请注意，我们不需要将资源移动到任何地方就可以做到这一点！这就是引用的美妙之处。

## 结论

引用没那么糟糕，对吧？主要有两点：
1.您可以使用引用获取信息，而无需移动资源。
2.获取引用时必须 “类型转换”，否则会收到错误。

不过，引用不会消失。当我们在下一章讨论帐户存储时，它们将非常重要。

## 任务

1. 定义一个存储了字典类型资源的合约，加一个函数以获取字典中某个资源的引用。

2. 创建一个脚本，使用第 1 部分中定义的函数中的引用从该资源读取信息。

3. 用自己的话解释为什么引用在Cadence中有用。
