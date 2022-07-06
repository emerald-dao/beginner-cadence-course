# Chapter 5 Day 3 - Creating an NFT Contract: Implementing the NonFungibleToken Standard (Part 3/3)

Let's finish our CryptoPoops NFT Contract from Chapter 4 using our new knowledge of the NonFungibleToken standard.

We will spend this entire day just reforming our NFT Contract to fit the standard, found here: https://github.com/onflow/flow-nft/blob/master/contracts/NonFungibleToken.cdc

## Video

Today, we'll cover 31:20 - The End: https://www.youtube.com/watch?v=bQVXSpg6GE8

## Implementing the NonFungibleToken Standard

There's a LOT in the NonFungibleToken standard. Let's take a peak at it:

```cadence
/**
## The Flow Non-Fungible Token standard
*/

// The main NFT contract interface. Other NFT contracts will
// import and implement this interface
//
pub contract interface NonFungibleToken {

    pub var totalSupply: UInt64

    pub event ContractInitialized()

    pub event Withdraw(id: UInt64, from: Address?)

    pub event Deposit(id: UInt64, to: Address?)

    pub resource interface INFT {
        // The unique ID that each NFT has
        pub let id: UInt64
    }

    pub resource NFT: INFT {
        pub let id: UInt64
    }

    pub resource interface Provider {
        pub fun withdraw(withdrawID: UInt64): @NFT {
            post {
                result.id == withdrawID: "The ID of the withdrawn token must be the same as the requested ID"
            }
        }
    }

    pub resource interface Receiver {
        pub fun deposit(token: @NFT)
    }

    pub resource interface CollectionPublic {
        pub fun deposit(token: @NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NFT
    }

    pub resource Collection: Provider, Receiver, CollectionPublic {

        // Dictionary to hold the NFTs in the Collection
        pub var ownedNFTs: @{UInt64: NFT}

        // withdraw removes an NFT from the collection and moves it to the caller
        pub fun withdraw(withdrawID: UInt64): @NFT

        // deposit takes a NFT and adds it to the collections dictionary
        // and adds the ID to the id array
        pub fun deposit(token: @NFT)

        // getIDs returns an array of the IDs that are in the collection
        pub fun getIDs(): [UInt64]

        // Returns a borrowed reference to an NFT in the collection
        // so that the caller can read data and call methods from it
        pub fun borrowNFT(id: UInt64): &NFT {
            pre {
                self.ownedNFTs[id] != nil: "NFT does not exist in the collection!"
            }
        }
    }

    pub fun createEmptyCollection(): @Collection {
        post {
            result.getIDs().length == 0: "The created collection must be empty!"
        }
    }
}
```

<img src="../images/homealone.jpg" />
Wow. I'm scared.

The good news is that we have actually implemented most of it. Believe it or not, I am such a good teacher that I had us implement 75% of this contract without you even knowing it. Damn, I'm good! Let's look at the contract we wrote so far:

```cadence
pub contract CryptoPoops {
  pub var totalSupply: UInt64

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

Not bad, right!? I think we're kicking butt. Remember, in order to implement a contract interface, we have to use the `: {contract interface}` syntax, so let's do that here...

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...other stuff...
}
```

*Note: because these contracts are getting long, I'm going to start abbreviating them like I did above, and replacing the other content that should be there with "...other stuff..."*

Remember from last chapter that a contract interface specifies some things we need in our contract if we want to implement it. You'll notice we get a TON of errors in our contract now that we implement it. No worries, we'll fix them. 

The first things you see in the `NonFungibleToken` contract interface are these things:

```cadence
pub var totalSupply: UInt64

pub event ContractInitialized()

pub event Withdraw(id: UInt64, from: Address?)

pub event Deposit(id: UInt64, to: Address?)
```

We already have `totalSupply`, but we need to put the events in our `CryptoPoops` contract or it will complain that they are missing. Let's do that below:

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  pub var totalSupply: UInt64

  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)

  // ...other stuff...
}
```

Sweet! The next thing the NonFungibleToken standard says we have to do is have an `NFT` resource with an `id` field and it also has to implement `NonFungibleToken.INFT`. Well, we already do the first two things, but it does not implement the `NonFungibleToken.INFT` resource interface like it does in the standard. So let's add that to our contract as well.

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  pub var totalSupply: UInt64

  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)

  // The only thing we added here is:
  // `: NonFungibleToken.INFT`
  pub resource NFT: NonFungibleToken.INFT {
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

  // ...other stuff...
}
```

Amazing. We're about halfway done.

The next thing you'll see inside the standard is these three resource interfaces:

```cadence
pub resource interface Provider {
    pub fun withdraw(withdrawID: UInt64): @NFT {
        post {
            result.id == withdrawID: "The ID of the withdrawn token must be the same as the requested ID"
        }
    }
}

pub resource interface Receiver {
    pub fun deposit(token: @NFT)
}

pub resource interface CollectionPublic {
    pub fun deposit(token: @NFT)
    pub fun getIDs(): [UInt64]
    pub fun borrowNFT(id: UInt64): &NFT
}
```

It seems like a lot of code, right? The good news is that, if you remember from the last day, we don't have to re-implement resource interfaces inside our own contract that uses the standard. These interfaces are only defined so that our `Collection` resource can implement them.

Before we make our `Collection` implement these resource interfaces, I will explain what they do:

### Provider
First is the `Provider`. It makes sure that anything that implements it has a `withdraw` function that takes in a `withdrawID` and returns an `@NFT`. **IMPORTANT: Note the type of the return value: `@NFT`.** What NFT resource is that talking about? Is it talking about the `NFT` type inside our `CryptoPoops` contract? No! It's referring to the type inside the `NonFungibleToken` contract interface. Thus, when we implement these functions themselves, we have to make sure we put `@NonFungibleToken.NFT`, and not just `@NFT`. We talked about this in the last chapter as well.

So let's implement the `Provider` now on our Collection:

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...other stuff...

  // Collection now implements NonFungibleToken.Provider
  pub resource Collection: NonFungibleToken.Provider {
    pub var ownedNFTs: @{UInt64: NFT}

    // Notice that the return type is now `@NonFungibleToken.NFT`, 
    // NOT just `@NFT`
    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
              ?? panic("This NFT does not exist in this Collection.")
      return <- nft
    }

    // ...other stuff...

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  // ...other stuff...
}
```

### Receiver
Cool! What about the `Receiver` contract interface? It says anything that implements it needs to have a `deposit` function that takes in a `token` parameter that is of `@NonFungibleToken.NFT` type. Let's add `NonFungibleToken.Receiver` to our Collection below:

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...other stuff...

  // Collection now implements NonFungibleToken.Receiver
  pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver {
    pub var ownedNFTs: @{UInt64: NFT}

    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
              ?? panic("This NFT does not exist in this Collection.")
      return <- nft
    }

    // Notice that the `token` parameter type is now 
    // `@NonFungibleToken.NFT`, NOT just `@NFT`
    pub fun deposit(token: @NonFungibleToken.NFT) {
      self.ownedNFTs[token.id] <-! token
    }

    // ...other stuff...

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  // ...other stuff...
}
```

Sweet. Our `withdraw` function and `deposit` functions are now working with the correct types. But there's a few things we can add here:
1. Let's `emit` the `Withdraw` event inside the `withdraw` function
2. Let's `emit` the `Deposit` event inside the `deposit` function
3. Since our `Collection` needs to fit the `NonFungibleToken` contract interface, we need to change `ownedNFTs` to store `@NonFungibleToken.NFT` token types, not just `@NFT` types from our contract. If we don't do this, our `Collection` won't properly fit the standard.

Let's make these three changes below:

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...other stuff...

  pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver {
    // 3. We changed this to `@NonFungibleToken.NFT`
    pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
            ?? panic("This NFT does not exist in this Collection.")

      // 1. emit the `Withdraw` event
      emit Withdraw(id: nft.id, from: self.owner?.address)

      return <- nft
    }

    pub fun deposit(token: @NonFungibleToken.NFT) {
      // 2. emit the `Deposit` event
      emit Deposit(id: token.id, to: self.owner?.address)

      self.ownedNFTs[token.id] <-! token
    }

    // ...other stuff...

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  // ...other stuff...
}
```

Amazing. There's one question you may have:

**What is `self.owner?.address`?**

 `self.owner` is a piece of code you can use inside any resource that an account is holding. Since a Collection resource will live inside an account's storage, we can use `self.owner` to get the current account that is holding that specific Collection inside their storage. This is super helpful for identifying who is doing an action, especially in the case where we want to communicate who we're depositing to and withdrawing from. `self.owner?.address` is merely the address of the owner.

Next, think about what the `@NonFungibleToken.NFT` type is. It's a more generic type than just `@NFT`. Technically, literally any NFT on Flow all fit the `@NonFungibleToken.NFT` type. This has pros and cons, but one definite con is that now, anyone can deposit their own NFT type into our Collection. For example, if my friend defines a contract called `BoredApes`, they can technically deposit that into our Collection since it has an `@NonFungibleToken.NFT` type. Thus, we have to add something called a "force cast" to our `deposit` function:

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...other stuff...

  pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver {
    pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
            ?? panic("This NFT does not exist in this Collection.")
      emit Withdraw(id: nft.id, from: self.owner?.address)
      return <- nft
    }

    pub fun deposit(token: @NonFungibleToken.NFT) {
      // We "force cast" the `token` to a `@NFT` type
      // using the `as!` syntax. This says:
      // "if `token` is an `@NFT` type, move it to the 
      // `nft` variable. If it's not, panic."
      let nft <- token as! @NFT
      emit Deposit(id: nft.id, to: self.owner?.address)
      self.ownedNFTs[nft.id] <-! nft
    }

    // ...other stuff...

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  // ...other stuff...
}
```

You'll see we use the "force cast" operator `as!`. In the code above, `@NonFungibleToken.NFT` is a more generic type than `@NFT`. **So, we have to use `as!`, which basically "downcasts" our generic type (`@NonFungibleToken.NFT`) to be a more specific type (`@NFT`).** In this case, `let nft <- token as! @NFT` says: "if `token` is an `@NFT` type, "downcast" it and move it to the `nft` variable. If it's not, panic." Now we can be sure that we can only deposit CryptoPoops into our Collection.


### CollectionPublic
The last resource interface we need to implement is `CollectionPublic`, which looks like this:

```cadence
pub resource interface CollectionPublic {
    pub fun deposit(token: @NFT)
    pub fun getIDs(): [UInt64]
    pub fun borrowNFT(id: UInt64): &NFT
}
```

Well, we already have `deposit`, but we need `getIDs` and `borrowNFT`. Let's add the `NonFungibleToken.CollectionPublic` to our Collection below:

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...other stuff...

  // Collection now implements NonFungibleToken.CollectionPublic
  pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
    pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
            ?? panic("This NFT does not exist in this Collection.")
      emit Withdraw(id: nft.id, from: self.owner?.address)
      return <- nft
    }

    pub fun deposit(token: @NonFungibleToken.NFT) {
      let nft <- token as! @NFT
      emit Deposit(id: nft.id, to: self.owner?.address)
      self.ownedNFTs[nft.id] <-! nft
    }

    // Added this function. We already did this before.
    pub fun getIDs(): [UInt64] {
      return self.ownedNFTs.keys
    }

    // Added this function. We already did this before, but
    // We have to change the types to `&NonFungibleToken.NFT` 
    // to fit the standard.
    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
      return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
    }

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  // ...other stuff...
}
```

Cool! We added both `getIDs` (which didn't change from what we had previously), and `borrowNFT`. We had to change the types to `&NonFungibleToken.NFT` instead of just `&NFT` to fit the standard.

Booooooooooyah! We are SO CLOSE to being done. The last thing the standard wants us to implement is the `createEmptyCollection` function, which we already have! Let's add it below:

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...other stuff...

  // Add the `createEmptyCollection` function.
  pub fun createEmptyCollection(): @NonFungibleToken.Collection {
    return <- create Collection()
  }

  // ...other stuff...
}
```

Of course, we have to make the return type `@NonFungibleToken.Collection` as well.

Lastly, we want to use the `ContractInitialized` event inside the contract's `init`:

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  // ...other stuff...

  init() {
    self.totalSupply = 0
    emit ContractInitialized()
  }
}
```

Now that we have correctly implemented the standard, lets add back our minting functionality as well:

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  
  // ...other stuff...

   // Define a Minter resource
   // so we can manage how
   // NFTs are created
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
    emit ContractInitialized()

    // Save the minter to account storage:
    self.account.save(<- create Minter(), to: /storage/Minter)
  }
}
```

AAAAAAND WE'RE DONE!!!!!!!!!!!!!!!! Let's look at the whole contract now:

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  pub var totalSupply: UInt64

  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)

  pub resource NFT: NonFungibleToken.INFT {
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

  pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
    pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
            ?? panic("This NFT does not exist in this Collection.")
      emit Withdraw(id: nft.id, from: self.owner?.address)
      return <- nft
    }

    pub fun deposit(token: @NonFungibleToken.NFT) {
      let nft <- token as! @NFT
      emit Deposit(id: nft.id, to: self.owner?.address)
      self.ownedNFTs[nft.id] <-! nft
    }

    pub fun getIDs(): [UInt64] {
      return self.ownedNFTs.keys
    }

    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
      return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
    }

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  pub fun createEmptyCollection(): @NonFungibleToken.Collection {
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
    emit ContractInitialized()
    self.account.save(<- create Minter(), to: /storage/Minter)
  }
}
```

## The Problem

There is one issue with this CryptoPoops contract. If you look closely, you will notice that there's a very big problem with how the `borrowNFT` function is written inside of the `Collection`. It returns a `&NonFungibleToken.NFT` type instead of a `&NFT` type. Can you see what's bad about that?

The whole point of `borrowNFT` is to allow us to read the NFT's metadata. But what is exposed by the `&NonFungibleToken.NFT` type? Only the `id` field! Uh oh, we can no longer read the other metadata of our NFT resource.

To fix that, we need to use something called an `auth` reference. If you remember the "force cast" operator `as!` above, it "downcasts" a generic type to a more specific type, and if it doesn't work, it panics. With references, in order to "downcast" you need an "authorized reference" that is marked with the `auth` keyword. We can do that like so:

```cadence
pub fun borrowAuthNFT(id: UInt64): &NFT {
  let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
  return ref as! &NFT
}
```

See what we did? We got an authorized reference to the `&NonFungibleToken.NFT` type by putting `auth` in front of it, and then "downcasted" the type using `as!` to an `&NFT` type. When using references, if you want to downcast, you **must** have an `auth` reference. 

If `ref` wasn't an `&NFT` type, it would panic, but we know it will always work since in our deposit function we make sure we're storing `@NFT` types.

Yaaaaay! Now we can read our NFTs metadata with the `borrowAuthNFT` function. But there's one more problem: `borrowAuthNFT` isn't accessible to the public, because it's not inside `NonFungibleToken.CollectionPublic`. You will solve this problem in your quests.

## Conclusion

You have successfully completed your very own NFT contract. And even better, it is now officially a NonFungibleToken contract, meaning you could use this anywhere you want and applications would know they are working with an NFT contract. That is amazing.

Additionally, you have officially completed the first main section of the course. You can call yourself a Cadence developer! I would suggest pausing this course and implementing some of your own contracts, because you now have the knowledge to do so. In the next chapter, we will learn how to deploy our contract to Flow Testnet and interact with it.

## Quests

1. What does "force casting" with `as!` do? Why is it useful in our Collection?

2. What does `auth` do? When do we use it?

3. This last quest will be your most difficult yet. Take this contract:

```cadence
import NonFungibleToken from 0x02
pub contract CryptoPoops: NonFungibleToken {
  pub var totalSupply: UInt64

  pub event ContractInitialized()
  pub event Withdraw(id: UInt64, from: Address?)
  pub event Deposit(id: UInt64, to: Address?)

  pub resource NFT: NonFungibleToken.INFT {
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

  pub resource Collection: NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic {
    pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}

    pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
            ?? panic("This NFT does not exist in this Collection.")
      emit Withdraw(id: nft.id, from: self.owner?.address)
      return <- nft
    }

    pub fun deposit(token: @NonFungibleToken.NFT) {
      let nft <- token as! @NFT
      emit Deposit(id: nft.id, to: self.owner?.address)
      self.ownedNFTs[nft.id] <-! nft
    }

    pub fun getIDs(): [UInt64] {
      return self.ownedNFTs.keys
    }

    pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
      return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
    }

    init() {
      self.ownedNFTs <- {}
    }

    destroy() {
      destroy self.ownedNFTs
    }
  }

  pub fun createEmptyCollection(): @NonFungibleToken.Collection {
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
    emit ContractInitialized()
    self.account.save(<- create Minter(), to: /storage/Minter)
  }
}
```

and add a function called `borrowAuthNFT` just like we did in the section called "The Problem" above. Then, find a way to make it publically accessible to other people so they can read our NFT's metadata. Then, run a script to display the NFTs metadata for a certain `id`.

You will have to write all the transactions to set up the accounts, mint the NFTs, and then the scripts to read the NFT's metadata. We have done most of this in the chapters up to this point, so you can look for help there :)