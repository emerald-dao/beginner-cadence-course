# Глава 2 День 4 - Основные структуры

Привет, идиоты! Сегодня ваш день для изучения структур! Хорошая новость в том, что структуры довольно просты в изучении, поэтому сегодняшний день не будет слишком долгим. Уууууууууу! Давайте приступим.

## Видео

1. (Структуры + словари и необязательные типы) - Смотрите видео с 12:10 и до конца: https://www.youtube.com/watch?v=LAUN7hqlL0w

## Структуры

Что такое структуры? Структуры - это контейнеры других типов. Давайте рассмотрим пример:

```cadence
pub struct Profile {
    pub let firstName: String
    pub let lastName: String
    pub let birthday: String
    pub let account: Address

    // `init()` gets called when this Struct is created...
    // Вы должны передать 4 аргумента при создании этой структуры.
    init(_firstName: String, _lastName: String, _birthday: String, _account: Address) {
        self.firstName = _firstName
        self.lastName = _lastName
        self.birthday = _birthday
        self.account = _account
    }
}
```

Ладно, там много чего происходит. Что произошло? В основном, мы определили новый тип с именем `Profile`. Он представляет собой структуру. Как вы можете видеть, он содержит 4 части данных: 
1. имя (`firstName`)
2. фамилия (`lastName`)
3. дата рождения (`birthday`)
4. адрес аккаунта (`account`)

Очень полезно создавать структуру, когда мы хотим, чтобы информация была собрана в контейнере. 

Давайте подумаем, почему это полезно. Допустим, мы создаем новый сценарий в Flow playground и хотим вернуть информацию о чьем-то профиле. Как бы мы это сделали? Без структуры нам пришлось бы возвращать массив строк (`[String]`), содержащий всю информацию, преобразовывать параметр `account` в `String` и т.д. Это много усилий и боли. Вместо этого мы могли бы просто возвращать структуру Profile. Перейдем к реальному примеру.

Заметьте также, что у структур есть функция `init()`, которая вызывается при создании структуры, так же как и функция `init()`, которая вызывается при развертывании контракта. Кроме того, вы заметите, что я обычно использую "_" перед именами переменных в функциях `init()`. Это просто то, что я делаю, чтобы отличить фактическую переменную от инициализированного значения. Это НЕ то же самое, что синтаксис неявной метки аргумента `_`. Знаю, я сложный человек.

**Важно**: Структуры могут иметь только модификатор доступа `pub` (о котором мы поговорим в следующих днях). Давайте рассмотрим реальный пример.

## Реальный пример

Давайте начнем с развертывания нового смарт-контракта на счете `0x01`:

```cadence
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

Я много всего на тебя вывалил. Но теперь вы действительно все это знаете! Мы можем разбить это на части:

1. Мы определили новый контракт под названием `Authentication`
2. Мы определили словарь под названием `profiles` который сопоставляет `Address` Тип к `Profile` Типу
3. Мы определили новую структуру под названием `Profile` который содержит 4 поля
4. Мы определили новую функцию с именем `addProfile` которая принимает 4 аргумента и создает новый `Profile` с ним. Затем он создает новое сопоставление из `account` -> `Profile` связанные с этим аккаунтом
5. Инициализирует `profiles` в пустой словарь при развертывании контракта

Если вы можете понять эти вещи, вы достигли значительного прогресса. Если вы испытываете трудности, не волнуйтесь! Я бы, возможно, пересмотрел некоторые понятия за последние несколько дней. И помните, что вы еще не должны знать, что означает `pub`.

### Добавление нового профиля

Теперь, когда мы определили новую структуру, давайте посмотрим, почему она может быть полезной.

Давайте откроем новую транзакцию, скопируем и вставим этот шаблонный код транзакции:

```cadence
import Authentication from 0x01

transaction() {

    prepare(signer: AuthAccount) {}

    execute {
        log("We're done.")
    }
}
```

Круто! Теперь мы хотим добавить новый профиль в словарь `profiles` в контракте `Authentication`. Как мы можем это сделать? Ну, давайте вызовем функцию `addProfile` со всеми необходимыми аргументами следующим образом: `Authentication.addProfile(firstName: firstName, lastName: lastName, birthday: birthday, account: account)`. Но подождите, сначала нам нужно откуда-то получить эти аргументы! Мы можем сделать это, передав их в транзакцию в качестве аргументов, например, так:

```cadence
import Authentication from 0x01

transaction(firstName: String, lastName: String, birthday: String, account: Address) {

    prepare(signer: AuthAccount) {}

    execute {
        Authentication.addProfile(firstName: firstName, lastName: lastName, birthday: birthday, account: account)
        log("We're done.")
    }
}
```

Бам! Давайте запустим эту транзакцию с любым аккаунтом и передадим некоторые данные следующим образом:

<img src="../images/txstuff.png" alt="drawing" size="400" />

### Чтение нашего профиля

Чтобы прочитать наш новый Профиль, давайте откроем скрипт, скопируем и вставим код скрипта:

```cadence
import Authentication from 0x01

pub fun main() {

}
```

Теперь попробуем прочитать наш профиль. Мы можем сделать это, передав `Address`, который представляет аккаунт, поскольку мы сопоставили аккаунты -> профили в нашем словаре `profiles` в контракте. Затем мы можем вернуть тип `Profile`, который мы получили из этого словаря, например, так:

```cadence
import Authentication from 0x01

pub fun main(account: Address): Authentication.Profile {
    return Authentication.profiles[account]
}
```

Ага! Подождите минутку, Джейкоб! Есть ошибка: "несовпадение типов. Ожидалось `Authentication.Profile`, получено `Authentication.Profile?`". Ну, мы знаем, как это исправить из вчерашнего материала. Мы должны добавить оператор force-unwrap, например, так: 

```cadence
import Authentication from 0x01

pub fun main(account: Address): Authentication.Profile {
    return Authentication.profiles[account]!
}
```

Также обратите внимание на возвращаемый тип: `Authentication.Profile`. Это потому, что мы возвращаем тип `Profile`, определенный в контракте `Authentication`. **Типы всегда основаны на контракте, в котором они определены.** И бум! Вот и все. Теперь, кто бы ни вызвал этот скрипт, он может получить всю необходимую информацию о профиле. Отлично, структуры - это здорово!

## Квесты

1. Разверните новый контракт, внутри которого находится написанная вами структура (она должна отличаться от `Profile`).

2. Создайте словарь или массив, содержащий определенную вами структуру.

3. Создайте функцию для добавления в этот массив/словарь.

4. Добавьте транзакцию для вызова этой функции в шаге 3.

5. Добавьте скрипт для чтения определенной вами структуры.

Вот и все! До завтра, друзья ;)