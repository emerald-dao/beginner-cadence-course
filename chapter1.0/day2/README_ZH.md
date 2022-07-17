# 第一章-第二天-Flow链和Cadence

现在我们已经了解了区块链是什么，第 2 天将介绍为什么我们决定学习 Flow 区块链以及它与其他区块链的区别。

## 视频

如果你想跟着视频学习，你可以点击下边链接

[Introduction to Flow and Cadence](https://www.youtube.com/watch?v=iVevnipJbHo)

## Flow链

![drawing](https://github.com/emerald-dao/beginner-cadence-course/raw/main/images/flowb.png)

Flow链是最好的。我说的。

## 历史课堂

![drawing](https://github.com/emerald-dao/beginner-cadence-course/raw/main/images/cryptokitty.png)

Flow 链相对较新。我想说，直到 2020 年夏天 Flow 团队开始向全世界展示它并引起人们的兴趣，它才变得广为人知。 Dapper Labs 最初创建了著名的 [CryptoKitties DApp](https://www.cryptokitties.co/)，该DApp在前几年非常受欢迎。事实上，我认为 CryptoKitties 是世界采用的首批“区块链”事物之一，这对行业来说是一笔巨大的震动。

在 Dapper Labs 在以太坊上的 CryptoKitties 取得巨大成功之后，他们也开始看到以太坊和 Solidity 的一些问题，Solidity是以太坊虚拟机 (EVM) 上许多区块链的智能合约编程语言。就这样，Cadence 诞生了。

## 关于Flow

- 它比以太坊便宜得多。例如，在以太坊上，如果您要尝试通过交易更改区块链上的数据（在第 1 天课程中有解释），平均成本约为 80 美元。然而，在 Flow 上，直到 2021 年 10 月左右，他们甚至都没有交易成本，而现在，交易成本只有几美分。因此，Flow 更容易为普通用户构建生产级 DApp。

- 它是非常新的，所以还有很多东西需要改进。这意味着Cadence某些地方肯定存在错误，但我们将一起解决它们。这也意味着现在是学习 Flow 和 Cadence 的绝佳机会。
- 几乎没有任何学习资源可以开始使用 Flow。因此，本课程应运而生。
- Flow 上有许多成功的 DApp，包括 NBATopShot，它曾经（现在仍然是）巨大的成功。

## Cadence

![drawing](https://github.com/emerald-dao/beginner-cadence-course/raw/main/images/cadence.png)

Cadence 是 Flow 区块链的智能合约编程语言。也就是说，您将在本课程中使用Cadence编写用于制作智能合约的代码。

因为 Flow 主要是为了解决以太坊上的一些问题而创建的，所以 Cadence 的基本要素是对 Solidity 的改进（有些人会反对这一点）。下面列出了这些。

基础知识，或者更确切地说，“Cadence 编程语言特性”：

1. **安全性**: 每个智能合约都必须是安全的。 Cadence 最大限度地提高效率，同时保持最高水平的安全性。它能做到这一点，是因为它非常强大的类型、合约和交易之间的分离以及面向资源的编程（参见 #5）。
2. **透明性**: 代码应该易于阅读，尤其是智能合约代码，以便我们作为用户可以验证它是安全的。这是通过使代码具有声明性并允许开发人员直接表达他们的意图来实现的。 Cadence 通过语言设计使这些意图非常清晰，再加上可读性，使审计和审查更加高效。
3. **容易入门**: Cadence 的编写方式与其他编程语言非常相似，如果您有先前的经验，可以轻松过渡到。
4. **开发者体验**: 开发人员应该能够以一种简单的方式进行调试，了解在哪里做什么，并且不会感到困扰。 Cadence 通过使错误消息非常清晰来做到这一点。
5. **面向资源编程**: 这是迄今为止最重要的，将占用我们本课程大约 80% 的时间。 Cadence 的核心就是使用称为`资源`的东西，它们几乎定义了我们在 Flow 上所做的一切。我现在不会讨论这个，因为我们将在之后上一堂关于`资源`的完整课程。

你可以通过看[Flow官方网站](https://docs.onflow.org/cadence/#cadences-programming-language-pillars)查看这些

如果你不明白这些。我们将在整个课程中触及这些特点，您将了解为什么这些特点对 Cadence 如此重要。

## 结论

今天的事情到此结束！第二天，我们将开始研究一些 Cadence 代码。

## 任务

请用你自己的语言回答下列问题

1. Cadence编程语言的特点是哪5个
2. 在您看来，即使您对区块链或编码一无所知，为什么 5 个特点会有用（您不必回答#5特点）？

