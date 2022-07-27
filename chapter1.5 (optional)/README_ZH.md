# 第1.5节-基本计算机编程概念

这一节将会涵盖计算机编程的基础知识。如果你以前写过代码，这对你来说会很无聊，所以你可以跳过这一节。

![img](https://github.com/emerald-dao/beginner-cadence-course/raw/main/chapter1.5%20(optional)/images/programmingdiagram.png)

## 最重要的是

如果您正在阅读本节，则意味着您可能从未编写过代码，或者您想复习基础知识。

作为初学者，我能告诉你的最重要的事情是，计算机科学最难的部分是学习如何像程序员一样思考。通常，难的不是编程本身，而是训练自己像一个高效的程序员那样思考，以编写好的程序。这是不管别人怎么告诉你都教不出来的。玩代码并耐心地真正掌握该技能取决于您。

因此，如果您发现自己感到痛苦，我完全理解！我也是。但是真正学习它的唯一方法是搞砸很多并自己找出错误。这比在线观看教程或阅读文章对您更有帮助。

让我们开始学习吧！

## 编程

![img](https://github.com/emerald-dao/beginner-cadence-course/raw/main/chapter1.5%20(optional)/images/programming.png)

什么是编程？什么是写代码？

通俗的讲，程序只是你在屏幕上键入的一堆数字和字母，它们可以做一些事情。例如，如果我想编写一个程序，每次单击按钮时都对我说“早安”，我可以做到！

为了使程序正常工作，您需要使用一种称为“语法”的东西。每种编程语言都有不同的语法，可让您与计算机进行通信。对于这个训练营，您将使用 Cadence 编程语言提供的语法，但您可能听说过其他语言，如 Javascript、Python、C++、HTML、CSS 等。

## 如何告诉计算机去做什么

那么，我们如何真正告诉计算机该做什么呢？

我们必须使用计算机想要的语法。因此，在 Cadence 中，有很多东西是为我们预定义的，可以让我们与计算机以及一般的区块链进行交互。

### 函数

当您编写程序时，总是有很多有用的工具可以帮助您做您想做的事。例如，我们可以使用称为`函数`的东西在调用时执行一段代码。

在Cadence中最基础的函数就是`log`，作用是让屏幕打印出来方便我们阅读，你可以像下面这样写:

```cadence
log("Hello, idiot!")
```

看看我们做了什么？我们写了`log`，后面跟着一组括号。函数总是接受被称为`参数`的东西，这些东西被放入函数中，它知道要做什么。如果我们要执行那个程序，它会说，"Hello,idiot!"，这正是我们想要的。 

让我们看看我用Cadence写的例子

![img](https://github.com/emerald-dao/beginner-cadence-course/raw/main/chapter1.5%20(optional)/images/hello.png)

您可以在那里看到中间的log语句。但它周围是什么？嘿，这是另一个函数！但这一次，我们必须自己定义函数。 log 已经存在于语言中，它是语法的一部分。但是main函数是我自己写的。你不用担心我是怎么做到的，只要知道程序启动时函数 main 会被执行。它将打印"Hello there!"，像这样:

![img](https://github.com/emerald-dao/beginner-cadence-course/raw/main/chapter1.5%20(optional)/images/hello_there.png)

您可以访问 https://play.onflow.org 并在左侧的“脚本”选项卡中键入相同的代码

https://play.onflow.org 是您在 Cadence 中编写程序的“游乐场”。此外，Script选项卡是我们可以编写一些简单程序来测试我们理解的地方。

### 变量

实话说，变量比函数更简单，函数允许您执行一些逻辑，变量就是在其中存储数据

您可以将变量视为在某个时间点保存一段数据。您可以更改变量表示的内容（如果允许），使其指向其他内容。这是一个例子：

![img](https://github.com/emerald-dao/beginner-cadence-course/raw/main/chapter1.5%20(optional)/images/x.png)

在这个例子下，`x` 是一个变量。在第 2 行，您可以看到我们通过var x = 5声明它。这是说“我想创建一个名为 x 的变量来存储值 5”的 Cadence 方式。

在程序开始时，`x` 的值是 5，它是一个数字。在我们log它之后，我们将 x 改为 3，然后我们也log它。您可以在底部看到正在log的值。

### 类型

在 Cadence（和大多数其他编程语言）中，所有东西都有一种叫做“类型”的东西。类型是事物是什么类型的更广泛的表示。例如，5 是一个数字。但是，“Hello World”是一段文本。我们如何区分这两者？

在 Cadence 中，我们称一个数字为“Integer”。更具体地说，它是 Int 类型。但是，我们将文本称为“String”，也称为字符串。这是一个例子：

```cadence
let x: Int = 5
let text: String = "Hello idiot"
```

您可以在[此处](https://docs.onflow.org/cadence/language/values-and-types/)查看不同类型的变量。不用担心，我们稍后会了解这一切。

这是一个错误的例子：

```cadence
let x: String = 5 // WRONG
let y: String = "5" // GOOD
```

确定你没有被不同的类型混淆。"5"是String类型，但是5时Int类型。

在 Cadence 中，您会看到许多不同的类型。例如，UInt64 是“0 到 18,446,744,073,709,551,615 之间的正数”的一种说法。随着时间的推移你会习惯的

### 写我们自己的函数

让我们想出一个例子并写我们自己的函数去检验我们对之前东西的理解

打开 [Flow playground](https://play.onflow.org/) 并去Script 栏。让我们这样开始：

![img](https://github.com/emerald-dao/beginner-cadence-course/raw/main/chapter1.5%20(optional)/images/step1.png)

好棒！所有我们做的就是把变量x表示数字5

现在让我们添加我们自己的函数并调用它。

![img](https://github.com/emerald-dao/beginner-cadence-course/raw/main/chapter1.5%20(optional)/images/step2.png)

哇，我们写了很多行。让我们一步一步看一下：

1. 在第6行，我们定义了我们自己的函数`myFunction`。记住，一个函数是当你调用时它会做某些事。
2. 注意myFunction接受一个参数：一个Int类型的叫做number的参数。
3. 在第7行，我们把number打印到控制台。
4. 在第3行，我们调用myFunction让它执行我们写的操作。

当你点击`Execute`的时候，你将会看到：

![img](https://github.com/emerald-dao/beginner-cadence-course/raw/main/chapter1.5%20(optional)/images/result.png)

棒！我们得到我们期待的答案。

注意如果我们没有写第3行，myFunction将不会被调用，我们也不会在控制台中log出number

我们可以稍微改变我们的代码让控制台log不同的数字：

![img](https://github.com/emerald-dao/beginner-cadence-course/raw/main/chapter1.5%20(optional)/images/newresult.png)

在这个例子中，我们定义了三个不同的变量：`x`，`y`，和`z`，它们表示不同的值。我们把它们传入myFunction让控制台打印出来。

### 为什么我们要写函数？

您将开始注意到函数有助于编写一些我们可能想要多次执行的代码。它使我们不必一遍又一遍地编写代码。例如，让我们看一下这段代码：

![img](https://github.com/emerald-dao/beginner-cadence-course/raw/main/chapter1.5%20(optional)/images/nofunction.png)

在这个例子中，我们定义了两个变量`greeting`和`person`来储存信息。然后，我们使用Cadence中预定义的`concat`函数去将两段信息结合起来。然后打印到控制台

这很好，但是当我们想要多次这样做时会发生什么，用不同的greeting和person呢？

![img](https://github.com/emerald-dao/beginner-cadence-course/raw/main/chapter1.5%20(optional)/images/long.png)

好吧，这需要写很多行代码。这个问题是什么呢？

问题是我们不断地编写相同的代码，将两段文本组合在一起。为什么一遍又一遍地重写相同的逻辑？有没有办法让这件事变得更容易？还是让我们只需要编写一次该逻辑，然后多次使用它？当然！让我们使用一个函数：

![img](https://github.com/emerald-dao/beginner-cadence-course/raw/main/chapter1.5%20(optional)/images/better.png)

在这个例子中，我们定义了一个叫做`combine`的函数，执行下列的动作：

1. 输入两段信息
2. 使用预定义的`concat`函数把它们拼接起来
3. 在控制台中打印出来

这个目的是什么呢？好吧，既然我们编写了 combine 函数，我们就不必多次更新我们的 newMessage 并不断地合并两段文本。现在，我们可以直接调用 combine 为我们做这件事！

现在创建一个函数可能看起来并没有什么好处，但是如果我们有更复杂的代码并且重复很多次，你可以通过创建一个函数来节省大量的编码时间。

### 函数和返回值

我要提到的最后一件事是函数也可以返回一些信息。让我们看一个例子：

![img](https://github.com/emerald-dao/beginner-cadence-course/raw/main/chapter1.5%20(optional)/images/add.png)

在这个例子中，我们定义了一个名为 `add` 的函数，它接受 2 个Int类型的数字，将它们相加，然后返回。第 12 行的 ": Int" ，这意味着“这个函数返回一个整数”。

你能看到例子中的第2行我们设置的answer等于add函数返回的结果。

## 结论

我想向您展示计算机编程的基础知识，但是我能做的只有这么多。

说真的，如果你想了解更多关于基本计算机编程概念的知识，或者你在本节中遇到困难，我建议你在网上查找 YouTube 教程。然而，真正学习的唯一方法是自己多写代码。我向你保证，你永远不会仅仅通过阅读/观看视频来提高。你必须自己尝试一下！

这就是这节课的所有内容，享受这节课吧！
