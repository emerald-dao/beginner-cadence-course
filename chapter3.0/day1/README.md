# Chapter 3 Day 1 - Resources

Uh oh. We're on the most important topic in all of Cadence: Resources. Seriously, this is the most important thing you'll learn from me. Let's get into it!

## Video

1. You can watch this video from 00:00 - 08:00 (we will cover the rest later): https://www.youtube.com/watch?v=SGa2mnDFafc

## Resources

<img src="../images/resources.jpeg" alt="drawing" width="500" />

Resources are probably the most crucial element of Cadence, and the reason Cadence is so unique. By the way they look, **a Resource is a more secure Struct**. That's the simple way to put it. But more importantly, because of their securities, they are used in many interesting ways we will explore.

It's always helpful to look at code, so let's do that first:
```cadence
pub resource Greeting {
    pub let message: String
    init() {
        self.message = "Hello, Mars!"
    }
}
```

Doesn't this look very similar to a Struct? In code, they do actually look pretty similar. Here, the resource `Greeting` is a container that stores a message, which is a `String` type. But there are many, many differences behind the scenes.

### Resources vs. Structs

In Cadence, structs are merely containers of data. You can copy them, overwrite them, and create them whenever you want. All of these things are completely false for resources. Here are some important facts that define resources:

1. They cannot be copied
2. They cannot be lost (or overwritten)
3. They cannot be created whenever you want
4. You must be *extremely* explicit about how you handle a resource (for example, moving them)
5. Resources are much harder to deal with

Let's look at some code below to figure out resources:
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

There are so many important things happening here, so let's look at them in steps:

1. We initialize a resource type called `Greeting` that contains a `message` field. You know this already.
2. We define a function named `createGreeting` that returns a `Greeting` resource. Note that resources in Cadence use the `@` symbol in front of their type to say, "this is a resource."
3. We create a new `Greeting` type with the `create` keyword and assign it to `myGreeting` using the `<-` "move" operator. In Cadence, you cannot simply use the `=` to put a resource somewhere. You MUST use the `<-` "move operator" to explicity "move" the resource around.
4. We return the new `Greeting` by moving the resource again to the return value.

Okay, this is cool. But what if we *want* to destroy a resource? Well, we can do that pretty easily:

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
        // Note: This is the only time you don't use the 
        // `<-` operator to change the location of a resource.
    }
}
```

You can already see resources are very different from structs. We have to be much more communicative with how we handle resources. Let's look at some things we can't do with resources:
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

            You CANNOT do the above. This would "overwrite" 
            the myGreeting variable and effectively lose the 
            previous resource that is already stored there.
        */

        /*
            let copiedMyGreeting = myGreeting

            You CANNOT do the above. This would try to "copy"
            the myGreeting resource, which is not allowed. 
            Resources can never be copied. If you wanted to
            move the myGreeting "into" the copiedMyGreeting,
            you could do:

            let copiedMyGreeting <- myGreeting

            After you do this, myGreeting would store nothing 
            inside of it, so you could no longer use it.
        */

        /*
            return myGreeting
            
            You CANNOT do the above. You must explicity "move" 
            the resource using the <- operator like we do below.
        */
        return <- myGreeting
    }
}
```

So, why is this useful? Isn't this just super fricken annoying? No, haha. This is super useful actually. Let's say we want to give someone an NFT worth billions of dollars. Don't we want to make sure we don't lose that NFT? Like *really sure*? We can do this in Cadence because it's *so so so so so* hard to lose our Resource unless we LITERALLY tell it to destroy. This plays into the overall theme in Cadence: **Cadence makes it very hard for the developer to mess up. Which is good.**

Here's a summary of the differences between them:
- Structs are containers of data. That's it.
- Resources are extremely secure, hard to lose, impossible to copy, well kept-track-of containers of data that cannot be lost.

## A Few Coding Notes

Here are a few notes to learn for when you're actually coding:

- You can only make a new resource with the `create` keyword. The `create` keyword can only ever be used inside the contract. This means you, as the developer, can control when they are made. This is not true for structs, since structs can be created outside the contract.
- You have to use the `@` symbol in front of a resource's type, like so: `@Greeting`.
- You use the `<-` symbol to move a resource around.
- You use the `destroy` keyword to, well, destroy a resource.

## That Wasn't So Scary? 

Hey, you made it! That wasn't so bad right? I think you're all gonna do just fine. Let's end things there for today, and tomorrow, I'll make it impossible for you. Just kiddin' ;)

## Quests

As always, feel free to answer in the language of your choice.

1. In words, list 3 reasons why structs are different from resources.

2. Describe a situation where a resource might be better to use than a struct.

3. What is the keyword to make a new resource?

4. Can a resource be created in a script or transaction (assuming there isn't a public function to create one)?

5. What is the type of the resource below?

```cadence
pub resource Jacob {

}
```

6. Let's play the "I Spy" game from when we were kids. I Spy 4 things wrong with this code. Please fix them.

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