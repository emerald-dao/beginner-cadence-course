# Chapter 3 Day 2 - Resources in Dictionaries & Arrays

Hellooooooo peoples. Today we will be taking our understanding of Resources and applying it to arrays and dictionaries, something we covered in Chapter 2. On their own they may be somewhat easy to handle, but you put them together and it gets a bit complicated. 

## Video

You can watch this video from 08:00 - The End (we covered the beginning in the last day): https://www.youtube.com/watch?v=SGa2mnDFafc

## Why Dictionaries & Arrays?

First of all, why are we talking about resources in dictionaries, but not resources in structs? Well, it's important to note at the beginning that *you cannot store resources inside of a struct*. Although a struct is a container of data, we cannot put resources inside of them. 

Okay. So then where can we store a resource? 
1. Inside a dictionary or array
2. Inside another resource
3. As a contract state variable
4. Inside account storage (we will talk about this later)

That is all. Today, we will be talking about 1.

## Resources in Arrays

It's always better to learn by examples, so let's open up a Flow playground and deploy the contract we used in Chapter 3 Day 1:

```cadence
pub contract Test {

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

}
```

So far we just have 1 resource with the type `@Greeting`. Cool! Now let's try and have a state variable that stores a list of Greetings in an array.

```cadence
pub contract Test {

    pub var arrayOfGreetings: @[Greeting]

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    init() {
        self.arrayOfGreetings <- []
    }

}
```

Notice the type of `arrayOfGreetings`: `@[Greeting]`. We learned yesterday that resources always have the symbol `@` in front of it. This also applies to array types that have resources inside of them, you must tell Cadence it is an array of resources by putting the `@` in front of it. And you must make sure the `@` is outside the brackets, not inside. 

`[@Greeting]` - this is wrong

`@[Greeting]` - this is correct

Also notice that inside the `init` function, we initialize it with the `<-` operator, not `=`. Once again, when dealing with resources (whether they are in arrays, dictionaries, or on their own), we must use `<-`.

### Adding to an Array

Sweet! We made our own array of resources. Let's look at how to add a resource to an array.

*NOTE: Today, we will be passing resources around as arguments to our functions. This means we are not worrying about how the resources were created, we're just using sample functions to show you how to add to arrays and dictionaries.*

```cadence
pub contract Test {

    pub var arrayOfGreetings: @[Greeting]

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    pub fun addGreeting(greeting: @Greeting) {
        self.arrayOfGreetings.append(<- greeting)
    }

    init() {
        self.arrayOfGreetings <- []
    }

}
```

In this example, we added a new function `addGreeting` that takes in a `@Greeting` type and adds it to the array using the `append` function. Seems easy enough right? This is exactly what it looks like to append to an array normally, we just use the `<-` operator to "move" the resource into the array.

### Removing from an Array

Alright, we added to the array. Now how do we remove a resource from it? 

```cadence
pub contract Test {

    pub var arrayOfGreetings: @[Greeting]

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    pub fun addGreeting(greeting: @Greeting) {
        self.arrayOfGreetings.append(<- greeting)
    }

    pub fun removeGreeting(index: Int): @Greeting {
        return <- self.arrayOfGreetings.remove(at: index)
    }

    init() {
        self.arrayOfGreetings <- []
    }

}
```

Once again, it's pretty straightforward. In a normal array, you would use the `remove` function to take an element out. It is the same for resources, the only difference is you use the `<-` to "move" the resource out of the array. Awesome!

## Resources in Dictionaries

Resources in dictionaries is a bit more complicated. One of the reasons for this is because, if you remember from Chapter 2 Day 3, dictionaries always return optionals when you access the values inside of it. This makes storing and retrieving resources a lot more difficult. Either way, I would say that resources *most commonly get stored in dictionaries*, so it's important to learn how it's done.

Let's use a similar contract for this example:

```cadence
pub contract Test {

    pub var dictionaryOfGreetings: @{String: Greeting}

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    init() {
        self.dictionaryOfGreetings <- {}
    }

}
```

We will have a dictionary that maps a `message` to the `@Greeting` resource that contains that message. Notice the type of the dictionary: `@{String: Greeting}`. The `@` is outside the curly brackets.

### Adding to a Dictionary

There are 2 different ways to add a resource to a dictionary. Let's look at both.

#### #1 - Easiest, but Strict

The easiest way to add a resource to a dictionary is by using the "force-move" operator `<-!`, like so:

```cadence
pub contract Test {

    pub var dictionaryOfGreetings: @{String: Greeting}

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    pub fun addGreeting(greeting: @Greeting) {
        let key = greeting.message
        self.dictionaryOfGreetings[key] <-! greeting
    }

    init() {
        self.dictionaryOfGreetings <- {}
    }

}
```

In the `addGreeting` function, we first get the `key` by accessing the `message` inside our `greeting`. We then add to the dictionary by "force moving" the `greeting` into the `dictionaryOfGreetings` dictionary at the specific `key`.

The force-move operator `<-!` basically means: "If there is already a value at the destination, panic and abort the program. Otherwise, put it there."

#### #2 - Complicated, but Handle Duplicates

The second way to move a resource into a dictionary is by using the double move syntax, like so:

```cadence
pub contract Test {

    pub var dictionaryOfGreetings: @{String: Greeting}

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    pub fun addGreeting(greeting: @Greeting) {
        let key = greeting.message
        
        let oldGreeting <- self.dictionaryOfGreetings[key] <- greeting
        destroy oldGreeting
    }

    init() {
        self.dictionaryOfGreetings <- {}
    }

}
```

In this example, you can see some weird double move operator thing happening. What does it mean? Let's break it down into steps:
1. Take whatever value is at the specific `key` and move it into `oldGreeting`
2. Now that we know nothing is mapped to `key`, move `greeting` to that location
3. Destroy `oldGreeting`

In essence, this way is more annoying and looks weird, but it **allows you to handle the case where there's already a value there.** In the case above, we simply destroy the resource, but if you wanted to you could do anything else.

### Removing from a Dictionary

Here's how you would remove a resource from a dictionary:

```cadence
pub contract Test {

    pub var dictionaryOfGreetings: @{String: Greeting}

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    pub fun addGreeting(greeting: @Greeting) {
        let key = greeting.message
        
        let oldGreeting <- self.dictionaryOfGreetings[key] <- greeting
        destroy oldGreeting
    }

    pub fun removeGreeting(key: String): @Greeting {
        let greeting <- self.dictionaryOfGreetings.remove(key: key) ?? panic("Could not find the greeting!")
        return <- greeting
    }

    init() {
        self.dictionaryOfGreetings <- {}
    }

}
```

Remember in the 'Removing from an Array' section, all we had to do was call the `remove` function. In dictionaries, accessing an element return an optional, so we have to "unwrap" it somehow. If we had just written this...

```cadence
pub fun removeGreeting(key: String): @Greeting {
    let greeting <- self.dictionaryOfGreetings.remove(key: key)
    return <- greeting
}
```

we would get an error: "Mismatched types. Expected `Test.Greeting`, got `Test.Greeting?`" To fix it, we can either use `panic`, or the force-unwrap operator `!`, like so:

```cadence
pub fun removeGreeting(key: String): @Greeting {
    let greeting <- self.dictionaryOfGreetings.remove(key: key) ?? panic("Could not find the greeting!")
    // OR...
    // let greeting <- self.dictionaryOfGreetings.remove(key: key)!
    return <- greeting
}
```

## Conclusion

That's all for today! :D Now, you may be wondering: "What if I want to *access* an element of an array/dictionary that has a resource, and do something with it?" You can do that, but you would first have to move the resource out of the array/dictionary, do something, and then move it back in. Tomorrow we'll talk about references, which will allow you to do things with resources without having to move them everywhere. Peace!

## Quests

For today's quest, you'll have 1 large quest instead of a few little ones.

1. Write your own smart contract that contains two state variables: an array of resources, and a dictionary of resources. Add functions to remove and add to each of them. They must be different from the examples above.