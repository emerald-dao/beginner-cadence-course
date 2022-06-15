# 第三章 第一天 - Resource资源

我们今天来学习Cadence中最最重要的话题：Resource资源。没开玩笑，这是你从这里学到的最重要的内容！我们开始吧！

## 视频

1. 你可以看视频的00:00 - 08:00 部分 (其余内容我们以后再讨论): https://www.youtube.com/watch?v=SGa2mnDFafc

## Resources 资源

<img src="../images/resources.jpeg" alt="drawing" width="500" />

resource或许是Cadence中最关键的一个组件，也是为什么Cadence是如此的特殊。顺便说一下，可以把 **一个resource看作是一个更安全的struct**。这个是简单说法。但更重要的是，因为resource的安全性，resource会有很多很有意思的用途，我们稍后会讲到。

读代码总是有帮助的，我们先来看一看这个：
```cadence
pub resource Greeting {
    pub let message: String
    init() {
        self.message = "Hello, Mars!"
    }
}
```

看起来是不是很像一个Struct？ 从代码的角度，他们看上去确实很类似。这里，`Greeting` resource 是一个包含了一条 `String` 类型的信息的容器。但这背后还有着很多很多的不同。


### Resources vs. Structs

在Cadence中，structs仅仅是数据的容器。你可以复制他们，覆写overwrite他们，在任何时间创建他们。所有的这些在resource上都不适用。下面这些是定义resource的几个重要的点：

1. 他们不能被复制。
2. 他们不能被丢失（或者复写）
3. 他们不能在任何时候都被创建
4. 你必须 *非常非常* 明确的表明你如何处理这个resource (比如，移动他们)
5. Resources更难操作。

让我们看下面的这些代码来学习resource：
```cadence
pub contract Test {

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    pub fun createGreeting(): @Greeting {
        let myGreeting <- create Greeting()
        return <- myGreeting
    }
}
```

这里发生了很多很重要的事情，我们挨个来看：

1. 我们声明了一个 resource类型的 `Greeting`， 包含一个 `message` 域. 这个你已经知道了
2. 我们定义了一个 `createGreeting` 函数来返回一个 `Greeting` resource. 注意在Cadence中，resource用 `@` 符来表示"这是一个resource"。
3. 我们用 `create` 关键字创建了一个新的 `Greeting`，并用 `<-` "移动" 操作符赋值给 `myGreeting`. 在Cadence中, 你不能用 `=` 来把resource放到某个地方. 你必须用 `<-` "移动操作符" 显式的 "移动" resource.
4. 通过移动resource，我们把新创建的 `Greeting` 返回.

好的，这很酷。但如果我们 *想* 销毁一个resource呢？好的，这个做起来很简单：

```cadence
pub contract Test {

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    pub fun makeAndDestroy() {
        let myGreeting <- create Greeting()
        destroy myGreeting 
        // 请注意：这是唯一一个你不需要用到`<-`操作符来改变resource所属地的地方。
    }
}
```

你已经能发现resources和struct有很大的不同。我们需要更清晰的表述我们想要如何操控resource。让我们来看一下resource有哪些事情我们不能做：

```cadence
pub contract Test {

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    pub fun createGreeting(): @Greeting {
        let myGreeting <- create Greeting()

        /*
            myGreeting <- create Greeting()

            你不能做上述的操作。这将”覆写overwrite“ myGreeting 变量，
            并立刻丢失之前已经存在这里的resource
        */

        /*
            let copiedMyGreeting = myGreeting

            你不能进行上述的操作。这是在尝试”复制“ myGreeting resource，但这是不允许的。
            resource永远不能被复制。如果你想把 myGreeting ”移动“ 到 copiedMyGreeting：
            你可以这样做：

            let copiedMyGreeting <- myGreeting

            这样之后，myGreeting里就什么都不存储了，因此你也不能再使用它了
        */

        /*
            return myGreeting
            
            你不能做上述操作。你必须用 <- 操作符显式的”移动“resource
        */
        return <- myGreeting
    }
}
```

不过这个为什么会有很用呢？ 它不是非常繁琐吗？不是的，这其实非常有用。比如说，我们想给某个人转一个价值几十亿刀的NFT。难道我们不想确定我们不会弄丢这个NFT吗？ **非常确定** ? 我们在Cadence中能做到，因为在Cadence中是 ”非常非常难“ 丢失Resource，除非我们真正的告诉它我们想要销毁。这也是Cadence的一个总的主题： **Cadence让开发者很难出错，这是件好事**

下面是关于Struct和Resource区别的一些总结：
- Structs是数据的容器，仅此而已
- Resource是极其安全，不能被复制，易于追踪的不能被丢失的数据的容器。


## 一些编程的注意事项：

下面是一些你实际编程时要注意的点：

- 你只能用 `create` 关键字来创建resource。`create` 关键字只能在合约中被调用。也就是说，你作为开发者，能够控制他们什么时候被创建。但这不适用于Structs，Structs可以在合约外创建。
- 在resource的类型前，你要使用 `@`符号，比如 `@Greeting`
- 要用 `<-` 来移动resource
- 要用 `destroy` 来销毁resource


## 不是很难吧？

你成功了！不是很难，对吧？我相信你能行。我们今天就到这里，明天继续！

## 任务

回答下面的问题：

1. 请用文字列举3个Structs为什么要和resource不同的原因。

2. 请表述一个resource比struct更适用的场景。

3. 创建一个新resource时的关键字是什么？

4. 我们能在在一个script或者transaction中创建resource吗？（假设有一个public的函数来创建）

5. 下面的这个resource类型是什么？

```cadence
pub resource Jacob {

}
```

6. 下面的代码中有四个错误，请修复他们

```cadence
pub contract Test {

    // Hint: There's nothing wrong here ;)
    pub resource Jacob {
        pub let rocks: Bool
        init() {
            self.rocks = true
        }
    }

    pub fun createJacob(): Jacob { // there is 1 here
        let myJacob = Jacob() // there are 2 here
        return myJacob // there is 1 here
    }
}
```