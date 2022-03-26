# Chapter 5 Day 2 - Contract Interfaces

Today, we will learn the last remaining concept needed to finish our NFT smart contract.

## Video

Contract Interfaces: https://www.youtube.com/watch?v=NHMBE6iRyfY

## Contract Interfaces

The good news about todays lesson is it's actually pretty easy. You have learned most of this already, you just don't know it yet ;)

Contract interfaces are pretty much exactly like resource interfaces, except they are for contracts. There are a few differences though, like "how do we define contract interfaces?" Let's look below:

```javascript
pub contract interface IHelloWorld {

}
```

Contract interfaces are like contracts in that they are deployed on their own. They are not inside a contract, rather, they are completely independent. 

You deploy a contract interface just like you do a normal contract. The only difference is they are declared with the `contract interface` keywords, like the example above.

Similar to resource interfaces, you can't initialize any variables or define any functions. Here's an example interface:

```javascript
pub contract interface IHelloWorld {
  pub var greeting: String
  
  pub fun changeGreeting(newGreeting: String)
}
```

We can take this contract interface and implement it on an actual contract:

```javascript
import IHelloWorld from 0x01
pub contract HelloWorld: IHelloWorld {

}
```

You'll notice we implement it just like we do with resources, using the `: {contract interface name}` syntax.

You'll also notice we get some errors: "contract `HelloWorld` does not conform to contract interface `IHelloWorld`". Why is this? Well, because we haven't implemented the stuff of course!


```javascript
import IHelloWorld from 0x01
pub contract HelloWorld: IHelloWorld {
  pub var greeting: String
  
  pub fun changeGreeting(newGreeting: String) {
    self.greeting = newGreeting
  }

  init() {
    self.greeting = "Hello, Jacob!"
  }
}
```

Ahh, all better now. Awesome!

### Pre/Post Conditions

We learned yesterday about pre/post-conditions. The great thing about them is we can actually use them inside a resource interface or contract interface, like so:

```javascript
pub contract interface IHelloWorld {
  pub var greeting: String
  
  pub fun changeGreeting(newGreeting: String) {
    post {
      self.greeting == newGreeting: "We didn't update the greeting appropiately."
    }
  }
}
```

We still didn't implement the function, but we enforced a restriction: the account that implements this contract interface MUST do the following:
1. Define a `greeting` string
2. Define a `changeGreeting` function
3. Furthermore, because of the post condition, they must update the `greeting` appropriately to be the `newGreeting` passed in.

This is a great way for us to make sure people are following our rules.

### Resource Interfaces in Contract Interfaces

Let's get fancy, shall we? Let's add a resource and a resource interface to our contract interface:

```javascript
pub contract interface IHelloWorld {
  pub var greeting: String
  
  pub fun changeGreeting(newGreeting: String) {
    post {
      self.greeting == newGreeting: "We didn't update the greeting appropiately."
    }
  }

  pub resource interface IGreeting {
    pub var favouriteFood: String
  }

  pub resource Greeting: IGreeting {
    pub var favouriteFood: String
  }
}
```

Lookey here! We have defined a resource named `Greeting` and a resource interface named `IGreeting` inside our contract interface. What this is saying is: "Whatever contract implements this contract interface, it MUST have a `Greeting` resource that specifically implements `IHelloWorld.IGreeting`."

This is very important to understand. If we define our own contract that defines it's own `IGreeting`, like so:

```javascript
import IHelloWorld from 0x01
pub contract HelloWorld: IHelloWorld {
  pub var greeting: String
  
  pub fun changeGreeting(newGreeting: String) {
    self.greeting = newGreeting
  }

  pub resource interface IGreeting {
    pub var favouriteFood: String
  }

  // ERROR: resource `HelloWorld.Greeting` is missing a declaration to 
  // required conformance to resource interface `IHelloWorld.IGreeting`
  pub resource Greeting: IGreeting {
    pub var favouriteFood: String

    init() {
      self.favouriteFood = "Chocolate chip pancakes." // soooooo good
    }
  }

  init() {
    self.greeting = "Hello, Jacob!"
  }
}
```

... we will get an error. The reason we're getting an error is because our contract interface specifically says our `Greeting` resource must implement `IHelloWorld.IGreeting`, not any arbitary `IGreeting` that someone defines. So this is what the contract would actually look like:

```javascript
import IHelloWorld from 0x01
pub contract HelloWorld: IHelloWorld {
  pub var greeting: String
  
  pub fun changeGreeting(newGreeting: String) {
    self.greeting = newGreeting
  }

  pub resource Greeting: IHelloWorld.IGreeting {
    pub var favouriteFood: String

    init() {
      self.favouriteFood = "Chocolate chip pancakes." // soooooo good
    }
  }

  init() {
    self.greeting = "Hello, Jacob!"
  }
}
```

Now we're all good :)

**Note: Even if a contract interface defines a resource interface, the implementing contract does NOT have to implement the resource interface as well. That can stay in the contract interface, like we did above.**

## Contract Interfaces as "Standards"

<img src="../images/nftpicforcourse.png" />

Contract interfaces allow you to specify some requirements on an implementing contract, and additionally, create "standards" on what certain contracts look like. 

Wouldn't it be helpful if we could rationalize that a contract was an "NFT Contract" without actually reading it's code? Well, it already exists! The NonFungibleToken contract interface (otherwise known as the NonFungibleToken standard) is a contract interface that defines what NFT Contracts must have to be deemed "NFT Contracts." This is helpful so clients like a Marketplace DApp can understand what they're looking at, and most importantly, **not have to implement different functionality for every NFT contract.**

Standardizing is incredibly beneficial so that a client using multiple contracts can have a singular way of interacting with all of those contracts. For example, all NFT contracts have a resource called Collection that has a `deposit` and `withdraw` function. This way, even if the client DApp is interacting with 100 NFT contracts, it only has to import the NonFungibleToken standard to call those functions, since it's all under one generic type. 

You can read more about it here: https://github.com/onflow/flow-nft

## Conclusion

Contract interfaces are very similar to resource interfaces in that they require you to implement certain things and allow you to implement heavy restrictions on what you're allowed to do. Additionally, they allow you to set "standards" which is very helpful in the context of rationalizing or ensuring a contract is what it claims to me. 

Coincidentally, contract interfaces are (in my opinion) the most heavily debated topic on Flow. This is because, for example, the NonFungibleToken contract interface (defined here: https://github.com/onflow/flow-nft/blob/master/contracts/NonFungibleToken.cdc) is relatively old, and there's lots of debate on how to fix it up. If you're ever in the Flow discord, you'll see us arguing about it nonstop ;)

## Quests

1. Explain why standards can be beneficial to the Flow ecosystem.

2. What is YOUR favourite food?

3. Please fix this code (Hint: There are two things wrong):

The contract interface:
```javascript
pub contract interface ITest {
  pub var number: Int
  
  pub fun updateNumber(newNumber: Int) {
    pre {
      newNumber >= 0: "We don't like negative numbers for some reason. We're mean."
    }
    post {
      self.number == newNumber: "Didn't update the number to be the new number."
    }
  }

  pub resource interface IStuff {
    pub var favouriteActivity: String
  }

  pub resource Stuff {
    pub var favouriteActivity: String
  }
}
```

The implementing contract:
```javascript
pub contract Test {
  pub var number: Int
  
  pub fun updateNumber(newNumber: Int) {
    self.number = 5
  }

  pub resource interface IStuff {
    pub var favouriteActivity: String
  }

  pub resource Stuff: IStuff {
    pub var favouriteActivity: String

    init() {
      self.favouriteActivity = "Playing League of Legends."
    }
  }

  init() {
    self.number = 0
  }
}
```