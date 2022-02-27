#1 In a script, initialize an array (that has length == 3) of your favourite people, represented as Strings, and log it.
> See Script -> Quest 1  
> https://play.onflow.org/93d9c08f-6778-42d1-bd48-8408c6d523b9?type=script&id=2c530e2f-2d53-4764-afc4-f0af59f6cf6b&storage=none

#2 In a script, initialize a dictionary that maps the Strings Facebook, Instagram, Twitter, YouTube, Reddit, and LinkedIn to a UInt64 that represents the order in which you use them from most to least. For example, YouTube --> 1, Reddit --> 2, etc. If you've never used one before, map it to 0!
> See Script -> Quest 2  
> https://play.onflow.org/93d9c08f-6778-42d1-bd48-8408c6d523b9?type=script&id=ac9df7cc-231f-4dac-825f-4535135bce35&storage=none

#3 Explain what the force unwrap operator ! does, with an example different from the one I showed you (you can just change the type).
> See Scripts & comments -> Quest 3 simple/dict  
> https://play.onflow.org/93d9c08f-6778-42d1-bd48-8408c6d523b9?type=script&id=86676fb1-db7b-42a9-82f3-44ec0ec8a5ad&storage=none  
> https://play.onflow.org/93d9c08f-6778-42d1-bd48-8408c6d523b9?type=script&id=cd55be4f-805f-4539-ad3a-61890646f26f&storage=none  

#4 Using this picture below, explain...
<img src="https://github.com/Keukendeur/Flow-Zero-to-Jacob/blob/main/chapter2/images/wrongcode.png" alt="drawing" size="200" />

What the error message means
> The return statement of the function on line 3 cannot define the Type of thing[0x03].

Why we're getting this error
> _**!! When accessing values of a dictionary, the Types of these values will always be retrieved as Optionals**_ -> ``<Type>?``.  
> In this case, the function is expecting a ``String`` as defined in line 1, but it got an Optional String in return on line 3 -> ``String?``.

How to fix it
> _**!! Optionals always need to be "unwrapped" before you can use them in a statement.**_  
> To unwrap Optionals, you need to add the force-unwrap operator to the end of the statement -> ``!``.  
> In this case we need to change ``return thing[0x03]`` to ``return thing[0x03]!``  
> See Script -> Quest 4  
> https://play.onflow.org/93d9c08f-6778-42d1-bd48-8408c6d523b9?type=script&id=10e0900b-e642-4ff0-98e3-6fe34bee62f8&storage=none

