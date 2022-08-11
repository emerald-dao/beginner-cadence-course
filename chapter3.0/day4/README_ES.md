# Capítulo 3 Día 4 - Interfaces de los Recursos/Structs

Oye oye oye! Ya volvimos para otro día divertido de Cadence. Hoy, vamos a aprender sobre los interfaces de los recursos. 

## Video

Si quieres ver una video sobre los interfaces de los recursos, puedes ir aquí: https://www.youtube.com/watch?v=5wnn9qsCXgE  

## ¿Qué es una Interfaz? 

Los interfaces son muy comunes en los idiomas tradicionales de programación. Hay dos cosas principales las interfaces son utilizan por: 
1. Especifica un conjunto de requisitos para algo que implementar
2. Le permite exponer solo ciertas cosas a ciertas personas

Miremos algún código para averiguar a qué me refiero. 

<img src="../images/interfaces.png" />

## Usando los interfaces como requisitos

En esta lección, yo voy a solamente usar interfaces de los recursos, sin embargo, **las interfaces de los structs son exactamente la misma cosa, pero para los structs. Jaja.** Tenlo en cuenta. 

En Cadence, interfaces de los recursos/structs son “requisitos” esencialmente, o maneras para exponer data de un recurso/structs. Por su cuenta, los interfaces no hacen nada. Simplemente se sientan allí. Pero cuando ellos son *aplicados* a un recurso/struct, eso es cuando ellos hacen algo.

Interfaces de los recursos son definidos con la palabra clave `resource interface` (para los structs es struct interface):

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

En el ejemplo arriba, puedes ver que hicimos dos cosas:
1. Definimos un `resource interface` vacío llamado `ITest`.
2. Definimos un `resource` llamado `Test`.

Personalmente, yo siempre llamo mis interfaces con un “I” al frente, porque me ayudó a determinar lo que realmente es. 

En el ejemplo de arriba, `ITest` no hace nada. Agreguemos algunas cosas a él. 

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

Ahora, `ITest` contiene un campo de nombre. ¡Genial! Pero todavía `ITest` no está haciendo nada. Así que, hagamos que `Test` a *implementar* la interfaz de recurso `ITest`.

```cadence
pub contract Stuff {

    pub resource interface ITest {
      pub let name: String
    }

    // ERROR: 
    // `resource Stuff.Test` no se ajusta
    //  a la interfaz de recurso Stuff.ITest` 
    pub resource Test: ITest {
      init() {

      }
    }
}
```

Tenga en cuenta lo que acabamos de hacer. Hicimos Test a implementar `ITest` añadiendo el sintaxi de `: ITest` . Que significa es, “Este recurso implementa los interfaces de los recursos después de la `:`”.

Pero puedes ver que hay un error: “recurso Stuff.Test no se conforma a la interfaz de recurso Stuff.ITest”. Recuerda lo que hemos dicho arriba? Los interfaces de los recursos son *requisitos*. Si un recurso implementa una interfaz de recurso, TIENE que definir las cosas en la interfaz. Vamos a arreglarlo. 

```cadence
pub contract Stuff {

    pub resource interface ITest {
      pub let name: String
    }

    // It's good now :)
    pub resource Test: ITest {
      pub let name: String
      init() {
        self.name = "Spongebob" // a alguien le gusta la esponja Bob?
      }
    }
}
```

¡Ahora no hay errores! ¡Wooo! 

## Usando los Interfaces para Exponer Cosas Específicas

Arriba, nosotros aprendimos que las interfaces de los recursos hace el recurso implementar cosas ciertas. Pero las interfaces de los recursos son realmente más importantes que eso. ¿Recuerdan la segunda cosa que ellos hacen? Hemos dicho que: “Le permite exponer cosas ciertas a personas ciertas”. ESO es por que ellos son tan poderosos. Veamos a continuación:

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
      log(test.number) // ERROR: `miembro de un tipo restrictivo no es accesible: number`

      destroy test
    }
}
```

Bueno, ¿qué acaba de pasar? Hay mucho pasando aquí: 
1. Hicimos una función llamado `noInterface`. Esta función crea un recurso nuevo (con el tipo de `@Test`) y registra su campo de `number`. Se funciona perfectamente. 
2. Hicimos una función llamado yesInterface. Esta función crea un recurso nuevo **que es restringido a la interfaz de `ITest`** (con type `@Test{ITest}`) e intenta a registrar el campo de `number`, pero falla. 

En Cadence, tu “restringir el tipo” de un recurso usando el notatacion de `{RESOURCE_INTERFACE}`. Usar los brackets `{}` y pones el nombre de la interfaz de recurso en el medio. Eso significa: “este tipo es de un recurso **que solamente puede usar cosas que son expone de la interfaz**.” Si entiendes esto, tú entiendes las interfaces de los recursos muy bien. 

Entonces, ¿por qué el `log` en yesInterface falla? Pues, es porque `ITest` no expone el campo de `number`. Así que si escribimos el variable de test a ser `@Test{ITest}`, no podremos acceder a él. 

## Ejemplo Complejo

Aquí es un ejemplo más complejo que también incluye funciones: 

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
        return self.number // devuelve el número nuevo
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
      let newNumber = test.updateNumber(newNumber: 5) // ERROR: `miembro de un tipo restrictivo no es accesible: updateNumber`
      log(newNumber)

      destroy test
    }
}
```

Quería mostrarte otro ejemplo para mostrarte que puedes también elegir a no exponer funciones. ¡Hay tan muchas cosas que puedes hacer! :D Sí quisiéramos arreglar este código, lo haríamos:

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
        return self.number // devuelve el número nuevo
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

    // Ahora trabaja perfectamente bien! :D
    pub fun yesInterface() {
      let test: @Test{ITest} <- create Test()
      let newNumber = test.updateNumber(newNumber: 5)
      log(newNumber) // 5

      destroy test
    }
}
```

Darse cuenta que cuando sume el funcion a `ITest`, yo solamente pongo la definición de la función: `pub fun updateNumber(newNumber : Int): Int`. No puedes implementar una función en un interfaz, solo puedes definirlo. 

## En Conclusión 

Buen trabajo en conseguir a través de el contenido de hoy. Los interfaces de los recursos van a ser súper importantes cuando empecemos a hablar sobre espacio de las cuentas en Capítulo 4. 

## Búsquedas

1. Explicar, en tus propias palabras, las 2 cosas las interfaces de los recursos se puede utilizar para (repasamos ambos en el contenido de hoy)

2. Definir en tu propio contrato. Hacer tu propio interfaz de recurso y un recurso que implemente la interfaz. Crea 2 funciones. En la primera función, muestra un ejemplo de no restringir el tipo de recurso y acceder a su contenido. En la segunda función, muestra un ejemplo de restricción del tipo de recurso y NO poder acceder a su contenido.

3. ¿Cómo arreglaremos este código?

```cadence
pub contract Stuff {

    pub struct interface ITest {
      pub var greeting: String
      pub var favouriteFruit: String
    }

    // ERROR:
    // `structure Stuff.Test no se ajusta 
    // a la interfaz de la estructura Stuff.ITest`
    pub struct Test: ITest {
      pub var greeting: String

      pub fun changeGreeting(newGreeting: String): String {
        self.greeting = newGreeting
        return self.greeting // devuelve el greeting nuevo
      }

      init() {
        self.greeting = "Hello!"
      }
    }

    pub fun fixThis() {
      let test: Test{ITest} = Test()
      let newGreeting = test.changeGreeting(newGreeting: "Bonjour!") // ERROR HERE: `miembro de un tipo restrictivo no es accesible: changeGreeting`
      log(newGreeting)
    }
}
```
