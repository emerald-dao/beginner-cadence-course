//Deploy a new contract that has a Struct of your choosing inside of it (must be different than Profile).

//Create a dictionary or array or the Struct you defined.

//Create a function to add to that array/dictionary.
pub contract Setup {

    pub var AllInformation : {Address : Information}

    pub struct Information{
        pub let account : Address
        pub let name : String
        pub let age : UInt64
        pub let flowlover : Bool
    

    
        init(_account : Address , _name : String , _age : UInt64 , _flowlover : Bool){
        self.account = _account
        self.name = _name
        self.age = _age
        self.flowlover = _flowlover
        
        }
    }

    pub fun addInformation(account : Address , name : String , age : UInt64 , flowlover : Bool) {
        self.AllInformation[account] = Information(_account : account , _name : name , _age : age , _flowlover : flowlover)
    }

    init(){
    self.AllInformation = {}
    }
}

//Add a transaction to call that function in step 3.
import Setup from 0x01

transaction (account : Address , name : String , age : UInt64 , flowlover : Bool) {

  prepare(acct: AuthAccount) {}

  execute {
    Setup.addInformation(account: account, name: name, age: age, flowlover: flowlover)
    
  }
}

//Add a script to read the Struct you defined.
import Setup from 0x01

pub fun main(account:Address) : Setup.Information? {
  return Setup.AllInformation[account]
}
