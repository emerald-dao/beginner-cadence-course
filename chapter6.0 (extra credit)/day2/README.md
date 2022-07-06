# Chapter 6 Day 2 - Interacting With Our Contract on Testnet

Now that we deployed our contract to testnet, we can interact with it in our terminal using the Flow CLI. Wooohooo! This is only going to get more complicated. I hope you all get super lost!

Today things will be a little different. It's going to involve doing things together. I'm not gonna give you all the answers ;)

## Interacting with our Contract

Now that we deployed our contract to testnet, we can interact with it in our terminal using the Flow CLI.

### Reading our Total Supply

Let's read the total supply of our smart contract!

> Step 1: Make a script that reads the totalSupply of our contract and returns it.

> Step 2: Paste that script into your scripts folder and name it `read_total_supply.cdc`

> Step 3: Open up your terminal in the base directory of the project and run:

```bash
flow scripts execute ./scripts/read_total_supply.cdc --network=testnet
```

If it works properly, you should see the total supply in your console (should be 0 if you haven't minted anything yet).

<img src="../images/read-total-supply.png" alt="read the total supply" />

### Setting Up Our Collection

Let's run a transaction to set up our NFT Collection on Testnet.

> Step 1: If you haven't already, make a transaction to set up a user's collection to store their NFTs.

> Step 2: Add a `setup_collection.cdc` file in your transactions folder with the Cadence code in it.

> Step 3: Open up your terminal in the base directory of the project and run:

```bash
flow transactions send ./transactions/setup_collection.cdc --network=testnet --signer=testnet-account
```

If it works properly, you should see the transasction is sealed (completed) and worked!

<img src="../images/setup-collection.png" alt="setup collection transaction" />

NICEEEEEE!!! We successfully set up our NFT Collection on testnet. This is so cool.

### How to Pass Arguments Using the Flow CLI

So far, we haven't shown you how to pass arguments into a script or transaction using the Flow CLI.

In order to do that, you simply put them after the file paths of the transaction or script.

Example #1:

```bash
flow transactions send ./transactions/mint_nft.cdc 0xfa88aefbb588049d --network=testnet --signer=testnet-account
```

If your `mint_nft.cdc` transaction took in a `recipient: Address`, it would be `0xfa88aefbb588049d` in this case.

Example #2:

```bash
flow scripts execute ./scripts/read_nft.cdc 0xfa88aefbb588049d 3  --network=testnet
```

If your `read_nft.cdc` script took in a `recipient: Address, id: UInt64`, it would be `0xfa88aefbb588049d` and `3` in this case.

Example #3:

```bash
flow transactions send ./transactions/mint_nft.cdc 0xfa88aefbb588049d "Jacob the Legend" --network=testnet --signer=testnet-account
```

If your `mint_nft.cdc` transaction took in a `recipient: Address, name: String`, it would be `0xfa88aefbb588049d` and `Jacob the Legend` in this case.

## Conclusion

That was a lot today, but how cool is this?! We deployed our own contract to Flow Testnet, ran a script to read our `totalSupply`, and then ran a transaction to setup our collection. You are all doing amazing!

## Quests

1. Figure out how to mint an NFT to yourself by sending a transaction using the Flow CLI, like we did today when we set up our collection. You will also likely have to pass an argument as well.

*Helpful tip*: Remember that only the owner of the contract has access to the `Minter` resource. This works in our favor because the `signer` of the transaction will be the one who deployed the contract, so we have access to the `Minter`.

*Helpful tip #2*: Also remember that in order to set up a collection, you must sign a transaction so the transaction has access to your `AuthAccount`. In this case, because we only have 1 created testnet account (the one who deployed the contract), we will be minting the NFT to ourselves to make it easier.

2. Run a script to read the new `totalSupply` using the Flow CLI

3. Run a script to read the ids of NFTs in someone's collection using the Flow CLI

4. Run a script to read a specific NFT's metadata from someone's collection using the Flow CLI

5. Run a script to read the GoatedGoats `totalSupply` on **Flow Mainnet**. Their contract lives here: https://flow-view-source.com/mainnet/account/0x2068315349bdfce5/contract/GoatedGoats

*Helpful tip #1*: In order to run scripts on Mainnet, simply switch the `--network=testnet` flag to `--network=mainnet`

*Helpful tip #2*: Because you will be running the script from a local file, you will have to hardcode in the mainnet address of the GoatedGoats contract into your script, like:
```cadence
import GoatedGoats from 0x2068315349bdfce5
```

Unfortunately you will now get compile errors (the VSCode extension won't be able to understand the import), but it will still work.

6. Figure out how to read someone's GoatedGoats NFTs from their collection and run a script using the Flow CLI to do it.