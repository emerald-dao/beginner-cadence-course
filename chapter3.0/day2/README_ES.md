# Capítulo 3 Día 2 - Recursos en Diccionarios y Arrays

Holaaaaa gente. Hoy, vamos a tomar nuestro entendimiento de los Recursos y aplicándola a arrays y diccionarios, algo que cubrimos en Capitúlo 2. En su propia manera ellos puede ser un poco fácil para manejar, pero los pones juntos y se complica un poco.

## Video

Puedes ver este video desde 08:00 - El Fin (cubrimos el principio en la ultima dia): https://www.youtube.com/watch?v=SGa2mnDFafc

## ¿Por qué Diccionarios & Arrays?

Primero, ¿por qué estamos hablando sobre recursos en diccionarios, pero no recursos en structs? Pues, es importante notar al principio que no puedes almacenar recursos dentro de un struct. Aunque un struct es un contenedor de data, no podemos poner recursos adentro el.

Bueno. Entonces donde podemos almacenar un recurso?
1. Adentro un diccionario o array
2. Adentro un otro recurso
3. Como un variable de estado de contrato 
4. Adentro un almacenamiento de una cuenta (hablamos sobre este más tarde)

Eso es todo. Hoy, hablamos sobre 1. 

## Recursos en Arrays

Es siempre mejor para aprender con los ejemplos, entonces abramos un Flow playground y desplegar el contrato nos usado en Capítulo 3 Día 1:

```cadence
pub contract Test {

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

}
```

Hasta ahora solo tenemos 1 recurso con el tipo de `@Greeting`. ¡Genial! Ahora intentemos a tener un variable de estado que almacena un listado de `Greetings` en un array. 

```cadence
pub contract Test {

    pub var arrayOfGreetings: @[Greeting]

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    init() {
        self.arrayOfGreetings <- []
    }

}
```

Darse cuenta que el tipo de `arrayOfGreetings`: `@[Greeting]`. Aprendimos ayer que los recursos siempre tiene el símbolo de `@` frente a él. Esto también se aplica a los tipos de arrays que tienen recursos dentro de ellos, debes decírselo a Cadence que es un array de recursos poniendo el `@` a frente de él. Debe asegurarse de que él `@` esté fuera de los soportes, no dentro. 

`[@Greeting]` - esto es incorrecto

`@[Greeting]` - esto es correcto

También darse cuenta que a dentro de la función de `init`, lo inicializamos con el operador `<-`, no `=`. Una vez más, cuando manejamos los recursos (si ellos están dentro de los arrays, diccionarios, o por su cuenta), tenemos que usar `<-`.

### Añadido a un Array

¡Genial! Hicimos nuestro propio array de los recursos. Miremos cómo añadir un recurso a un array.

*NOTA: Hoy, vamos a pasar recursos como argumentos a nuestras funciones. Esto significa que no vamos a preocuparnos sobre cómo se crearon los recursos, solo estamos usando funciones de ejemplos para mostrar como añadir a los arrays y diccionarios.*

```cadence
pub contract Test {

    pub var arrayOfGreetings: @[Greeting]

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    pub fun addGreeting(greeting: @Greeting) {
        self.arrayOfGreetings.append(<- greeting)
    }

    init() {
        self.arrayOfGreetings <- []
    }

}
```
En este ejemplo, sumamos una nueva función `addGreeting` que toman el tipo de `@Greeting` y añadirlo a el array usando la función de `append`. ¿Parece fácil cierto? Este es exactamente como se parece para agregar a un array normalmente, sólo usamos el operador `<-` para “mover” el recurso en el array. 

### Quitando de un Array

Bueno, hemos añadido a el array. Ahora cómo quitamos un recurso de él?

```cadence
pub contract Test {

    pub var arrayOfGreetings: @[Greeting]

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    pub fun addGreeting(greeting: @Greeting) {
        self.arrayOfGreetings.append(<- greeting)
    }

    pub fun removeGreeting(index: Int): @Greeting {
        return <- self.arrayOfGreetings.remove(at: index)
    }

    init() {
        self.arrayOfGreetings <- []
    }

}
```

Una vez más, es bastante sencillo. En un array normal, usaría la función de `remove` para quitar un elemento. Es lo mismo para recursos, la única diferencia es usas el  `<-` para “mover” el recurso afuera de el array. ¡Genial! 


## Recursos en Diccionarios

Recursos en diccionarios son un poco más complicados. Una de las razones de esto es porque, si recuerdas de Capitúlo 2 Día 3, diccionarios siempre devuelve opcionales cuando al acceder los valores dentro de él. Esto hace que almacenar y recuperar recursos sea mucho más difícil. De cualquier manera, diría que los recursos * más comúnmente se almacenan en diccionarios *, por lo que es importante aprender cómo se hace.

Usemos un contrato similar para este ejemplo: 

```cadence
pub contract Test {

    pub var dictionaryOfGreetings: @{String: Greeting}

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    init() {
        self.dictionaryOfGreetings <- {}
    }

}
```

Vamos a tener un diccionario que asigna una `message` a el recurso de `@Greeting` que contiene ese mensaje. Darse cuenta que el tipo del diccionario: `@{String: Greeting}`. El `@` está afuera de las llaves.  

### Añadido a un Diccionario

Hay 2 maneras diferentes para añadir un recurso a un diccionario. Miremos a los dos: 

#### #1. Lo más fácil, pero estricto

La manera más fácil para añadir un a recurso a un diccionario es usando el operador de movimiento forzado `<-!`, como así:

```cadence
pub contract Test {

    pub var dictionaryOfGreetings: @{String: Greeting}

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    pub fun addGreeting(greeting: @Greeting) {
        let key = greeting.message
        self.dictionaryOfGreetings[key] <-! greeting
    }

    init() {
        self.dictionaryOfGreetings <- {}
    }

}
```

En la función de `addGreeting`, primero nos conseguiremos la `key` accediendo el mensaje dentro de nuestro `greeting`. Entonces añadimos a el diccionario por “movimiento forzado” `greeting` en el diccionario de `dictionaryOfGreetings` a una `key` específica.

El operador de movimiento forzado `<-!` significa básicamente: “Si ya hay un valor en destino, pánico y abortar el programa. De lo contrario, póngalo allí”

#### #2 - Complicada, pero manejar duplicados

La segunda manera para mover un recurso en un diccionario es usando la sintaxis de doble movimiento, como así:

```cadence
pub contract Test {

    pub var dictionaryOfGreetings: @{String: Greeting}

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    pub fun addGreeting(greeting: @Greeting) {
        let key = greeting.message
        
        let oldGreeting <- self.dictionaryOfGreetings[key] <- greeting
        destroy oldGreeting
    }

    init() {
        self.dictionaryOfGreetings <- {}
    }

}
```

En este ejemplo, puedes ver algo extraño con el operador de doble movimiento que sucede. ¿Qué significa? Vamos a dividirlo en pasos:
1. Toma cualquier valor que esté en la `key` específica y moverlo a `oldGreeting`
2. Ahora que sabemos que no hay nada asignado a la `key`, movemos `greeting` a esa locación
3. Destruir `oldGreeting`

En esencia, esta manera es más molesto y parece raro, pero **te permite manejar el caso donde ya hay un valor allí**. En el caso de arriba, nos destruir el recurso, pero si querías puedes hacer cualquier otra cosa.

### Quitando de un Diccionario

Aquí es cómo eliminaría un recurso de un diccionario:


```cadence
pub contract Test {

    pub var dictionaryOfGreetings: @{String: Greeting}

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    pub fun addGreeting(greeting: @Greeting) {
        let key = greeting.message
        
        let oldGreeting <- self.dictionaryOfGreetings[key] <- greeting
        destroy oldGreeting
    }

    pub fun removeGreeting(key: String): @Greeting {
        let greeting <- self.dictionaryOfGreetings.remove(key: key) ?? panic("Could not find the greeting!")
        return <- greeting
    }

    init() {
        self.dictionaryOfGreetings <- {}
    }

}
```

Recuerda en la sección de ‘Quitando de un Array’ todo lo que teníamos que hacer fue llamar la función de `remove`. En diccionarios, accediendo un elemento devuelve un opcional, entonces tenemos que “desenvolver” el, de alguna manera. Si acabáramos de escribir esto..

```cadence
pub fun removeGreeting(key: String): @Greeting {
    let greeting <- self.dictionaryOfGreetings.remove(key: key)
    return <- greeting
}
```

obtendríamos un error: “Tipos no coincidentes. `Test.Greeting` esperado, consiguió `Test.Greeting?`” Para resolverlo podemos utilizar pánico, o el operador de desenvolver a la fuerza `!`, como así:

```cadence
pub fun removeGreeting(key: String): @Greeting {
    let greeting <- self.dictionaryOfGreetings.remove(key: key) ?? panic("Could not find the greeting!")
    // OR...
    // let greeting <- self.dictionaryOfGreetings.remove(key: key)!
    return <- greeting
}
```

## En Conclusión

¡Eso es todo para hoy! :D Ahora, te estarás preguntando: “Que si quiero *acceder* un elemento de un array/diccionario que tiene un recurso, y hacer algo con él?” Puedes hacer eso, pero tienes que primero mover el recurso afuera del array/diccionario, hacer algo, y muévelo hacia atrás. Mañana vamos a hablar sobre referencias, las cuales le permitirán hacer cosas con recursos sin tener que moverlos a todas partes. ¡Chao! 

## Búsquedas

Para la búsqueda de hoy, vas a tener 1 busqueda grande en vez de algunas búsquedas pequeñas.
1. Escribir tu propio smart contract que contiene dos variables de estado: un array de recursos, y un diccionario de recursos. Añadir funciones para quitar y añadir a cada uno de ellos. Ellos tienen que ser diferentes de los ejemplos arriba. 
