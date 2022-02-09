# Chapter 2 Day 4 - Basic Structs

Hello idiots. Today is your day to learn Structs! The good news is structs are pretty simple to learn, so today won't be too long. Woooohoooo! Let's get into it.

## Video

1. (Structs + Dictionaryies & Optionals) - Watch this video from 12:10-The End: https://www.youtube.com/watch?v=LAUN7hqlL0w

## Structs

What are structs? Structs are containers of other types. Let's look at an example:

```swift
pub struct Profile {
    pub let firstName: String
    pub let lastName: String
    pub let birthday: String
    pub let account: Address

    // `init()` gets called when this Struct is created...
    // You have to pass in 4 arguments when creating this Struct.
    init(_firstName: String, _lastName: String, _birthday: String, _account: Address) {
        self.firstName = _firstName
        self.lastName = _lastName
        self.birthday = _birthday
        self.account = _account
    }
}
```

Okay, there's a lot going on there. What happened? Basically, we defined a new Type named `Profile`. It is a Struct. As you can see, it contains 4 pieces of data: 
1. a first name (firstName)
2. a last name (lastName)
3. a birthday (birthday)
4. an account address (account)

It is really helpful to make a Struct when we want information to be gathered together in a container. 

Let's think about why this is helpful. Let's say we go to make a new script in the Flow playground and we want to return someone's profile information. How would we do that? Without a Struct, we would have to return an array of Strings (`[String]`) that contained all the information, convert the `account` parameter to a `String`, etc. That's a lot of effort and pain. Instead, we could just return a Profile struct. Let's go to a real example.

Notice also that Structs have the `init()` function that gets called when the Struct gets created, much like the `init()` function that gets called when the contract is deployed. In addition, you'll notice I tend to use "_" before my variable names in `init()` functions. This is just something I do to distinguish between the actual variable and the initialized value.

**Important**: Structs can only be defined inside of a Smart Contract and can only ever have the `pub` access modifier (which we'll talk about in future days). Let's look at a real example.

## Real Example

Let's start off by deploying a new Smart Contract to account `0x01`:

```swift
pub contract Authentication {

    pub var profiles: {Address: Profile}
    
    pub struct Profile {
        pub let firstName: String
        pub let lastName: String
        pub let birthday: String
        pub let account: Address

        // You have to pass in 4 arguments when creating this Struct.
        init(_firstName: String, _lastName: String, _birthday: String, _account: Address) {
            self.firstName = _firstName
            self.lastName = _lastName
            self.birthday = _birthday
            self.account = _account
        }
    }

    pub fun addProfile(firstName: String, lastName: String, birthday: String, account: Address) {
        let newProfile = Profile(_firstName: firstName, _lastName: lastName, _birthday: birthday, _account: account)
        self.profiles[account] = newProfile
    }

    init() {
        self.profiles = {}
    }

}
```

I threw a lot at you here. But you actually know all of it now! We can break it down:

1. We defined a new contract named `Authentication`
2. We defined a dictionary named `profiles` that maps an `Address` Type to a `Profile` Type
3. We defined a new Struct called `Profile` that contains 4 arguments
4. We defined a new function named `addProfile` that takes in 4 arguments and creates a new `Profile` with them. It then creates a new mapping from `account` -> the `Profile` associated with that account
5. Initializes `profiles` to an empty dictionary when the contract is deployed

If you can understand these things, you've made significant progress. If you're struggling with this a bit, no worries! I would maybe review some of the concepts from the past few days. And remember, you don't have to know what `pub` means yet.

### Add a new Profile

Now that we've defined a new Struct, let's see why it can be helpful.

Let's open a new transaction and copy and paste this boilerplate transaction code:

```swift
import Authentication from 0x01

transaction() {

    prepare(signer: AuthAccount) {}

    execute {
        log("We're done.")
    }
}
```

Cool! Now, we want to add a new profile to the `profiles` dictionary in the `Authentication` contract. How can we do this? Well, let's call the `addProfile` function with all the arguments we need like so: `Authentication.addProfile(firstName: firstName, lastName: lastName, birthday: birthday, account: account)`. But wait, we need to get these arguments from somewhere first! We can do that by passing them into the transaction as arguments, like so:

```swift
import Authentication from 0x01

transaction(firstName: String, lastName: String, birthday: String, account: Address) {

    prepare(signer: AuthAccount) {}

    execute {
        Authentication.addProfile(firstName: firstName, lastName: lastName, birthday: birthday, account: account)
        log("We're done.")
    }
}
```

Bam! Let's run this transaction with any account and pass in some example data like so:

<img src="../images/txstuff.png" alt="drawing" size="400" />

### Read our Profile

To read our new Profile, let's open up a Script and copy and paste the boilerplate script code:

```swift
import Authentication from 0x01

pub fun main() {

}
```

Now, let's try to read our Profile. We can do this by passing in an `Address` that represents an account, since we mapped accounts -> profiles in our `profiles` dictionary in the contract. We can then return the `Profile` type we get from that dictionary, like so:

```swift
import Authentication from 0x01

pub fun main(account: Address): Authentication.Profile {
    return Authentication.profiles[account]
}
```

Aha! WAIT A MINUTE JACOB! There's an error: "mismatched types. expected `Authentication.Profile`, got `Authentication.Profile?`" Well, we know how to fix that from yesterday's content. We have to add the force-unwrap operator, like so: 

```swift
import Authentication from 0x01

pub fun main(account: Address): Authentication.Profile {
    return Authentication.profiles[account]!
}
```

Also notice the return type here: `Authentication.Profile`. That is because we are returning a `Profile` type defined in the `Authentication` contract. And boom! That's it. Now, whoever called this script can have all the profile information they need. Sweet, Structs are awesome!

## Quests

1. Deploy a new contract that has a Struct of your choosing inside of it (must be different than `Profile`).

2. Create a dictionary or array that contains the Struct you defined.

3. Create a function to add to that array/dictionary.

4. Add a transaction to call that function in step 3.

5. Add a script to read the Struct you defined.

That's all! See you tomorrow folks ;)