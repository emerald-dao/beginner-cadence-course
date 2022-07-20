# Глава 3 День 4 - Интерфейсы ресурсов и структур

Йоооооо йо йо йо йо! Мы ВСТРЕТИЛИСЬ для очередного дня развлечений в Cadence. Сегодня мы будем изучать интерфейсы ресурсов.

## Видео

Если вы хотите посмотреть видео об интерфейсах ресурсов, то переходите сюда: https://www.youtube.com/watch?v=5wnn9qsCXgE

## Что такое интерфейс?

Интерфейсы очень распространены в традиционных языках программирования. Есть две основные вещи, для которых используются интерфейсы:
1. Они определяют набор требований к чему-либо для реализации
2. Это позволяет вам давать доступ к определенной информации только определенным людям

Давайте посмотрим на код, чтобы понять, что я имею в виду.

<img src="../images/interfaces.png" />

## Применение интерфейсов в качестве требований

В этом уроке я буду использовать только интерфейсы ресурсов, однако **интерфейсы структур - это то же самое, только для структур. Лол.** Просто имейте это в виду.

В Cadence интерфейсы ресурсов/структур - это, по сути, "требования", или способы предоставления данных из ресурсов/структур. Сами по себе интерфейсы ничего не делают. Они просто сидят там. Но когда они *применяются* к ресурсу/структуре, тогда они начинают что-то делать.

Интерфейсы ресурсов определяются с помощью ключевого слова `resource interface` (для структур это `struct interface`):

```cadence
pub contract Stuff {

    pub resource interface ITest {

    }

    pub resource Test {
      init() {
      }
    }
}
```

В приведенном выше примере вы можете видеть, что мы сделали две вещи:
1. Определили пустой `ресурсный интерфейс` с именем `ITest`.
2. Определили пустой `ресурс` с именем `Test`.

Лично я всегда называю интерфейсы через "I", потому что это помогает мне определить, что это действительно интерфейс.

В приведенном выше примере `ITest` на самом деле ничего не делает. Он просто сидит там. Давайте добавим к нему что-нибудь.

```cadence
pub contract Stuff {

    pub resource interface ITest {
      pub let name: String
    }

    pub resource Test {
      init() {
      }
    }
}
```

Теперь `ITest` содержит поле `name`. Круто! Но ITest по-прежнему ничего не делает. Он просто сидит там в пространстве. Поэтому давайте сделаем `Test` *реализацией* интерфейса ресурса `ITest`.

```cadence
pub contract Stuff {

    pub resource interface ITest {
      pub let name: String
    }

    // ERROR: 
    // `resource Stuff.Test does not conform
    // to resource interface Stuff.ITest`
    pub resource Test: ITest {
      init() {

      }
    }
}
```

Обратите внимание на то, что мы только что сделали. Мы заставили `Test` реализовать `ITest`, добавив синтаксис `: ITest`. Это означает: "Этот ресурс реализует интерфейсы ресурса после `:`".

Но вы заметите ошибку: "ресурс Stuff.Test не соответствует интерфейсу ресурса Stuff.ITest". Помните, что мы говорили выше? Интерфейсы ресурсов - это *требования*. Если ресурс реализует интерфейс ресурса, он ДОЛЖЕН определять вещи в интерфейсе. Давайте исправим это.

```cadence
pub contract Stuff {

    pub resource interface ITest {
      pub let name: String
    }

    // It's good now :)
    pub resource Test: ITest {
      pub let name: String
      init() {
        self.name = "Spongebob" // anyone else like Spongebob?
      }
    }
}
```

Теперь ошибок нет! Ух ты!

## Использование интерфейсов для раскрытия конкретных вещей

Выше мы узнали, что интерфейсы ресурсов заставляют ресурс реализовывать определенные вещи. Но интерфейсы ресурсов на самом деле гораздо мощнее. Помните 2-ю вещь, которую они делают? Мы сказали: "Это позволяет вам раскрывать определенные вещи только определенным людям". Именно поэтому они очень мощные. Давайте посмотрим ниже:

```cadence
pub contract Stuff {

    pub resource interface ITest {
      pub let name: String
    }

    pub resource Test: ITest {
      pub let name: String
      pub let number: Int
      init() {
        self.name = "Spongebob"
        self.number = 1
      }
    }

    pub fun noInterface() {
      let test: @Test <- create Test()
      log(test.number) // 1

      destroy test
    }

    pub fun yesInterface() {
      let test: @Test{ITest} <- create Test()
      log(test.number) // ERROR: `member of restricted type is not accessible: number`

      destroy test
    }
}
```

Ладно, что, черт возьми, только что произошло. Тут много чего происходит:
1. Мы создали функцию под названием `noInterface`. Эта функция создает новый ресурс (с типом `@Test`) и выводит его поле `number`. Это прекрасно работает.
2. Мы создали функцию под названием `yesInterface`. Эта функция создает новый ресурс **который ограничен интерфейсом `ITest`** (с типом `@Test{ITest}`) и пытается вывести поле `number`, но безуспешно.

В Cadence вы "ограничиваете тип" ресурса, используя нотацию `{RESOURCE_INTERFACE}`. Вы используете скобки `{}` и помещаете имя интерфейса ресурса в середину. Это означает: "этот тип является ресурсом **который может использовать только то, что раскрывается интерфейсом**". Если вы понимаете это, вы понимаете интерфейсы ресурсов очень хорошо.

Итак, почему же `log` в `yesInterface` не работает? Да потому что `ITest` НЕ раскрывает поле `number`! Поэтому, если мы напечатаем переменную `test` как `@Test{ITest}`, мы не сможем получить к ней доступ.

## Усложненный пример

Вот более сложный пример, который также включает функции:

```cadence
pub contract Stuff {

    pub resource interface ITest {
      pub var name: String
    }

    pub resource Test: ITest {
      pub var name: String
      pub var number: Int

      pub fun updateNumber(newNumber: Int): Int {
        self.number = newNumber
        return self.number // returns the new number
      }

      init() {
        self.name = "Spongebob"
        self.number = 1
      }
    }

    pub fun noInterface() {
      let test: @Test <- create Test()
      test.updateNumber(newNumber: 5)
      log(test.number) // 5

      destroy test
    }

    pub fun yesInterface() {
      let test: @Test{ITest} <- create Test()
      let newNumber = test.updateNumber(newNumber: 5) // ERROR: `member of restricted type is not accessible: updateNumber`
      log(newNumber)

      destroy test
    }
}
```

Я хотел показать вам еще один пример, чтобы показать, что вы также можете не раскрывать функции. Вы можете сделать так много вещей! :D Если бы мы хотели исправить этот код, мы бы это сделали так:

```cadence
pub contract Stuff {

    pub resource interface ITest {
      pub var name: String
      pub var number: Int
      pub fun updateNumber(newNumber: Int): Int
    }

    pub resource Test: ITest {
      pub var name: String
      pub var number: Int

      pub fun updateNumber(newNumber: Int): Int {
        self.number = newNumber
        return self.number // returns the new number
      }

      init() {
        self.name = "Spongebob"
        self.number = 1
      }
    }

    pub fun noInterface() {
      let test: @Test <- create Test()
      test.updateNumber(newNumber: 5)
      log(test.number) // 5

      destroy test
    }

    // Works totally fine now! :D
    pub fun yesInterface() {
      let test: @Test{ITest} <- create Test()
      let newNumber = test.updateNumber(newNumber: 5)
      log(newNumber) // 5

      destroy test
    }
}
```

Обратите внимание, что когда я добавил функцию в `ITest`, я поместил только определение функции: `pub fun updateNumber(newNumber: Int): Int`. Вы не можете реализовать функцию в интерфейсе, вы можете только определить ее.

## Заключение

Отличная работа по освоению сегодняшнего материала. Интерфейсы ресурсов будут чрезвычайно важны, когда мы начнем говорить о хранении аккаунтов в главе 4.

## Квесты

1. Объясните своими словами 2 вещи, для которых могут использоваться интерфейсы ресурсов (мы рассмотрели их в сегодняшнем материале)

2. Определите свой собственный контракт. Создайте собственный интерфейс ресурса и ресурс, реализующий этот интерфейс. Создайте 2 функции. В 1-й функции покажите пример отсутствия ограничения типа ресурса и доступа к его содержимому. Во 2-й функции покажите пример ограничения типа ресурса и невозможности доступа к его содержимому.

3. Как исправить этот код?

```cadence
pub contract Stuff {

    pub struct interface ITest {
      pub var greeting: String
      pub var favouriteFruit: String
    }

    // ERROR:
    // `structure Stuff.Test does not conform 
    // to structure interface Stuff.ITest`
    pub struct Test: ITest {
      pub var greeting: String

      pub fun changeGreeting(newGreeting: String): String {
        self.greeting = newGreeting
        return self.greeting // returns the new greeting
      }

      init() {
        self.greeting = "Hello!"
      }
    }

    pub fun fixThis() {
      let test: Test{ITest} = Test()
      let newGreeting = test.changeGreeting(newGreeting: "Bonjour!") // ERROR HERE: `member of restricted type is not accessible: changeGreeting`
      log(newGreeting)
    }
}
```