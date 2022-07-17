# 第三章 第二天 - 在Dictionary和数组Array中的Resource

在第二章中，我们学过Dictionary和数组Array，今天我们来学习如果把resource应用到Dictionary和Array中区。我们单独使用他们的时候，也许还不难，但我们把他们弄到一起时，就会有点复杂了。

## 视频
你可以从08：00一直看到最后（我们昨天讨论了前半部分）: https://www.youtube.com/watch?v=SGa2mnDFafc

## 为什么是Dictionaries & Arrays?

首先，我们为什么要讨论Dictionary中的resource，而不是structs中的resource呢？因为，首先你要知道，*你不能在struct中存储resource*。虽然struct是一个数据的容器，但我们不能把resource放在里面。

那我们能在哪里存储resource呢？
1. 在dictionary或者array中
2. 在另外一个resource中
3. 一个合约的状态变量
4. 在账户的存储空间中 (我们稍后会讨论)

就是这样，今天我们会讨论第一点。

## Arrays数组中的resource

通过示例还学习总是很好的，我们来打开一个Flow playground，并在Chapter 3 Day 1中部署这个合约。

```cadence
pub contract Test {

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

}
```

到此为止，我们有了1个 `@Greeting`类型的resource。现在我们试着创建一个状态变量，把一列 Greetings 存储在一个数组array里。


```cadence
pub contract Test {

    pub var arrayOfGreetings: @[Greeting]

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    init() {
        self.arrayOfGreetings <- []
    }

}
```

请注意这个 `arrayOfGreetings`: `@[Greeting]` 类型。我们昨天学到resource在开头必须有 `@` 符号。这在包含resource的数组中也同样适用，你需要在开头加入 `@` 来告知Cadence这是一个包含resources的数组。并且，这个 `@` 必须是在括号外的，不是里面。

`[@Greeting]` - 错误

`@[Greeting]` - 正确

同时请注意，在 `init` 函数中，我们是用 `<-` 运算符来初始化它的，而不是 `=`。再一次的，当我们处理resource的时候（不管是单纯的一个resource，还是在Dictionary中，或者array中），我们必须使用 `<-`。 

### 加入到数组中

好的，现在我们创建了我们的自己的resource数组。现在我们来看一下我们怎么才能把resource加到数组中。

*请注意：今天我们将会以变量的形式把resource传入到我们的函数中。也就是说我们不关心resource是如何被创建的，我们只是用一些例子来展示如何把resource加入到array和Dictionary中*

```cadence
pub contract Test {

    pub var arrayOfGreetings: @[Greeting]

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    pub fun addGreeting(greeting: @Greeting) {
        self.arrayOfGreetings.append(<- greeting)
    }

    init() {
        self.arrayOfGreetings <- []
    }

}
```

在这个例子中，我们添加了一个我 `addGreeting` 函数，把传入的 `@Greeting` 通过 `append` 函数添加到array中。很简单，对吧？ 这和我们平时如何加入array是一样的，只是我们是用的 `<-` 运算符把resource “移动” 到array中。


### 从Array中删除

好的，我们知道了如何加入到数组中。我们来看一下如何从数组中删除resource

```cadence
pub contract Test {

    pub var arrayOfGreetings: @[Greeting]

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    pub fun addGreeting(greeting: @Greeting) {
        self.arrayOfGreetings.append(<- greeting)
    }

    pub fun removeGreeting(index: Int): @Greeting {
        return <- self.arrayOfGreetings.remove(at: index)
    }

    init() {
        self.arrayOfGreetings <- []
    }

}
```

还是那么简单直接。在一个通常的数组中，我们会用 `remove` 函数来把某一个元素取出来。在处理resource时也同样适用，唯一的区别就是我们要用 `<-` 运算符来把resource从数组中取出。

## Dictionaries中的resource

Dictionaries中的resource相对有一点复杂。原因之一是，如果你还记得在前面第二章第三天时我们提到，当时访问Dictionary中的值的时候，返回的一定是optional的。这使得存储和提取resource更复杂点。无论怎样，resource *通常也都是存储在Dictionary中*，因此学习如何处理这些是非常重要的。

我们用一个类似的合约作为例子：

```cadence
pub contract Test {

    pub var dictionaryOfGreetings: @{String: Greeting}

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    init() {
        self.dictionaryOfGreetings <- {}
    }

}
```

我们有一个Dictionary包含 `message` 与包含message的`@Greeting` resource的映射. 请注意这个dictionary类型: `@{String: Greeting}`. `@` 是在花括号外.

### 添加到Dictionary

把resource添加到dictionary有两种方式。我们来分别看一下

##### 1 - 最简单的, 但有些限制

将一个resource加到dictionary里最简单的办法就是用 “强制移动” 运算符 `<-!`，比如这样：

```cadence
pub contract Test {

    pub var dictionaryOfGreetings: @{String: Greeting}

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    pub fun addGreeting(greeting: @Greeting) {
        let key = greeting.message
        self.dictionaryOfGreetings[key] <-! greeting
    }

    init() {
        self.dictionaryOfGreetings <- {}
    }

}
```

在 `addGreeting` 函数中, 我们首先通过 `greeting` 里的 `message`来获得 `key` . 之后我们用“强制移动”把 `greeting` 加到 `dictionaryOfGreetings` dictionary 的 `key` 的位置.

强制移动运算符 `<-!` 的意思是：“如果要存放的位置有值，就报错并终止程序；否则的话，就把值放进去”

##### 2 - 复杂点，但能处理重复值的情况

第二种方式是两次移动语法，比如这样：

```cadence
pub contract Test {

    pub var dictionaryOfGreetings: @{String: Greeting}

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    pub fun addGreeting(greeting: @Greeting) {
        let key = greeting.message
        
        let oldGreeting <- self.dictionaryOfGreetings[key] <- greeting
        destroy oldGreeting
    }

    init() {
        self.dictionaryOfGreetings <- {}
    }

}
```

在这个例子中，你能看到这个比较奇怪的两次移动运算符。这个是干什么用的？我们来一步步分解来看：

1. 把 `key` 中的任何值取出来，移动到 `oldGreeting`
2. 现在我们知道 `key` 没有映射到任何东西, 移动 `greeting` 到这个位置
3. 销毁 `oldGreeting`

本质上来说，这个确实有点麻烦且看上去怪怪的，但 **这能让你处理如果原来已经有值的情况**。在上面的例子中，我们是简单的销毁了resource，但如果你想的话，你可以做一些其他的操作。

### 从Dictionary中删除

下面是，我们如何从dictionary中删除一个resource：

```cadence
pub contract Test {

    pub var dictionaryOfGreetings: @{String: Greeting}

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    pub fun addGreeting(greeting: @Greeting) {
        let key = greeting.message
        
        let oldGreeting <- self.dictionaryOfGreetings[key] <- greeting
        destroy oldGreeting
    }

    pub fun removeGreeting(key: String): @Greeting {
        let greeting <- self.dictionaryOfGreetings.remove(key: key) ?? panic("Could not find the greeting!")
        return <- greeting
    }

    init() {
        self.dictionaryOfGreetings <- {}
    }

}
```

还记得我们在“从array中删除值的”那一部分讲到的，需要我们做的只是调用那个 `remove` 函数。在 dictionary中，访问一个元素的返回值是optional的，所以我们需要怎么着“打开”它。如果我们这样写。。。


```cadence
pub fun removeGreeting(key: String): @Greeting {
    let greeting <- self.dictionaryOfGreetings.remove(key: key)
    return <- greeting
}
```

我们会发现一个报错："Mismatched types. Expected `Test.Greeting`, got `Test.Greeting?`"。修正这个问题，我们可以要么使用 `panic` ，或者我们使用强制打开运算符 `！`，比如这样：


```cadence
pub fun removeGreeting(key: String): @Greeting {
    let greeting <- self.dictionaryOfGreetings.remove(key: key) ?? panic("Could not find the greeting!")
    // 或者...
    // let greeting <- self.dictionaryOfGreetings.remove(key: key)!
    return <- greeting
}
```

## 结语


这就是我们今天的内容！也许你想问： “如果我想*获取*一个数组或dictionary中的一个resource，然后再对其进行一些操作，该怎么做？你当然可以做，但你第一步要先把resource从arry/dictionary中移动出来，做某些操作，然后再移动回去。明天，我们会讨论reference，通过reference我们可以对resource做一些操作，但不需要移动resource”

## 任务

今天的任务，是一个大一点的任务。

1. 编写你自己的合约，包含两个状态变量：一个resource array，一个resource dictionary。编写对应的函数来问添加/移除对应的元素。必须与上面用到的例子不同。