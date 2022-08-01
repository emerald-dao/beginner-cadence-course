# Capítulo 3 Día 1 - Recursos

Oh, oh. Estamos en la tópica más importante de todo de Cadence: Recursos. En serio, esta es la cosa más importante que vas a aprender de mí. ¡Empecemos! 

## Video

Puedes ver este video desde 00:00 - 08:00 (vamos a cubrir el resto más tarde): https://www.youtube.com/watch?v=SGa2mnDFafc 

## Recursos

<img src="../images/resources.jpeg" alt="drawing" width="500" />

Los recursos son probablemente el elemento más crucial de Cadence, y la razón por la que Cadence es tan único. Por la forma en que se vea, **un recurso es como un Struct pero más seguro**. Esa es la manera más fácil para ponerlo. Pero más importante, porque de su seguridad, se utilizan en muchas maneras interesantes que vamos a explorar. 

Es siempre útil para mirar a el código, hagamos eso primero: 
```cadence
pub resource Greeting {
    pub let message: String
    init() {
        self.message = "Hello, Mars!"
    }
}
```

¿No se parece similar a un Struct? En código, en realidad se ven similares. Aquí, el recurso `Greeting` es un contenedor que almacena un mensaje, cúal es un tipo de `String`. Pero hay muchos, muchos différences entre bastidores.

### Recursos v. Structs

En Cadence, structs solo son contenedores de data. Puedes cópialos, sobreescribirlos, y crearlos cuando quieras. Todas esas cosas son completamente falsas para los recursos. Aquí están algunas cosas importantes que definen recursos:

1. No se puede copiar
2. No se pueden perder (o sobrescribir)
3. No se puede crear cuando se deseas
4. Tienes que ser super explícito sobre cómo te manejas un recurso (por ejemplo, moverlos)
5. Recursos son más difícil para manejarlo

Miremos a algún código para entender recursos mejor:
```cadence
pub contract Test {

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    pub fun createGreeting(): @Greeting {
        let myGreeting <- create Greeting()
        return <- myGreeting
    }
}
```

Hay muchas cosas importantes pasando aqui, asi que miremos a ellos en pasos: 

1. Inicializamos un tipo de recurso llamado `Greeting` que contiene un campo de `message`. Ya sabemos esto. 
2. Definimos un función llamado `createGreeting` que devuelves un recurso de `Greeting`. Tenga en cuenta que recursos en Cadence usan el símbolo de `@` al frente de su tipo para decir, “este es un recurso.”
3. Creamos un nuevo tipo de `Greeting` con la palabra clave `create` y lo asignamos a `myGreeting` usando el operador de “mueve” `<-`. En Cadence, no puedes simplemente usar el `=` para poner un recurso en algún lugar. 
4. Devolvemos el nuevo `Greeting` moviendo el recurso de nuevo a el valor de devolver.

Bueno, esto es genial. Pero si *quieres* destruir un recurso? Pues, podemos hacer eso bastante fácil:

```cadence
pub contract Test {

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    pub fun makeAndDestroy() {
        let myGreeting <- create Greeting()
        destroy myGreeting 
        // Nota: Esta es la única vez que no usas el operador 
        // `<-` para cambiar el lugar de un recurso.
    }
}
```

Ya puedes ver como los recursos son muy diferentes de los structs. Tenemos que ser mucho más comunicativos con cómo manejamos recursos. Miremos a algunas cosas no podemos hacer con recursos:
```cadence
pub contract Test {

    pub resource Greeting {
        pub let message: String
        init() {
            self.message = "Hello, Mars!"
        }
    }

    pub fun createGreeting(): @Greeting {
        let myGreeting <- create Greeting()

        /*
            myGreeting <- create Greeting()

            No puedes hacer lo anterior. Esto sobrescribirá el variable 
            de myGreeting y efectivamente perder los recursos 
            previos que ya está almacenado.
        */

        /*
            let copiedMyGreeting = myGreeting

            NO puedes hacer lo anterior. Esto intentaría copiar
            el recurso de myGreeting, que no está permitido. 
            Resources can never be copied. If you wanted to
            Si quería mover el myGreeting en el copiedMyGreeting,
            usted podría hacer: 

            let copiedMyGreeting <- myGreeting

            Después de hacer esto, no almacenaría nada dentro 
            de él, así que ya no podías usarlo.
        */

        /*
            return myGreeting
            
            NO puedes hacer lo anterior. Tienes que “mover” el recurso
            explícitamente usando el operador de <- cómo hacemos debajo.
        */
        return <- myGreeting
    }
}
```

Entonces, ¿por qué es este util? ¿No es super molesto? No, jaja. Esto es  útil realmente. Digamos que queremos dar a alguien un NFT que vale millones de dólares. Queremos asegurarnos de no perder eso, cierto? Podemos hacer esto en Cadence porque es *muy muy muy* difícil perder nuestro recurso a menos que se lo decimos a destruir. Esto juega con el tema general en Cadence: **Cadence hace que sea difícil para el desarrollador cometer un error. Cúal es bien.**

Aquí es un resumen de los diferencias entre ellos:
- Structs son contenedores de datos. Eso es todo.
- Los recursos son muy seguros, difícil a perder, imposible copiar, seguimiento bien cuidado de los contenedores de datos que no se pueden perder. 

## Algunas Notas de Codificación 

Aquí son algunas notas para aprender para cuando estás codificando realmente:
- Solo puedes hacer un nuevo recurso con la palabra clave `create`. La palabra clave `create` sólo puede ser usada dentro de un contrato. Esto significa que tú, como el desarrollador, puedes controlar donde ellos son creados. Eso no es verdadero para los structs, ya que los structs se pueden crear fuera de un contrato.
- Tienes que usar el símbolo de `@` al frente de el tipo de un recurso, como así: `@Greeting`.
- Tienes que usar el símbolo de `<-` para mover un recurso.
- Tienes que usar la palabra clave `destroy` para, pues, destruir un recurso. 

## No Era Tan Miedoso

¡Oye, te hiciste! ¿No era tan malo? Creo que lo harás muy bien. Terminemos cosas allí para hoy, y mañana, voy a hacerlo imposible para ti. ;)

## Búsquedas

Como siempre, sientes libre para contestar en el idioma de tu preferencia. 

1. En palabras, listar 3 razones por las que los structs son diferentes desde recursos. 

2. Describir una situación donde un recurso podría ser mejor a usar que un struct. 

3. ¿Cuál es la palabra clave para hacer un nuevo recurso?

4. ¿Puede un recurso ser creado en un guión o transacción (suponiendo que no hay un función pública para crearlo)?

5. Cúal es el tipo de el recurso debajo: 
```cadence
pub resource Jacob {

}
```

Jugamos el juego de “Veo, veo..” desde que eran niños. Veo, veo 4 cosas mal con este código. Por favor, arréglalo. 
```cadence
pub contract Test {

    // Pista: No hay nada malo aquí ;)
    pub resource Jacob {
        pub let rocks: Bool
        init() {
            self.rocks = true
        }
    }

    pub fun createJacob(): Jacob { // hay 1 aquí
        let myJacob = Jacob() // hay 2 aquí
        return myJacob // hay 1 aquí
    }
}
```
