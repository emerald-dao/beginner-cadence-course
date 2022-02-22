1. Explain why we wouldn't call `changeGreeting` in a script.
> The `changeGreeting` function that we wrote modifies data, you cannot do that with a Script. Scripts can only view the data on the blockchain.  

2. What does the `AuthAccount` mean in the `prepare` phase of the transaction?
>

3. What is the difference between the `prepare` phase and the `execute` phase in the transaction?

4. This is the hardest quest so far, so if it takes you some time, do not worry! I can help you in the Discord if you have questions.

- Add two new things inside your contract:
    - A variable named `myNumber` that has type `Int` (set it to 0 when the contract is deployed)
    - A function named `updateMyNumber` that takes in a new number named `newNumber` as a parameter that has type `Int` and updates `myNumber` to be `newNumber`

- Add a script that reads `myNumber` from the contract

- Add a transaction that takes in a parameter named `myNewNumber` and passes it into the `updateMyNumber` function. Verify that your number changed by running the script again.
