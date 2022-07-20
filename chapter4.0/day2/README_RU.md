# Глава 4 День 2 - Возможности

Во вчерашней главе мы говорили о пути `/storage/` к хранилищу учетной записи. Сегодня мы поговорим о путях `/public/` и `/private/`, а также о том, что такое возможности.

**ПРИМЕЧАНИЕ: ЭТА ГЛАВА МОЖЕТ СТАТЬ ОЧЕНЬ ЗАПУТАННОЙ**. Если вы почувствуете, что заблудились, я обниму вас виртуальным призраком. Обещаю, если вы прочтете ее несколько раз, то в конце концов все поймете.

## Видео

Вы можете посмотреть это видео с 14:45 и до конца (первую половину мы смотрели вчера): https://www.youtube.com/watch?v=01zvWVoDKmU

## Обзор от вчерашнего дня

<img src="../images/accountstorage1.PNG" />

Быстрый обзор:
1. Доступ к `/storage/` имеет только владелец аккаунта. Для взаимодействия с ним мы используем функции `.save()`, `.load()` и `.borrow()`.
2. `/public/` доступен для всех.
3. `/private/` доступен владельцу аккаунта и людям, которым владелец предоставляет доступ.

Для сегодняшней главы мы будем использовать вчерашний код контракта:

```cadence
pub contract Stuff {

  pub resource Test {
    pub var name: String
    init() {
      self.name = "Jacob"
    }
  }

  pub fun createTest(): @Test {
    return <- create Test()
  }

}
```

И не забудьте, что мы сохранили ресурс в наше хранилище вот так:
```cadence
import Stuff from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    let testResource <- Stuff.createTest()
    signer.save(<- testResource, to: /storage/MyTestResource) 
    // saves `testResource` to my account storage at this path:
    // /storage/MyTestResource
  }

  execute {

  }
}
```

Хорошо, мы готовы к работе.

## `/public/` путь

Раньше, когда мы сохраняли что-то в хранилище аккаунта, доступ к этому мог получить только владелец аккаунта. Это потому, что он сохранялся по пути `/storage/`. Но что, если мы хотим, чтобы другие люди могли прочитать поле `name` из моего ресурса? Ну, вы, наверное, догадались. Давайте сделаем наш ресурс общедоступным!

```cadence 
import Stuff from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // Links our resource to the public so other people can now access it
    signer.link<&Stuff.Test>(/public/MyTestResource, target: /storage/MyTestResource)
  }

  execute {

  }
}
```

В примере выше мы использовали функцию `.link()`, чтобы "привязать" наш ресурс к пути `/public/`. Проще говоря, мы взяли ресурс по адресу `/storage/MyTestResource` и открыли его для всех `&Stuff.Test`, чтобы они могли читать из него.

`.link()` принимает два параметра:
1. Путь `/public/` или `/private/`
2. параметр `target`, который представляет собой путь `/storage/`, где в настоящее время находятся данные, которые вы связываете

Теперь любой может запустить скрипт для чтения поля `name` на нашем ресурсе. Я покажу вам, как это сделать, но сначала мне нужно познакомить вас с некоторыми вещами.

## Возможности

Когда вы "связываете" что-то с путями `/public/` или `/private/`, вы создаете нечто, называемое возможностью. На самом деле ничто *не живет* в путях `/public/` или `/private/`, все живет в вашем `/storage/`. Однако мы можем думать о возможностях как об "указателях", которые указывают от пути `/public/` или `/private/` к связанному с ним пути `/storage/`. Вот полезная визуализация:

<img src="../images/capabilities.PNG" />

Самое интересное, что вы можете сделать ваши возможности `/public/` или `/private/` *более ограниченными*, чем то, что находится внутри вашего пути `/storage/`. Это очень здорово, потому что вы можете ограничить возможности других людей, но при этом позволить им делать некоторые вещи. Мы сделаем это с интерфейсами ресурсов позже.

## `PublicAccount` vs. `AuthAccount`

Мы уже узнали, что `AuthAccount` позволяет вам делать с аккаунтом все, что вы захотите. С другой стороны, `PublicAccount` позволяет любому читать с него, но только то, что раскрывает владелец аккаунта. Вы можете получить тип `PublicAccount`, используя функцию `getAccount` следующим образом:

```cadence
let account: PublicAccount = getAccount(0x1)
// `account` now holds the PublicAccount of address 0x1
```

Я говорю вам об этом потому, что единственный способ получить возможность из пути `/public/` - это использовать `PublicAccount`. С другой стороны, вы можете получить возможность из пути `/private/` только с помощью `AuthAccount`.

## Вернемся к `/public/`

Итак, мы выложили наш ресурс в открытый доступ. Давайте теперь прочитаем из него скрипт и применим кое-что из того, чему мы научились!

```cadence
import Stuff from 0x01
pub fun main(address: Address): String {
  // gets the public capability that is pointing to a `&Stuff.Test` type
  let publicCapability: Capability<&Stuff.Test> =
    getAccount(address).getCapability<&Stuff.Test>(/public/MyTestResource)

  // Borrow the `&Stuff.Test` from the public capability
  let testResource: &Stuff.Test = publicCapability.borrow() ?? panic("The capability doesn't exist or you did not specify the right type when you got the capability.")

  return testResource.name // "Jacob"
}
```

Отлично! Мы читаем имя нашего ресурса из пути `/public/`. Разберем на шаги:
1. Получаем публичный аккаунт, с которого мы читаем: `getAccount(address)`.
2. Получаем возможность, указывающую на тип `&Stuff.Test` по пути `/public/MyTestResource`: `getCapability<&Stuff.Test>(/public/MyTestResource)`.
3. Заимствуйте возможность, чтобы вернуть фактическую ссылку: `let testResource: &Stuff.Test = publicCapability.borrow() ?? panic("The capability is invalid")`.
4. Возвращаем имя: `return testResource.name`.

Вы можете задаться вопросом, почему нам не нужно указывать тип ссылки, когда мы выполняем `.borrow()`? Ответ заключается в том, что возможность уже указывает тип, поэтому она предполагает, что именно этот тип она заимствует. Если заимствуется другой тип, или возможность вообще не существовала, то возвращается `nil` и возникает panic.

## Использование публичных возможностей для ограничения типа

Отлично! Великолепно. Мы, по крайней мере, добрались до сюда, я горжусь вами. Следующая тема - выяснить, как ограничить определенные части нашей ссылки, чтобы `public` не могла делать то, чего мы не хотим.

Давайте определим другой контракт:

```cadence
pub contract Stuff {

  pub resource Test {
    pub var name: String

    pub fun changeName(newName: String) {
      self.name = newName
    }

    init() {
      self.name = "Jacob"
    }
  }

  pub fun createTest(): @Test {
    return <- create Test()
  }

}
```

В этом примере я добавил функцию `changeName`, которая позволяет изменить имя в ресурсе. Но что, если мы не хотим, чтобы любой мог это сделать? Сейчас у нас есть проблема:

```cadence
import Stuff from 0x01
transaction(address: Address) {

  prepare(signer: AuthAccount) {

  }

  execute {
    let publicCapability: Capability<&Stuff.Test> =
      getAccount(address).getCapability<&Stuff.Test>(/public/MyTestResource)

    let testResource: &Stuff.Test = publicCapability.borrow() ?? panic("The capability doesn't exist or you did not specify the right type when you got the capability.")

    testResource.changeName(newName: "Sarah") // THIS IS A SECURITY PROBLEM!!!!!!!!!
  }
}
```

Видите проблему? Поскольку мы связали наш ресурс с `public`, любой может вызвать `changeName` и изменить наше имя! Это несправедливо.

Решить эту проблему можно следующим образом:
1. Определите новый интерфейс ресурса, который раскрывает только поле `name`, но НЕ `changeName`.
2. Когда мы `.link()` ресурс к пути `/public/`, мы ограничиваем ссылку на использование этого интерфейса ресурса в шаге 1).

Давайте добавим интерфейс ресурса в наш контракт:

```cadence
pub contract Stuff {

  pub resource interface ITest {
    pub var name: String
  }

  // `Test` now implements `ITest`
  pub resource Test: ITest {
    pub var name: String

    pub fun changeName(newName: String) {
      self.name = newName
    }

    init() {
      self.name = "Jacob"
    }
  }

  pub fun createTest(): @Test {
    return <- create Test()
  }

}
```

Замечательно! Теперь `Test` реализует интерфейс ресурса под названием `ITest`, в котором есть только `name`. Теперь мы можем связать наш ресурс с `public`, сделав следующее:

```cadence 
import Stuff from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // Save the resource to account storage
    signer.save(<- Stuff.createTest(), to: /storage/MyTestResource)

    // See what I did here? I only linked `&Stuff.Test{Stuff.ITest}`, NOT `&Stuff.Test`.
    // Now the public only has access to the things in `Stuff.ITest`.
    signer.link<&Stuff.Test{Stuff.ITest}>(/public/MyTestResource, target: /storage/MyTestResource)
  }

  execute {

  }
}
```

Итак, что произойдет, если мы попытаемся получить доступ ко всей ссылке в скрипте, как мы делали раньше?

```cadence
import Stuff from 0x01
transaction(address: Address) {
  prepare(signer: AuthAccount) {

  }

  execute {
    let publicCapability: Capability<&Stuff.Test> =
      getAccount(address).getCapability<&Stuff.Test>(/public/MyTestResource)

    // ERROR: "The capability doesn't exist or you did not 
    // specify the right type when you got the capability."
    let testResource: &Stuff.Test = publicCapability.borrow() ?? panic("The capability doesn't exist or you did not specify the right type when you got the capability.")

    testResource.changeName(newName: "Sarah")
  }
}
```

Теперь мы получаем ошибку! Хаха, выкуси, хакер! Вы не можете заимствовать возможность, потому что вы пытались заимствовать возможность `&Stuff.Test`, а я не сделал ее доступной для вас. Я сделал доступным только `&Stuff.Test{Stuff.ITest}`. ;)

Что если мы попробуем сдедать так?

```cadence
import Stuff from 0x01
transaction(address: Address) {

  prepare(signer: AuthAccount) {

  }

  execute {
    let publicCapability: Capability<&Stuff.Test{Stuff.ITest}> =
      getAccount(address).getCapability<&Stuff.Test{Stuff.ITest}>(/public/MyTestResource)

    // This works...
    let testResource: &Stuff.Test{Stuff.ITest} = publicCapability.borrow() ?? panic("The capability doesn't exist or you did not specify the right type when you got the capability.")

    // ERROR: "Member of restricted type is not accessible: changeName"
    testResource.changeName(newName: "Sarah")
  }
}
```

И снова! Попался мошенник. Даже если вы заимствовали правильный тип, вы не можете вызвать `changeName`, потому что он недоступен через тип `&Stuff.Test{Stuff.ITest}`.

Но это сработает:

```cadence
import Stuff from 0x01
pub fun main(address: Address): String {
  let publicCapability: Capability<&Stuff.Test{Stuff.ITest}> =
    getAccount(address).getCapability<&Stuff.Test{Stuff.ITest}>(/public/MyTestResource)

  let testResource: &Stuff.Test{Stuff.ITest} = publicCapability.borrow() ?? panic("The capability doesn't exist or you did not specify the right type when you got the capability.")

  // This works because `name` is in `&Stuff.Test{Stuff.ITest}`
  return testResource.name
}
```

Именно так, как мы и хотели :)

## Заключение

Вот это да. На сегодняшний день вы узнали о Cadence безумно много. И что еще лучше, вы выучили все сложные вещи. Я очень, очень горжусь тобой.

Я также намеренно не стал углубляться в `/private/`. Это потому, что на практике вы редко будете использовать `/private/`, и я не хотел впихивать вам в голову слишком много информации. 

И, ну... Я голоден. Так что я собираюсь поесть. Может быть, я добавлю ее в эту главу позже ;)

## Квесты

Пожалуйста, не стесняйтесь, можете отвечать на выбранном вами языке.

1. Что делает `.link()`?

2. Объясните своими словами (без кода), как мы можем использовать интерфейсы ресурсов, чтобы открывать определенные вещи только для пути `/public/`.

3. Разверните контракт, содержащий ресурс, который реализует интерфейс ресурса. Затем сделайте следующее:

    1) В транзакции сохраните ресурс в хранилище и свяжите его с публичным ограниченным интерфейсом. 

    2) Запустите скрипт, который пытается получить доступ к незащищенному полю в интерфейсе ресурса, и увидите всплывающую ошибку.

    3) Запустите скрипт и получите доступ к чему-то, из чего можно читать. Верните его из скрипта.