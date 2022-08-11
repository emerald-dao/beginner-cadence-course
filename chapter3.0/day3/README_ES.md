# Capítulo 3 Día 3 - Las Referencias 

¿Que pasa? Hoy, vamos a hablar sobre referencias, una otra parte importante de la idioma de programación Cadence.

## Video

Si quieres ver una video sobre Referencias, puedes va aquí: https://www.youtube.com/watch?v=mI3KC-5e81E 

## ¿Qué es una referencia?

En las condiciones más simples, una referencia es una manera para interactuar con un pedazo de data sin tener que tener ese dato. Imagina un mundo donde no tienes que mover un recurso 1,000 veces para mirar o cambiar sus campos. Ahh, este mundo existe! Las referencias están aquí para salvar el día.

## Las referencias en Cadence

En Cadence, las referencias son *casi siempre* usadas en los Structs o Recursos. En realidad no tiene sentido hacer una referencia de un string, numero, o tipo de data basico. Pero ciertamente no tiene sentido hacer una referencia de cosas que nos queremos pasar mucho.

Las referencias siempre usan el símbolo `&` al frente de él. Miremos a un ejemplo: 

```cadence
pub contract Test {

    pub var dictionaryOfGreetings: @{String: Greeting}

    pub resource Greeting {
        pub let language: String
        init(_language: String) {
            self.language = _language
        }
    }

    pub fun getReference(key: String): &Greeting? {
        return &self.dictionaryOfGreetings[key] as &Greeting?
    }

    init() {
        self.dictionaryOfGreetings <- {
            "Hello!": <- create Greeting(_language: "English"), 
            "Bonjour!": <- create Greeting(_language: "French")
        }
    }
}
```

En el ejemplo arriba, puedes ver que `getReference` devuelve un tipo de `&Greeting?`, cual simplemente significa, “Una referencia de opcional a el tipo de `@Greeting`.” Adentro el funccion, algunas cosas son pasando: 

1. Primero, nos consiguió una referencia de el valor a `key` haciendo `&self.dictionaryOfGreeting[key]`. 
2. Nos “type-cast” la referencia haciendo `&Greeting?`. Tenga en cuenta que es un opcional, cúal hace sentido porque cuando indexamos en los diccionarios, devuelve un tipo de opcional. 

Tenga en cuenta que si lo hubiéramos olvidado el `as &Greeting?`, Cadence dirían “expresión de conversión esperada.” Esto es porque en Cadence, **tienes que type cast cuando consigues una referencia**. Type casting es cuando se le dice a Cadence que el tipo que está obteniendo la referencia como, cual es que `as &Greeting?` está haciendo. Es diciendo “obtener esta referencia opcional que es una referencia &Greeting". Si no es así, abortaremos el programa.

Ahora, te estarás preguntando “¿cómo puedo desenvolver esta referencia de opcional?” Puedes hacerlo como así: 
```cadence
pub fun getReference(key: String): &Greeting {
    return (&self.dictionaryOfGreetings[key] as &Greeting?)!
}
```

Tenga en cuenta que envolvemos toda la cosa y usar el operador de desenvolver a la fuerza `!` para desenvolverse, como normal. También se cambia el tipo de devuelve a un no opcional `&Greeting`. Asegurarse de cambiar este en tú código. 

Ahora que podemos conseguir una referencia, podemos conseguir la referencia en una transacción o guión como así: 

```cadence
import Test from 0x01

pub fun main(): String {
  let ref = Test.getReference(key: "Hello!")
  return ref.language // devuelve "English"
}
```

Darse cuenta de que no teníamos que mover el recurso a cualquier parte para hacer esto! Esa es la belleza de las referencias. 

## En Conclusión

Las referencias no son tan malas cierto? Los puntos principales son:
1. Puedes usar referencias para conseguir información sin mover recursos. 
2. Tienes que “type cast” una referencia cuando al recibirlo, o recibirá un error.

Las referencias no van a desaparecer. Ellos van a ser SÚPER importantes cuando vamos a hablar sobre el espacio de las cuentas en el próximo capítulo. 

## Búsquedas

1. Definir tú propio contrato que guarda un diccionario de los recursos. También añadir una función para conseguir una referencia a uno de los recursos en el diccionario. 

2. Crear un guión que lees la información de ese recurso usando la referencia de la función que se definió en parte 1. 

3. Explicar, en tus propias palabras, por qué las referencias pueden ser útiles en Cadence.
