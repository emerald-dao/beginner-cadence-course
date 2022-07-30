# Capítulo 2 Día 3 - Arrays, Diccionarios, & Opcionales

Qué está pasando noobs de Cadence. Hoy, vamos a aprender algunos de los tipos más importante que te va a usar en casi todo los contratos te escribas. 

## Video

Este es en orden:

(Arrays y Diccionarios en Cadence) Mira este video desde 00:00-12:10. No mirar pasado a las 12:10, que se cubrirá mañana: https://www.youtube.com/watch?v=LAUN7hqlL0w 

(Opcionales en Cadence) Mira este video: https://www.youtube.com/watch?v=I9Z1z9BsZ0I 

## Tipos

Para empezar jugando con tipos, abramos el Flow playground (https://play.onflow.org) y abrir un guión. No vamos a escribir ninguna smart contracts hoy :) 

En Cadence, el código que te escribas a menudo puede inferir que tipo algo es. Por ejemplo, si escribas: 
```cadence
var jacob = "isCool"
```

Automáticamente Cadence se da cuenta que te has registrado un String. Sin embargo, si queremos ser más explícito sobre nuestros tipos, podemos incluir el tipo en la declaración, como así: 
```cadence
var jacob: String = "isCool"
```

A menudo es útil para incluir el tipo de algo así que podemos razonar sobre dónde nos equivocamos en nuestro programas. Cadence también le dirá si cometió un error si pretendía que una variable fuera de diferente tipo. Por ejemplo, intenta tecleando:
```cadence
var jacob: String = 3
```

Cadence se va a decir “Oye! Estos tipos no coinciden.” O algo como eso. Pero el punto es que podemos incluir tipos para ayudarnos a entender donde salimos mal. 

## Arrays

Genial. Entonces, ¿qué es un array? Un array es como una lista de elementos. Vamos a ver un array muy básico en Cadence: 
```cadence
var people: [String] = ["Jacob", "Alice", "Damian"]
```

Esta es una lista de String. Declaramos un tipo de array como así: `[Tipo]`. Hacemos otro ejemplo. Si queremos una lista de direcciones, pues, es muy similar:
```cadence
var addresses: [Address] = [0x1, 0x2, 0x3]
```

También podemos indexar en arrays para ver qué elementos son. Este es exactamente como Javascript o idiomas similares. 

```cadence
var addresses: [Address] = [0x1, 0x2, 0x3]
log(addresses[0]) // 0x1
log(addresses[1]) // 0x2
log(addresses[2]) // 0x3
```

### Útiles Funciones de Arrays que Uso Todo el Tiempo

Las cosas que miramos arribas todos son arrays fijados. También podemos hacer algunas cosas super genial con arrays, y enumerar algunos aquí: 

**append(_ elemento: Tipo)**

(nota que el `elemento` de argument label tiene un `_` frente a el, cúal significa que es implícito, pero no tienes que poner el argument label cuando te llamas él función. Así que en vez de `.append(elemento: valor)`, puedes hacer `.append(valor)`)

Añadir un elemento al final del array. 

Ejemplo:
```cadence
var people: [String] = ["Jacob", "Alice", "Damian"]
people.append("Ochako Unaraka") // alguien viste My Hero Academia? :D
log(people) // ["Jacob", "Alice", "Damian", "Ochako Unaraka"]
```

**contains(_ elemento_: Tipo): Bool**

Cheques para ver si un array contiene un elemento. 

Ejemplo:
```cadence
var people: [String] = ["Jacob", "Alice", "Damian"]
log(people.contains("Jacob")) // verdadero
log(people.contains("Poop")) // falso
```

**remove(at: Int)**

Quita a un elemento en el índice dado (índice empiezas desde 0, significando el primero elemento tienes el índice de 0)

Ejemplo:
```cadence
var people: [String] = ["Jacob", "Alice", "Damian"]
people.remove(at: 1)
log(people) // ["Jacob", "Damian"]
```

**length**

Devuelvas el largo de un array. 

Ejemplo:
```cadence
var people: [String] = ["Jacob", "Alice", "Damian"]
log(people.length) // 3
```

## Diccionarios

¡Genial! Ahora es tiempo para diccionarios. Pues, ¿qué son ellos? Un diccionario es algo que asigna una clave, `key` con un valor, `value`. Vamos a ver a un ejemplo debajo:

```cadence
var names: {String: String} = {"Jacob": "Tucker", "Bob": "Vance", "Ochako": "Unaraka"} // cualquiera mira la oficina
```

En el ejemplo de arriba, ponemos `String`s a `String`s. Más específicamente, ponemos el nombre de alguien a su apellido. Lo hicimos con el tipo de diccionario, cuál es `{Tipo:Tipo}`. Podemos usar este diccionario para conseguir los apellidos de personas como así:

```cadence
var names: {String: String} = {"Jacob": "Tucker", "Bob": "Vance", "Ochako": "Unaraka"}
log(names["Jacob"]) // "Tucker"
log(names["Bob"]) // "Vance"
log(names["Ochako"]) // "Unaraka"
```

Miremos a un ejemplo de poniendo Strings a Ints. Vamos a poner el nombre de alguien a su número favorito. 

```cadence
var favouriteNums: {String: Int} = {"Jacob": 13, "Bob": 0, "Ochako": 1000100103}
log(favouriteNums["Jacob"]) // 13
```

Eso es genial. Pero hay más. Entraremos en por qué diccionarios son más complicados en la sección de diccionarios y opcionales en la parte inferior. 

## Útiles Funciones de Diccionarios que Uso Todo el Tiempo

**insert(clave: Tipo, _ valor: Tipo)**

(nota el valor, `value` de argument label es implícito, pero la clave, `key` no es)

Ejemplo:
```cadence
var favouriteNums: {String: Int} = {"Jacob": 13, "Bob": 0, "Ochako": 1000100103}
favouriteNums.insert(key: "Justin Bieber", 1)
log(favouriteNums) // {"Jacob": 13, "Bob": 0, "Ochako": 1000100103, "Justin Bieber": 1}
```

**remove(clave: Tipo): Tipo?**

Quita la clave, `key`, y valor asociadas a ella, y devuelvas ese valor. 

Ejemplo:
```cadence
var favouriteNums: {String: Int} = {"Jacob": 13, "Bob": 0, "Ochako": 1000100103}
let removedNumber = favouriteNums.remove(key: "Jacob")
log(favouriteNums) // {"Bob": 0, "Ochako": 1000100103}
log(removedNumber) // 13
```

**claves: [Tipo]**

Devuelve un array con todas las claves en el diccionario. 

Ejemplo:
```cadence
var favouriteNums: {String: Int} = {"Jacob": 13, "Bob": 0, "Ochako": 1000100103}
log(favouriteNums.keys) // ["Jacob", "Bob", "Ochako"]
```

**valores: [Tipo]**

Devuelve un array con todos los valores en el diccionario. 

Ejemplo:
```cadence
var favouriteNums: {String: Int} = {"Jacob": 13, "Bob": 0, "Ochako": 1000100103}
log(favouriteNums.values) // [13, 0, 1000100103]
```

## Opcionales

Bueno, así que ahora estamos en opcionales. Opcionales son tan importantes, pero puede ser difícil. Tú probablemente vas a encontrar opcionales en todo lo que haces en Cadence. La mayoría de las veces, será porque de diccionarios. 

Un `tipo opcional` en Cadence es representado con un `?`. Se significa: “Es o bien el tipo que está diciendo o `nil`”. Jacob, que acabas de decir? Miremos a un ejemplo: 

```cadence
var name: String? = "Jacob"
```

Darse cuenta de la `?` después de `String`. Eso significa “el nombre de la variable es o bien un String, o es nil.” Obviamente, sabemos que es un `String` porque es igual a “Jacob”. Pero también podemos tener algo como así: 

```cadence
var name: String? = nil
```

Esto no tendrá ningún error de compilación, porque es correcto. Un tipo de `String?` Puede ser `nil`.

No tan mal cierto? Soy la mejor profesor de todos los tiempos. Todos ustedes son tan afortunados por tenerme aquí.

### El Operador de Desenvolver a la Fuerza

Esto nos lleva a el operador de desenvolver a la fuerza, `!`. Este operador, “desenvuelve” un tipo opcional diciendo: “Si esta cosa es nil, pánico! Si no es nil, estamos bien, pero deshágase del tipo opcional.” Pues, ¿qué significa? Miramos: 

```cadence
var name1: String? = "Jacob"
var unwrappedName1: String = name1! // Darse cuenta se quita el tipo de opcional

var name2: String? = nil
var unwrappedName2: String = name2! // Pánico! Todo el programa se cancelará porque encontró un problema. Intentó desenvolver un nil, lo cual no está permitido
```

## Opcionales y Diccionarios

Esto es donde vamos a combinar todo lo que sabemos para hablar sobre opcionales y diccionarios. Antes, cuando explico diccionarios, dejé fuera un pedazo clave de la información. Cuando tenga acceso al elemento de un diccionario, se devuelva el valor como un **opcional**. ¿Qué significa? Miremos a un ejemplo debajo:

Bueno, tenemos este diccionario:
```cadence
let thing: {String: Int} = {"Hi": 1, "Bonjour": 2, "Hola": 3}
```

¡Genial! Ahora queremos a registrar el valor que es igual a la clave de “Bonjour”:
```cadence
let thing: {String: Int} = {"Hi": 1, "Bonjour": 2, "Hola": 3}
log(thing["Bonjour"]) // se va a imprimir 2
```

Se va a imprimir 2 como hemos mostrado anteriormente. Así que no *parece* raro. Pero en realidad es. Hacemos un nuevo guión que parece como así:

```cadence
pub fun main(): Int {
    let thing: {String: Int} = {"Hi": 1, "Bonjour": 2, "Hola": 3}
    return thing["Bonjour"] // ERROR: "Mismatched types. expected `Int`, got `Int?`"
}
```

Eso nos dará un ERROR! El error dice “tipos no coincidentes, esperados `Int`, tiene `Int?`” Pues sabemos que `Int?` que significa ahora! Se significa que es un opcional, así que el puede ser `Int` or `nil`. Para resolver este error, tenemos que usar el operador de desenvolver a la fuerza `!`, como así:

```cadence
pub fun main(): Int {
    let thing: {String: Int} = {"Hi": 1, "Bonjour": 2, "Hola": 3}
    return thing["Bonjour"]! // nos añadimos el operador de desenvolver a la fuerza
}
```

Ahora, no hay errores :D

### Devolviendo Opcionales v. Desenvolviendo

Es posible que esté preguntando, “hay alguna vez donde quiero devolver un opcional en lugar de desenvolvimiento forzado el opcional?” La respuesta es sí. De hecho, la mayoría de veces, es preferible devolver un opcional en lugar de desenvolver. Por ejemplo, mirando a este código: 

```cadence
pub fun main(): Int {
    let thing: {String: Int} = {"Hi": 1, "Bonjour": 2, "Hola": 3}
    return thing["Bonjour"]! // estamos desenvolvimiento forzado el opcional
}
```

…esto provocará `pánico` y anulará el programa si no hay un valor a la clave de “Bonjour”. En su lugar podemos escribir código como así: 

```cadence
pub fun main(): Int? { // notice the return value is an optional type
    let thing: {String: Int} = {"Hi": 1, "Bonjour": 2, "Hola": 3}
    return thing["Bonjour"] // dejamos el opcional
}
```

En esta manera, el cliente/la persona que llama puede manejar el caso donde el valor de devolver es `nil`, en lugar de tener que preocuparse sobre errores en el programa. Lo mismo lógico aplicar a otras funciones en tu código de Cadence también.

### El Punto Principal

El punto principal de todo es que cuando accediendo los valores de un diccionario, siempre obtendrá opcionales de vuelta. Así que si quieres el *tipo real* y no el opcional, tienes que “desenvolver” usando el operador de desenvolver a la fuerza `!`.

## Busquedas

1. En un guión, inicializa un array (que tiene length == 3) de tus personas favoritas, representados como `String`s, y registralo. 

2. En un guión, inicializar un diccionario que establece los `String`s Facebook, Instagram, Twitter, YouTube, Reddit y LinkedIn a un `UInt64` que representa el orden en que te usas ellos, de más a menos. Por ejemplo, YouTube → 1, Reddit →2, etc. Si no has usado uno de ellos antes, registrarlo a 0!

3. Explicar lo que el operador de desenvolver a la fuerza `!` hace, con un ejemplo diferente de la que te mostré (puedes cambiar el tipo).

4. Usando esta foto debajo, explicaré..
- Que significa el mensaje de error
- Por qué estamos conseguindo este error
- Cómo solucionarlo

<img src="../images/wrongcode.png" alt="drawing" size="400" />
