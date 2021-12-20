Quests
Please answer in the language of your choice.

Explain why we couldn't call changeGreeting in a script.
We can call changeGreeting in a script.

What does the AuthAccount mean in the prepare phase of the transaction?
AuthAccount means the account that signs the transaction.
in prepare phase of the transaction, we can access the data in the AuthAccount


What is the difference between the prepare phase and the execute phase in the transaction?
Prepare phase can access the AuthAccount's data and call functions / change status of the blockchain, where in execute phase we can only alter the staus of blockchain / call functions. But for the sake of clarity, we usually do things other than accessing account data in execute phase.


This is the hardest quest so far, so if it takes you some time, do not worry! I can help you in the Discord if you have questions.

Add two new things inside your contract:

A variable named myNumber that has type Int (set it to 0 when the contract is deployed)
A function named updateMyNumber that takes in a new number named newNumber as a parameter that has type Int and updates myNumber to be newNumber
Add a script that reads myNumber from the contract

pub contract HelloWorld {

    pub var greeting: String

    pub var myNumber : Int

    init() {
        self.greeting = "Hello, World!"
        self.myNumber = 0
    }

    pub fun changeGreeting(newGreeting: String) {
        self.greeting = newGreeting
    }

    pub fun updateMyNumber(newNumber: Int) {
        self.myNumber = newNumber
    }
}

Script :

import HelloWorld from 0x01

pub fun main(): Int {
  
  return HelloWorld.myNumber
}










Add a transaction that takes in a parameter named myNewNumber and passes it into the updateMyNumber function. Verify that your number changed by running the script again.


import HelloWorld from 0x01

transaction (myNewNumber : Int) {

  prepare(acct: AuthAccount) {}

  execute {
    HelloWorld.updateMyNumber(newNumber : myNewNumber)
  }
}
