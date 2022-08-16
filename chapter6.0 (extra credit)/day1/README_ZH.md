# 第六章·第一天 - 创建测试账户并部署到测试网（Testnet）

嘿，大咖们。 在今天的课程中，我们将学习如何创建一个新的测试网账户，并把我们的 NFT 合约部署到 Flow 测试网。

## 安装 VSCode 插件：Cadence 

*如果你之前没安装过 VSCode，可以在这里下载: https://code.visualstudio.com/*

现在我们就不再在 playground 上玩了，我们希望在编写 Cadence 时，VSCode 可以展示错误信息。刚好有一个插件可以满足这个需求！

> 打开 VSCode。在左侧有一个图标（看起来像 4个正方形）。点击并搜索 "Cadence"。

> 点击下面的插件，安装:

<img src="../images/cadence-vscode-extension.png" />

## 安装 Flow CLI & flow.json

Flow CLI 可以让我们从 terminal 运行 transactions & scripts，也可以执行其他的 Flow 操作，例如部署合约。

> 安装 [Flow CLI](https://docs.onflow.org/flow-cli/install/). 通过以下方式:

**Mac**
- 粘贴 `sh -ci "$(curl -fsSL https://storage.googleapis.com/flow-cli/install.sh)"` 到 terminal

**Windows**
- 粘贴 `iex "& { $(irm 'https://storage.googleapis.com/flow-cli/install.ps1') }"` 到PowerShell

**Linux** 
- 粘贴 `sh -ci "$(curl -fsSL https://storage.googleapis.com/flow-cli/install.sh)"` 到 terminal

通过在 terminal 里输入 `flow version` 来确认 Flow CLI 已安装。如果出现了版本号，表示已安装成功。

## Flow 文件夹

在根目录里，我们创建一个文件夹叫 `flow`。 

在这个 `flow` 文件夹里，我们再创建一个文件夹叫 `cadence`。

在这个 `cadence` 文件夹里，我们分别创建一个 `contracts` 文件夹、一个 `transactions` 文件夹，和一个 `scripts` 文件夹。

在 `contracts` 文件夹里，新建一个文件 `CONTRACT_NAME.cdc`。用你的合约名字替换 CONTRACT_NAME。把第五章的合约代码放进这个文件。

首先要注意的是，现在我们需要导入本地文件路径，而不是 Flow playground 的随机地址。我们不再从 `0x01` 导入，那只是一个 playground 合约。现在我们要导入本地项目中的合约。

> 把顶部的导入改为: `import NonFungibleToken from "./NonFungibleToken.cdc"`

为了能正常工作，我们还需要把 `NonFungibleToken` 合约接口添加到 `contracts` 文件夹。确保文件命名为 `NonFungibleToken.cdc`。

---

在 transactions 文件夹中，创建一堆名为 `TRANSACTION_NAME.cdc` 的文件。把 TRANSACTION_NAME 替换为你的 transactions 名。

注意现在的导入都是错的。我们不再从 `0x01` 导入。我们不再从 `0x01` 导入，那只是一个 playground 合约。现在我们要导入本地项目中的合约。因此，把导入改成如下格式：

```cadence
import ExampleNFT from "../contracts/ExampleNFT.cdc"
```

--- 
 
在 scripts 文件夹中，创建一堆名为 `SCRIPT_NAME.cdc` 的文件。把 SCRIPT_NAME 替换成你的 scripts 名。

---

### flow.json

> 现在我们的项目目录里有我们的合约了，在 terminal 输入 `cd` 来到根目录。

> 输入 `flow init`

这个命令会在项目里创建一个 `flow.json` 文件。该文件是部署合约、编译 Cadence 代码所必需的。

## 部署我们的 NFT 合约到 TestNet

开心！现在让我们把合约部署到 TestNet，然后就可以和它交互了。

## 配置 `flow.json`

> 在 `flow.json` 文件里，"contracts" 长这样:

```json
"contracts": {
  "ExampleNFT": "./contracts/ExampleNFT.cdc",
  "NonFungibleToken": {
    "source": "./contracts/NonFungibleToken.cdc",
    "aliases": {
      "testnet": "0x631e88ae7f1d7c20"
    }
  }
},
```

"contracts" 让 `flow.json` 知道你的合约在哪儿。注意：`NonFungibleToken` 已经在 Flow Testnet 上了，所以看起来稍微有点复杂。

### 创建账户

> 🔐 生成一个 **部署地址** ：在 terminal 输入 `flow keys generate --network=testnet`，确保将你的公钥（public key）和私钥（private key）保存好，很快就要用到。

<img src="https://i.imgur.com/HbF4C73.png" alt="generate key pair" />

> 👛 创建你的 **部署账户** ：跳转到 https://testnet-faucet.onflow.org/ ，粘贴上面的公钥（public key）然和单击 `CREATE ACCOUNT` : 

<img src="https://i.imgur.com/73OjT3K.png" alt="configure testnet account on the website" />

> 完成之后，点击`复制地址`(`COPY ADDRESS`) ，保存好地址。你会用到它！

> ⛽️ 通过修改下面的代码，添加你的 testnet 账户到 `flow.json`。用刚才复制的地址替换 "YOUR GENERATED ADDRESS"，用你的私钥替换 "YOUR PRIVATE KEY"。

```json
"accounts": {
  "emulator-account": {
    "address": "f8d6e0586b0a20c7",
    "key": "5112883de06b9576af62b9aafa7ead685fb7fb46c495039b1a83649d61bff97c"
  },
  "testnet-account": {
    "address": "YOUR GENERATED ADDRESS",
    "key": {
      "type": "hex",
      "index": 0,
      "signatureAlgorithm": "ECDSA_P256",
      "hashAlgorithm": "SHA3_256",
      "privateKey": "YOUR PRIVATE KEY"
    }
  }
},
"deployments": {
  "testnet": {
    "testnet-account": [
      "ExampleNFT"
    ]
  }
}
```

> 🚀 部署你的 ExampleNFT 智能合约:

```sh
flow project deploy --network=testnet
```

<img src="../images/deploy-contract.png" alt="deploy contract to testnet" />

## 任务

1. 跳转到 https://flow-view-source.com/testnet/ 。在显示账户（"Account"）的地方，粘贴你生成的 Flow 地址，然后点击开始（"Go"）。在左手边，你将看到你的 NFT 合约。在 Testnet 上看到自己的合约是不是很🆒? 然后把 URL 发送到这个页面。
- 示例: https://flow-view-source.com/testnet/account/0x90250c4359cebac7/