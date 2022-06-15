# Chapter 3 Day 3 - References

What's up Flow people. Today, we'll be talking about references, another important part of the Cadence programming language.

## Video

If you'd like to watch a video on References, you can go here: https://www.youtube.com/watch?v=mI3KC-5e81E

## What is a Reference?

In simplest terms, a reference is a way for you to interact with a piece of data without actually having to have that piece of data. Right off the bat, you can imagine how helpful this will be for resources. Imagine a world where you don't have to move a resource 1,000 times just to look at or update its fields. Ahh, that world does exist! References are here to save the day.

## References in Cadence

In Cadence, references are *almost always* used on Structs or Resources. It doesn't really make sense to make a reference of a string, number, or basic data type. But it certainly makes sense to make a reference of things we don't want to pass around a lot. 

References always use the `&` symbol in front of them. Let's look at an example:

```cadence
pub contract Test {

    pub var dictionaryOfGreetings: @{String: Greeting}

    pub resource Greeting {
        pub let language: String
        init(_language: String) {
            self.language = _language
        }
    }

    pub fun getReference(key: String): &Greeting? {
        return &self.dictionaryOfGreetings[key] as &Greeting?
    }

    init() {
        self.dictionaryOfGreetings <- {
            "Hello!": <- create Greeting(_language: "English"), 
            "Bonjour!": <- create Greeting(_language: "French")
        }
    }
}
```

In the above example, you can see that `getReference` returns a `&Greeting?` type, which simply means "An optional reference to the `@Greeting` type." Inside the function, a few things are happening:
1. We first get a reference of the value at `key` by doing `&self.dictionaryOfGreetings[key]`. 
2. We "type cast" the reference by doing `as &Greeting?`. Notice that it is an optional, which makes sense because when we index into dictionaries, it returns an optional type.

Notice that if we had forgotten the `as &Greeting?`, Cadence would yell at us and say "expected casting expression." This is because in Cadence, **you have to type cast when getting a reference**. Type casting is when you tell Cadence the type you're getting the reference as, which is what `as &Greeting?` is doing. It's saying "get this optional reference that is a &Greeting reference." If it's not, we will abort the program.

Now, you might be wondering "how can I unwrap this optional reference?" You can do that like so:
```cadence
pub fun getReference(key: String): &Greeting {
    return (&self.dictionaryOfGreetings[key] as &Greeting?)!
}
```

Notice that we wrap the whole thing and use the force-unwrap operator `!` to unwrap it, like normal. It also changes the return type to a non-optional `&Greeting`. Make sure to change this in your code.

Now that we can get a reference, we can get the reference in a transaction or script like so:

```cadence
import Test from 0x01

pub fun main(): String {
  let ref = Test.getReference(key: "Hello!")
  return ref.language // returns "English"
}
```

Notice we didn't have to move the resource anywhere in order to do this! That's the beauty of references. 

## Conclusion

References aren't so bad right? The main two points are:
1. You can use references to get information without moving resources around.
2. You MUST "type cast" a reference when getting it, or you'll receive an error.

References are not going to go away, though. They will be EXTREMELY important when we talk about account storage in the next chapter.

## Quests

1. Define your own contract that stores a dictionary of resources. Add a function to get a reference to one of the resources in the dictionary.

2. Create a script that reads information from that resource using the reference from the function you defined in part 1. 

3. Explain, in your own words, why references can be useful in Cadence.

