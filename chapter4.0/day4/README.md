# Chapter 4 Day 4 - Creating an NFT Contract: Transferring, Minting, and Borrowing (Part 2/3)

Let's keep building our NFT contract! :D

## Video

Today, we'll cover 20:35 - 31:20: https://www.youtube.com/watch?v=bQVXSpg6GE8

## Recap so Far

In the last day, we went over how to create NFTs and store them inside of a Collection. The reason we made a Collection was so we could have all of our NFTs stored in one place in our account storage.

But we left ourselves with somewhat of a problem: should we *really* allow anybody to create an NFT? That seems a bit weird. What if we want to control who can mint an NFT? That's what we'll be talking about today. 

## Transferring

Before we get into controlling who can "mint" (or create) an NFT, let's talk about transferring. How can we transfer an NFT from one account to another?

Well, if you recall, only the owner of a Collection can `withdraw` from their Collection. However, anyone can `deposit` into another persons Collection. This is perfect for us, because it means we will only need access to 1 AuthAccount: the person who will be transferring (aka withdrawing) the NFT! Let's spin up a transaction to transfer an NFT:

*Note: This is assuming you've already set up both accounts with a Collection.*

```cadence
import CryptoPoops from 0x01

// `id` is the `id` of the NFT
// `recipient` is the person receiving the NFT
transaction(id: UInt64, recipient: Address) {

  prepare(signer: AuthAccount) {
    // get a reference to the signer's Collection
    let signersCollection = signer.borrow<&CryptoPoops.Collection>(from: /storage/MyCollection)
                            ?? panic("Signer does not have a CryptoPoops Collection")

    // Get a reference to the `recipient`s public Collection
    let recipientsCollection = getAccount(recipient).getCapability(/public/MyCollection)
                                  .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>
                                  ?? panic("The recipient does not have a CryptoPoops Collection.")
    
    // withdraws the NFT with id == `id` and moves it into the `nft` variable
    let nft <- signersCollection.withdraw(withdrawID: id)

    // deposits the NFT into the recipient's Collection
    recipientsCollection.deposit(token: <- nft)
  }

}
```

Not too bad right? We should understand all of this after learning yesterday's content. Here are the steps:
1. We first get a reference to the signer's Collection. We do not use a capability because we need to borrow directly from storage since we need to be able to call `withdraw`.
2. We then get a *public* reference to the recipient's Collection. We get this through a public capability because we don't have access to their AuthAccount, but this is fine since we only need to `deposit`.
3. We `withdraw` the NFT with `id` out of the signer's Collection.
4. We `deposit` the NFT into the recipient's Collection.

## Minting

Alright, so let's figure out how to prevent everyone from minting their own NFTs. The question now is, well, then WHO should have the ability to mint? 

The beauty of Cadence is that we can decide for ourselves. Why don't we start by making a Resource that mints NFTs? Then, whoever owns the resource can have the ability to mint an NFT. Let's build on top of the contract we had previously:

```cadence
pub contract CryptoPoops {
  
  // ... other stuff here ...

  pub fun createEmptyCollection(): @Collection {
    return <- create Collection()
  }

  // New resource: Minter
  // Allows anyone who holds it to
  // mint NFTs
  pub resource Minter {

    // mints a new NFT resource
    pub fun createNFT(): @NFT {
      return <- create NFT()
    }
  }

  init() {
    self.totalSupply = 0
  }
}
```

Here are the things that were added:
1. We created a new resource called `Minter`
2. We moved the `createNFT` function into the `Minter` resource

Now, anyone who holds the `Minter` resource is able to mint NFTs. Okay, that's cool and all, but who gets to have the minter now?

The easiest solution is to give the `Minter` automatically to the account that is deploying the contract. We can do that by saving the `Minter` resource to the account storage of the contract deployer's account inside the `init` function:

```cadence
pub contract CryptoPoops {
  
  // ... other stuff here ...

  pub fun createEmptyCollection(): @Collection {
    return <- create Collection()
  }

  pub resource Minter {

    pub fun createNFT(): @NFT {
      return <- create NFT()
    }

  }

  init() {
    self.totalSupply = 0

    // Save the `Minter` resource to account storage here
    self.account.save(<- create Minter(), to: /storage/Minter)
  }
}
```

When you're deploying the contract, inside the `init` function, you actually have access to the deploying account's `AuthAccount`! So we can save stuff to account storage there.

See what we did at the very end? We saved the `Minter` to account storage. Perfect! Now, only the account that deployed the contract has the ability to mint NFTs, and since there's no function to allow other users to get a `Minter`, it is completely safe! 

Let's look at an example transaction of a `Minter` minting someone an NFT. 

*Note: Let's assume the `signer` was the one who deployed the contract, since only they have the `Minter` resource*

```cadence
import CryptoPoops from 0x01

transaction(recipient: Address) {

  // Let's assume the `signer` was the one who deployed the contract, since only they have the `Minter` resource
  prepare(signer: AuthAccount) {
    // Get a reference to the `Minter`
    let minter = signer.borrow<&CryptoPoops.Minter>(from: /storage/Minter)
                    ?? panic("This signer is not the one who deployed the contract.")

    // Get a reference to the `recipient`s public Collection
    let recipientsCollection = getAccount(recipient).getCapability(/public/MyCollection)
                                  .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>
                                  ?? panic("The recipient does not have a Collection.")

    // mint the NFT using the reference to the `Minter`
    let nft <- minter.createNFT()

    // deposit the NFT in the recipient's Collection
    recipientsCollection.deposit(token: <- nft)
  }

}
```

Wooooooooohoooooooooooooo! We successfully implemented secure minting. This is a very important pattern to be aware of in Cadence: the ability to delegate some "Admin" functionality to a certain resource, like the `Minter` in this case. That "Admin" is most often given to the account storage of the account who deployed the contract.

## Borrowing

Alright, last thing. Remember yesterday we said that it is weird that we can't read our NFT without literally withdrawing it from the Collection? Well, let's add a function inside the `Collection` resource that lets us borrow the NFT:

```cadence
pub contract CryptoPoops {
  pub var totalSupply: UInt64

  pub resource NFT {
    pub let id: UInt64

    // Added some more metadata here so we can
    // read from it
    pub let name: String
    pub let favouriteFood: String
    pub let luckyNumber: Int

    init(_name: String, _favouriteFood: String, _luckyNumber: Int) {
      self.id = self.uuid

      self.name = _name
      self.favouriteFood = _favouriteFood
      self.luckyNumber = _luckyNumber
    }
  }

  pub resource interface CollectionPublic {
    pub fun deposit(token: @NFT)
    pub fun getIDs(): [UInt64]
  }

  pub resource Collection: CollectionPublic {
    pub var ownedNFTs: @{UInt64: NFT}

    pub fun deposit(token: @NFT) {
      self.ownedNFTs[token.id] <-! token
    }

    pub fun withdraw(withdrawID: UInt64): @NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
              ?? panic("This NFT does not exist in this Collection.")
      return <- nft
    }

    pub fun getIDs(): [UInt64] {
      return self.ownedNFTs.keys
    }

    // Added this function so now we can
    // read our NFT
    pub fun borrowNFT(id: UInt64): &NFT {
      return (&self.ownedNFTs[id] as &NFT?)!
    }

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  // ... other stuff here ...

  init() {
    self.totalSupply = 0
    self.account.save(<- create Minter(), to: /storage/Minter)
  }
}
```

Super simple right! We even added some extra fields (or "metadata") to our NFT so we can read info about it when we borrow it's reference from the Collection. In order to get the reference, we use a new `borrowNFT` function inside our `Collection` to return a reference to one of our NFTs that is stored inside our `ownedNFTs` dictionary. If we redeploy our contract, setup our accounts and run a new transaction to mint an NFT:

```cadence
import CryptoPoops from 0x01

// name: "Jacob"
// favouriteFood: "Chocolate chip pancakes"
// luckyNumber: 13
transaction(recipient: Address, name: String, favouriteFood: String, luckyNumber: Int) {

  prepare(signer: AuthAccount) {
    // Get a reference to the `Minter`
    let minter = signer.borrow<&CryptoPoops.Minter>(from: /storage/Minter)
                    ?? panic("This signer is not the one who deployed the contract.")

    // Get a reference to the `recipient`s public Collection
    let recipientsCollection = getAccount(recipient).getCapability(/public/MyCollection)
                                  .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>
                                  ?? panic("The recipient does not have a Collection.")

    // mint the NFT using the reference to the `Minter` and pass in the metadata
    let nft <- minter.createNFT(name: name, favouriteFood: favouriteFood, luckyNumber: luckyNumber)

    // deposit the NFT in the recipient's Collection
    recipientsCollection.deposit(token: <- nft)
  }

}
```

Awesome! We minted an NFT into the recipient's account. Now let's go ahead and use our new `borrowNFT` function in a script to read the NFT's metadata that was deposited into the account:

```cadence
import CryptoPoops from 0x01
pub fun main(address: Address, id: id) {
  let publicCollection = getAccount(address).getCapability(/public/MyCollection)
              .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>()
              ?? panic("The address does not have a Collection.")
  
  let nftRef: &CryptoPoops.NFT = publicCollection.borrowNFT(id: id) // ERROR: "Member of restricted type is not accessible: borrowNFT"
  log(nftRef.name)
  log(nftRef.favouriteFood)
  log(nftRef.luckyNumber)
}
```

WAIT! We get an error! Why is that? Ahh, it's because we forgot to add `borrowNFT` to the `CollectionPublic` interface inside our contract, so it's not accessible to the public! Let's go ahead and fix that:

```cadence
pub contract CryptoPoops {
  
  // ... other stuff here ...

  pub resource interface CollectionPublic {
    pub fun deposit(token: @NFT)
    pub fun getIDs(): [UInt64]
    // We added the borrowNFT function here
    // so it's accessible to the public
    pub fun borrowNFT(id: UInt64): &NFT
  }

  // ... other stuff here ...
}
```

Now, we can retry our script (assuming you mint the NFT all over again):

```cadence
import CryptoPoops from 0x01
pub fun main(address: Address, id: id) {
  let publicCollection = getAccount(address).getCapability(/public/MyCollection)
              .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>()
              ?? panic("The address does not have a Collection.")
  
  let nftRef: &CryptoPoops.NFT = publicCollection.borrowNFT(id: id)
  log(nftRef.name) // "Jacob"
  log(nftRef.favouriteFood) // "Chocolate chip pancakes"
  log(nftRef.luckyNumber) // 13
}
```

Yaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaay!!! We read our NFT metadata without having to withdraw it from the collection ;)

## Conclusion

We have now written a full-fledged NFT smart contract. That is super cool. We have also completed Chapter 4. 

In the next Chapter, we finish this contract and we will start to learn how to make our contract more "official." That is, how to implement something called a contract interface so that other applications know our NFT smart contract *is* in fact an NFT smart contract.

## Quests

Because we had a LOT to talk about during this Chapter, I want you to do the following:

Take our NFT contract so far and add comments to every single resource or function explaining what it's doing in your own words. Something like this:


```cadence
pub contract CryptoPoops {
  pub var totalSupply: UInt64

  // This is an NFT resource that contains a name,
  // favouriteFood, and luckyNumber
  pub resource NFT {
    pub let id: UInt64

    pub let name: String
    pub let favouriteFood: String
    pub let luckyNumber: Int

    init(_name: String, _favouriteFood: String, _luckyNumber: Int) {
      self.id = self.uuid

      self.name = _name
      self.favouriteFood = _favouriteFood
      self.luckyNumber = _luckyNumber
    }
  }

  // This is a resource interface that allows us to... you get the point.
  pub resource interface CollectionPublic {
    pub fun deposit(token: @NFT)
    pub fun getIDs(): [UInt64]
    pub fun borrowNFT(id: UInt64): &NFT
  }

  pub resource Collection: CollectionPublic {
    pub var ownedNFTs: @{UInt64: NFT}

    pub fun deposit(token: @NFT) {
      self.ownedNFTs[token.id] <-! token
    }

    pub fun withdraw(withdrawID: UInt64): @NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
              ?? panic("This NFT does not exist in this Collection.")
      return <- nft
    }

    pub fun getIDs(): [UInt64] {
      return self.ownedNFTs.keys
    }

    pub fun borrowNFT(id: UInt64): &NFT {
      return (&self.ownedNFTs[id] as &NFT?)!
    }

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  pub fun createEmptyCollection(): @Collection {
    return <- create Collection()
  }

  pub resource Minter {

    pub fun createNFT(name: String, favouriteFood: String, luckyNumber: Int): @NFT {
      return <- create NFT(_name: name, _favouriteFood: favouriteFood, _luckyNumber: luckyNumber)
    }

    pub fun createMinter(): @Minter {
      return <- create Minter()
    }

  }

  init() {
    self.totalSupply = 0
    self.account.save(<- create Minter(), to: /storage/Minter)
  }
}
```