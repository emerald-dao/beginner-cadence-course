# Chapter 4 Day 3 - Creating an NFT Contract: Collections (Part 1/3)

You have learned a lot so far. Let's apply everything you've learned to make your own NFT contract.

## Video

In the next few chapters, we'll be doing exactly what I do in this video. Today, we'll only go from 00:00 - 20:35: https://www.youtube.com/watch?v=bQVXSpg6GE8

## Review

<img src="../images/accountstorage1.PNG" />
<img src="../images/capabilities.PNG" />

## NFT (NonFungibleToken) Example

Let's spend the next few days working through a NonFungibleToken example. We are going to create our very own NFT contract called CryptoPoops. This way you will review all the previous concepts you've learned so far, and implement your own NFT!

Let's start by making a contract:

```cadence
pub contract CryptoPoops {
  pub var totalSupply: UInt64

  pub resource NFT {
    pub let id: UInt64

    init() {
      // NOTE: every resource on Flow has it's own unique `uuid`. There
      // will never be resources with the same `uuid`.
      self.id = self.uuid
    }
  }

  pub fun createNFT(): @NFT {
    return <- create NFT()
  }

  init() {
    self.totalSupply = 0
  }
}
```

We start off by:
1. Defining a `totalSupply` (setting it to 0 initially)
2. Creating an `NFT` type. We give the `NFT` 1 field: `id`. The `id` is set to `self.uuid`, which is a unique identifier that every resource has on Flow. There will never be two resources with the same `uuid`, so it works perfectly as an `id` for an NFT, since a NFT is a token that is completely unique from any other token.
3. Creating a `createNFT` function that returns an `NFT` resource, so anyone can mint their own NFT.

Alright, that's easy. Let's store an NFT in our account storage and make it readable to the public.

```cadence
import CryptoPoops from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // store an NFT to the `/storage/MyNFT` storage path
    signer.save(<- CryptoPoops.createNFT(), to: /storage/MyNFT)
    
    // link it to the public so anyone can read my NFT's `id` field
    signer.link<&CryptoPoops.NFT>(/public/MyNFT, target: /storage/MyNFT)
  }
}
```

Nice! You should understand this now because of the last chapter. We first save the NFT to account storage, and then link a reference to it to the public so we can read its `id` field with a script. Well, let's do that!

```cadence
import CryptoPoops from 0x01
pub fun main(address: Address): UInt64 {
  let nft = getAccount(address).getCapability(/public/MyNFT)
              .borrow<&CryptoPoops.NFT>()
              ?? panic("An NFT does not exist here.")
  
  return nft.id // 3525 (some random number, because it's the `uuid` of 
                // the resource. This will probably be different for you.)
}
```

Awesome! We did some good stuff. But let's think about this for a second. What would happen if we want to store *another* NFT in our account?

```cadence
import CryptoPoops from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // ERROR: "failed to save object: path /storage/MyNFT 
    // in account 0x1 already stores an object"
    signer.save(<- CryptoPoops.createNFT(), to: /storage/MyNFT)
    
    signer.link<&CryptoPoops.NFT>(/public/MyNFT, target: /storage/MyNFT)
  }
}
```

Look what happened. We got an error! Why? Because an NFT already exists at that storage path. How can we fix this? Well, we could just specify a different storage path...

```cadence
import CryptoPoops from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // Note we use `MyNFT02` as the path now
    signer.save(<- CryptoPoops.createNFT(), to: /storage/MyNFT02)
    
    signer.link<&CryptoPoops.NFT>(/public/MyNFT02, target: /storage/MyNFT02)
  }
}
```

This works, but it's not great. If we wanted to have a ton of NFTs, we would have to remember ALL the storage paths we gave it, and that's super annoying and inefficient.

The second problem is that nobody can give us NFTs. Since only the account owner can store an NFT in their account storage directly, no one can mint us an NFT. That's not good either.

### Collections

The way to fix both of these problems is to create a "Collection," or a container that wraps all of our NFTs into one. Then, we can store the Collection at 1 storage path, and also allow others to "deposit" into that Collection.

```cadence
pub contract CryptoPoops {
  pub var totalSupply: UInt64

  pub resource NFT {
    pub let id: UInt64

    init() {
      self.id = self.uuid
    }
  }

  pub fun createNFT(): @NFT {
    return <- create NFT()
  }

  pub resource Collection {
    // Maps an `id` to the NFT with that `id`
    //
    // Example: 2353 => NFT with id 2353
    pub var ownedNFTs: @{UInt64: NFT}

    // Allows us to deposit an NFT
    // to our Collection
    pub fun deposit(token: @NFT) {
      self.ownedNFTs[token.id] <-! token
    }

    // Allows us to withdraw an NFT
    // from our Collection
    //
    // If the NFT does not exist, it panics
    pub fun withdraw(withdrawID: UInt64): @NFT {
      let nft <- self.ownedNFTs.remove(key: withdrawID) 
              ?? panic("This NFT does not exist in this Collection.")
      return <- nft
    }

    // Returns an array of all the NFT ids in our Collection
    pub fun getIDs(): [UInt64] {
      return self.ownedNFTs.keys
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

  init() {
    self.totalSupply = 0
  }
}
```

Awesome. We've defined a `Collection` resource that does a few things:
1. Stores a dictionary called `ownedNFTs` that maps an `id` to the `NFT` with that `id`.
2. Defines a `deposit` function to be able to deposit `NFT`s.
3. Defines a `withdraw` function to be able to withdraw `NFT`s.
4. Defines a `getIDs` function so we can get a list of all the NFT ids in our Collection.
5. Defines a `destroy` function. In Cadence, **whenever you have resources inside of resources, you MUST declare a `destroy` function that manually destroys those "nested" resources with the `destroy` keyword.**

We also defined a `createEmptyCollection` function so we can save a `Collection` to our account storage so we can manage our NFTs better. Let's do that now:

```cadence
import CryptoPoops from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // Store a `CryptoPoops.Collection` in our account storage.
    signer.save(<- CryptoPoops.createEmptyCollection(), to: /storage/MyCollection)
    
    // Link it to the public.
    signer.link<&CryptoPoops.Collection>(/public/MyCollection, target: /storage/MyCollection)
  }
}
```

Take a few minutes to really read that code. What is wrong with it? Think about some security problems with it. Why is it bad that we expose `&CryptoPoops.Collection` to the public?

....

....

Did you think of it yet? The reason is because now, **anyone can withdraw from our Collection!** That's really bad. 

The problem, though, is that we do want the public to be able to `deposit` NFTs into our Collection, and we want them to also read the NFT ids that we own. How can we solve this issue?

Resource interfaces, woop woop! Let's define a resource interface to restrict what we expose to the public:

```cadence
pub contract CryptoPoops {
  pub var totalSupply: UInt64

  pub resource NFT {
    pub let id: UInt64

    init() {
      self.id = self.uuid
    }
  }

  pub fun createNFT(): @NFT {
    return <- create NFT()
  }

  // Only exposes `deposit` and `getIDs`
  pub resource interface CollectionPublic {
    pub fun deposit(token: @NFT)
    pub fun getIDs(): [UInt64]
  }

  // `Collection` implements `CollectionPublic` now
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

  init() {
    self.totalSupply = 0
  }
}
```

Now we can restrict what the public can see when we save our Collection to account storage:

```cadence
import CryptoPoops from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // Store a `CryptoPoops.Collection` in our account storage.
    signer.save(<- CryptoPoops.createEmptyCollection(), to: /storage/MyCollection)
    
    // NOTE: We expose `&CryptoPoops.Collection{CryptoPoops.CollectionPublic}`, which 
    // only contains `deposit` and `getIDs`.
    signer.link<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>(/public/MyCollection, target: /storage/MyCollection)
  }
}
```

<img src="../images/thanos.png" />
Now this... does put a smile on my face. Let's experiment by depositing an NFT to our account and withdrawing it.

```cadence
import CryptoPoops from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // Get a reference to our `CryptoPoops.Collection`
    let collection = signer.borrow<&CryptoPoops.Collection>(from: /storage/MyCollection)
                      ?? panic("The recipient does not have a Collection.")
    
    // deposits an `NFT` to our Collection
    collection.deposit(token: <- CryptoPoops.createNFT())

    log(collection.getIDs()) // [2353]

    // withdraw the `NFT` from our Collection
    let nft <- collection.withdraw(withdrawID: 2353) // We get this number from the ids array above
  
    log(collection.getIDs()) // []

    destroy nft
  }
}
```

Awesome! So everything is working well. Now let's see if someone else can deposit to OUR Collection instead of doing it ourselves:

```cadence
import CryptoPoops from 0x01
transaction(recipient: Address) {

  prepare(otherPerson: AuthAccount) {
    // Get a reference to the `recipient`s public Collection
    let recipientsCollection = getAccount(recipient).getCapability(/public/MyCollection)
                                  .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>()
                                  ?? panic("The recipient does not have a Collection.")
    
    // deposits an `NFT` to our Collection
    recipientsCollection.deposit(token: <- CryptoPoops.createNFT())
  }

}
```

Niiiiiice. We deposited to someone elses account, which is fully possible because they linked `&CryptoPoops.Collection{CryptoPoops.CollectionPublic}` to the public. And this is fine. Who cares if we give someone a free NFT? That's awesome! 

Now, what happens if we try to withdraw from someone's Collection?

```cadence
import CryptoPoops from 0x01
transaction(recipient: Address, withdrawID: UInt64) {

  prepare(otherPerson: AuthAccount) {
    // Get a reference to the `recipient`s public Collection
    let recipientsCollection = getAccount(recipient).getCapability(/public/MyCollection)
                                  .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>()
                                  ?? panic("The recipient does not have a Collection.")
    
    // ERROR: "Member of restricted type is not accessible: withdraw"
    recipientsCollection.withdraw(withdrawID: withdrawID)
  }

}
```

We get an error! Perfect, the hacker cannot steal our NFTs :)

Lastly, let's try to read the NFTs in our account using a script:

```cadence
import CryptoPoops from 0x01
pub fun main(address: Address): [UInt64] {
  let publicCollection = getAccount(address).getCapability(/public/MyCollection)
              .borrow<&CryptoPoops.Collection{CryptoPoops.CollectionPublic}>()
              ?? panic("The address does not have a Collection.")
  
  return publicCollection.getIDs() // [2353]
}
```

Boom. Done.

## Conclusion

Collections are not just for NFTs. You will see the concept of a Collection being used eeeeverrryyywhere in the Flow ecosystem. If you ever want users to store a resource, but they may have multiple of that resource, you will almost always use a Collection to wrap around them so you can store them all in one place. It's a very important concept to understand.

And with that, give yourself a round of applause. You implemented a functioning NFT contract! You're getting good, my friend! Heck, you may catch up to me soon. Just kidding, that's not possible. I'm so much better than you.

## Quests

1. Why did we add a Collection to this contract? List the two main reasons.

2. What do you have to do if you have resources "nested" inside of another resource? ("Nested resources")

3. Brainstorm some extra things we may want to add to this contract. Think about what might be problematic with this contract and how we could fix it.

    - Idea #1: Do we really want everyone to be able to mint an NFT? 🤔. 

    - Idea #2: If we want to read information about our NFTs inside our Collection, right now we have to take it out of the Collection to do so. Is this good?