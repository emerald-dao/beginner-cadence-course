In a script, initialize an array (that has length == 3) of your favourite people, represented as Strings, and log it.
pub let myfavouritepeople : [String] = ["Jacob", "Jacob Tucker", "JacobmTucker"]

pub fun main(){
    log(myfavouritepeople)
}




In a script, initialize a dictionary that maps the Strings Facebook, Instagram, Twitter, YouTube, Reddit, and LinkedIn to a UInt64 that represents the order in which you use them from most to least. For example, YouTube --> 1, Reddit --> 2, etc. If you've never used one before, map it to 0!

pub let socialmedia : {String : UInt64} = {
    "Facebook" : 1,
    "Instagram" : 0,
    "Twitter" : 3,
    "YouTube" : 4,
    "Reddit" : 5,
    "LinkedIn" : 6
}









Explain what the force unwrap operator ! does, with an example different from the one I showed you (you can just change the type).

Force unwrap operator ! either returns a value, or panic and abort the program if nil

pub fun main(Whatevertheyinput : String): Int {
    let thing: {String: Int} = {"Hi": 1, "Bonjour": 2, "Hola": 3}
    return thing[Whatevertheyinput]! // we added the force-unwrap operator
}





Using this picture below, explain...

What the error message means
The error means the type of return (String?) does not match as it is expected (String).


Why we're getting this error
When you access an element of a dictionary, it returns as an optional.

How to fix it
1. To make the return type become an optional (String?) ; or
2. To force unwrap what the program returns -> return thing [0x03] !
