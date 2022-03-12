# Chapter 5 Day 1 - Pre/Post Conditions & Events

Today, we will learn 2 concepts that, although fairly easy, are very common in Cadence.

## Video

Pre/Post Conditions: https://www.youtube.com/watch?v=WFqoCZY36b0

Events: https://www.youtube.com/watch?v=xRHG6Kgkxpg

## Pre/Post Conditions

So far, we have only learned of 1 way to abort a program if something isn't correct: the `panic` keyword. `panic` is a keyword that completely reverts what happened in the code if it's called, and it sends a message along with it. Here's an example:

```swift
pub fun main(): String {
  let a: Int = 3

  if a == 3 {
    panic("This script will never work because it will always panic on this line.")
  }

  return "Will never get to this line."
}
```

This is kind of a silly example, but you get the point. It will never return because it will always panic.

Often times, we want to handle errors in a clearer way, and also implement a concept called "fail fast." On the blockchain, operations are very expensive. That is why transactions cost expensive fees. "Fail fast" is a way of programming so that your code fails as soon as possible if something is wrong, so that you don't waste further execution time for no reason.

Pre/post conditions are perfect for this. They allow us to specify a very clear way to fail if something is wrong before (pre) or after (post) a function is called. Let's look at an example:

```swift
pub contract Test {

  pub fun logName(name: String) {
    pre {
      name.length > 0: "This name is too short."
    }
    log(name)
  }

}
```

In the example above, we define a "pre-condition" on the function `logName`. It says "if the length of the name is not greater than 0, `panic` with this message: 'This name is too short.'"

Pre-conditions and post-conditions **must** be defined as the first thing of a function, you can't put them in the middle or at the end. In order for a pre/post-condition to pass, the condition must be `true`, or else it will `panic` with the string after.

Post-conditions are the same thing, except they are checked at the end of a function (they still have to be defined at the start. I know, it's confusing, but you'll get used to it):


```swift
pub contract Test {

  pub fun makePositiveResult(x: Int, y: Int): Int {
    post {
      result > 0: "The result is not positive."
    }
    return x + y
  }

}
```

You may be wondering: "what the heck is that `result` variable? We never defined it." You're right! Post conditions are super cool because they come with a `result` variable already that equals the value of what's being returned. So if we return `x + y`, `result` will represent that. If there's no return value, `result` doesn't exist.

Additionally, you can use a `before()` function inside your post condition to access the value of something before the function modified that thing, even after the function has taken place. 

```swift
pub contract Test {

  pub resource TestResource {
    pub var number: Int

    pub fun updateNumber() {
      post {
        before(self.number) == self.number - 1
      }
      self.number = self.number + 1
    }

    init() {
      self.number = 0
    }

  }

}
```

The above code will always work, because the post-condition is satisfied. It says "after the `updateNumber` function is run, make sure that the updated number is 1 greater than the value is was before this function was run." Which is always true in this case.

### Important Note

It's important to understand what `panic` or pre/post conditions actually do. They "abort" a transaction, which means none of the state is actually changed.

Example:
```swift
pub contract Test {

  pub resource TestResource {
    pub var number: Int

    pub fun updateNumber() {
      post {
        self.number == 1000: "Will always panic!" // when this panics after the function is run, `self.number` gets reset back to 0
      }
      self.number = self.number + 1
    }

    init() {
      self.number = 0
    }

  }

}
```

## Events

Events are a way for a smart contract to communicate to the outside world that something happened. 

For example, if we mint an NFT, we want the outside world to know that an NFT was minted. Of course, we could just constantly check the contract to see if the `totalSupply` was updated or something, but that's really innefficient. Why not just have the contract tell *us*?

Here's how you can define an event in Cadence:

```swift
pub contract Test {

  // define an event here
  pub event NFTMinted(id: UInt64)

  pub resource NFT {
    pub let id: UInt64

    init() {
      self.id = self.uuid

      // broadcast the event to the outside world
      emit NFTMinted(id: self.id)
    }

  }

}
```

You can see we defined an event called `NFTMinted` like so: `pub event NFTMinted(id: UInt64)`. Note that events are ALWAYS `pub`/`access(all)`. We then broadcast the event using the `emit` keyword, which sends it off to the blockchain.

You can also pass parameters into the event so you can send data to the outside world. In this case, we want to tell the world that an NFT with a certain id was minted, so that whatever client is reading our events knows that specific NFT was minted.

The purpose of this is so that clients (people reading from our contract) can know when something happens, and update their code accordingly. Maybe we could make a cool website that shoots off a firework with my face on it every time an NFT is minted! :D

## Conclusion

That's all for today! I hope you enjoyed the shorter lesson. 

## Quests

1. Describe what an event is, and why it might be useful to a client.

2. Deploy a contract with an event in it, and emit the event somewhere else in the contract indicating that it happened.

3. Using the contract in step 2), add some pre conditions and post conditions to your contract to get used to writing them out.

4. For each of the functions below (numberOne, numberTwo, numberThree), follow the instructions.

```swift
pub contract Test {

  // TODO
  // Tell me whether or not this function will log the name.
  // name: 'Jacob'
  pub fun numberOne(name: String) {
    pre {
      name.length == 5: "This name is not cool enough."
    }
    log(name)
  }

  // TODO
  // Tell me whether or not this function will return a value.
  // name: 'Jacob'
  pub fun numberTwo(name: String): String {
    pre {
      name.length >= 0: "You must input a valid name."
    }
    post {
      result == "Jacob Tucker"
    }
    return name.concat(" Tucker")
  }

  pub resource TestResource {
    pub var number: Int

    // TODO
    // Tell me whether or not this function will log the updated number.
    // Also, tell me the value of `self.number` after it's run.
    pub fun numberThree(): Int {
      post {
        before(self.number) == result + 1
      }
      self.number = self.number + 1
      return self.number
    }

    init() {
      self.number = 0
    }

  }

}
```