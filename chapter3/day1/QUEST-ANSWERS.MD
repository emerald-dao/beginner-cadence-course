#1 In words, list 3 reasons why structs are different from resources.
> Reason 1:  
> **Structs** can be 'copied' into multiple vars and constants.  
> **Resources** can only exist once and should always be moved (``<-``) or destroyed (``destroy``).
> 
> Reason 2:   
> **Structs** can get lost or overwritten by new values.  
> **Resources** cannot get lost or overwritten. You could say this is the *non-fungible* element in Cadence.
>
> Reason 3:   
> **Structs** can be created in contracts, transactions and scripts.   
> **Resources** can only be created inside the contract by using the ``create`` keyword.
   
   
#2 Describe a situation where a resource might be better to use than a struct.
> If a developer wants to make sure the creation of an NFT happens as secure as possible he's better off by using the Resource element.
  
   
#3 What is the keyword to make a new resource?
> ``create``
  
   
#4 Can a resource be created in a script or transaction (assuming there isn't a public function to create one)?
> No. Resources can only be created inside the contract.
  
   
#5 What is the type of the resource below?
```swift
pub resource Jacob {

}
```
> The resource type is ``Jacob``
  
   
#6 Let's play the "I Spy" game from when we were kids. I Spy 4 things wrong with this code. Please fix them.

```swift
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
> Solution:  
> https://play.onflow.org/75ec7f86-b24d-4f02-ab45-c3c11bc7a0b5?type=account&id=d2e2c641-307c-4d5f-baaa-30d96ee6d842&storage=none
