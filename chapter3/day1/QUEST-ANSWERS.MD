1. In words, list 3 reasons why structs are different from resources.
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

2. Describe a situation where a resource might be better to use than a struct.
> A developer strictly secured Cadence makes it very hard for the developer to mess up

3. What is the keyword to make a new resource?
> CREATE
