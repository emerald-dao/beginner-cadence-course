# Capítulo 5 Día 1 - Condiciones de Pre/Post

Hoy, vamos a aprender 2 conceptos que, aunque muy fáciles, son muy comunes en Cadence. 

## Video

Condiciones de Pre/Post: https://www.youtube.com/watch?v=WFqoCZY36b0 

Eventos: https://www.youtube.com/watch?v=xRHG6Kgkxpg 

## Condiciones de Pre/Post

Hasta ahora, solo aprendemos de 1 manera para abortar un programa si algo no es correcto: la palabra clave `panic`. `panic` es una palabra clave que completamente revierte que paso en el código si es llamado, y se envía una mensaje junto con él. 

```cadence
pub fun main(): String {
  let a: Int = 3

  if a == 3 {
    panic("Este guión nunca funcionará porque siempre entrará en pánico en esta línea.")
  }

  return "Nunca llegaré a esta línea."
}
```

Este es como un tonto ejemplo, pero tu entiendes. Nunca volverá porque siempre entrará en pánico.

A veces, queremos manejar los errores de una manera más clara, y también implementar un concepto llamado “failed fast”. En el blockchain, las operaciones son muy caras. Eso es por que las transacciones cuestan cuotas caras. “Fail fast” es una manera de programación así que tu código falla lo antes posible si algo es incorrecto, entonces no pierda más tiempo de ejecución sin ninguna razón.

Las condiciones de pre/post son perfectas para este. Ellos nos permiten especificar una manera muy clara para fallar si algo es incorrecto antes (pre) o después (post) que una función es llamada. Miremos a una ejemplo: 

```cadence
pub contract Test {

  pub fun logName(name: String) {
    pre {
      name.length > 0: "This name is too short."
    }
    log(name)
  }

}
```

En el ejemplo de arriba, definimos un “pre-condition” en la función `logName`. Dice “si el largo de name no es mayor que 0, pánico con este mensaje: ‘Este nombre es demasiado baja.’”

Los condiciones de pre/post **tienes** que ser definido como la primera cosa de una función, no puedes ponerlos en la mitad o al final. En orden para una condición de pre/post a pasar, la condición tiene que ser `true`(verdad), o si no entrará en `panic`(pánico) con la string después.

Los condiciones de post son la misma cosa, excepto que se comprueban al final de una función (ellos todavía tienen que ser definidos al principio. Yo se, es confuso, pero te acostumbrarás): 

```cadence
pub contract Test {

  pub fun makePositiveResult(x: Int, y: Int): Int {
    post {
      result > 0: "The result is not positive."
    }
    return x + y
  }

}
```

Te estarás preguntando: “¿qué es eso variable de `result`? Nunca lo definimos.” Estas correcto! Los condiciones son super genial porque ellos son juntos con un variable de `result` que es igual a el valor que es siendo devuelto. Así que devolvemos x + y, `result` va a representar eso. Si no hay un valor de devolver, `result` no existen. 

Adicionalmente, puedes usar una función de `before()` dentro tu condición de post para acceder el valor de algo antes de que la función modifique esa cosa, incluso después de que la función haya tenido lugar.

```cadence
pub contract Test {

  pub resource TestResource {
    pub var number: Int

    pub fun updateNumber() {
      post {
        before(self.number) == self.number - 1
      }
      self.number = self.number + 1
    }

    init() {
      self.number = 0
    }

  }

}
```

El código de arriba siempre va a funcionar, porque la condición de post es satisfado. Dice “después el función de `updateNumber` es ejecutan, asegúrese de que el número actualizado es 1 mayor que el valor antes de ejecutar esta función.” Cúal es siempre verdad en este caso. 

### Nota Importante

Es importante para aprender que la palabra clave `panic` o las condiciones de pre/post que realmente hacen. Ellos “abortar” una transacción, lo cual significa que ninguno de los estados realmente cambian. 

Ejemplo:
```cadence
pub contract Test {

  pub resource TestResource {
    pub var number: Int

    pub fun updateNumber() {
      post {
        self.number == 1000:  "Siempre panico!" // cuando esto entra en pánico después de ejecutar la función, `self.number` se establece de nuevo a 0
      }
      self.number = self.number + 1
    }

    init() {
      self.number = 0
    }

  }

}
```

## Eventos

Los eventos son una manera para los smart contracts de comunicar al mundo exterior que algo pasó. 

Por ejemplo, si creamos (mint) un NFT, queremos que el mundo exterior que sabe que un NFT fue creado. Por supuesto, podríamos simplemente verificar el contrato para ver si el `totalSupply` se actualizó o algo, pero eso es muy ineficiente. ¿Por qué no teníamos el contrato para *contarnos*? 

Aquí es cómo puedes definir un evento en Cadence: 

```cadence
pub contract Test {

  // Definir un evento aquí
  pub event NFTMinted(id: UInt64)

  pub resource NFT {
    pub let id: UInt64

    init() {
      self.id = self.uuid

      // Transmitir el evento al mundo exterior
      emit NFTMinted(id: self.id)
    }

  }

}
```

Puedes ver que definimos un evento llamado `NFTMinted` como así: `pub event NFTMinted(id: UInt64)`. Nota que los eventos siempre son `pub`/`access(all)`. Entonces transmitimos el evento usando la palabra clave `emit`, que lo envían a la blockchain. 

También puedes pasar los parámetros dentro el evento así que puedes enviar el data a el mundo exterior. En este caso, queríamos contar al mundo que un NFT con un id cierto era creado, así que cualquier cliente que esté leyendo nuestros eventos sabe que ese NFT especificado fue creado.

El propósito de este es para que los clientes (las personas leyendo de nuestro contrato) puedan saber cuando algo pasó, y actualizar su código en consecuencia. Tal vez podemos crear un sitio web super genial que dispara fuegos artificiales cada vez que un NFT es creado! :D

## En Conclusión

Eso es todo para hoy! Espero que disfrutes la lección más corta. 

## Búsquedas

1. Describir qué es un evento, y ¿por qué puede ser útil a un cliente? 

2. Desplegar un contrato con un evento, y emitir el evento en otro lugar en el contrato señalando que paso. 

3. Usando el contrato de paso 2, añadir algunas condiciones de pre y post a tu contrato para acostumbrarse a escribirlos. 

4. Para cada de los funciones (numberOne, numberTwo, numberThree), sigue las instrucciones. 

```cadence
pub contract Test {

  // TODO
  // Dígame si esta función registrará o no el nombre.
  // name: 'Jacob'
  pub fun numberOne(name: String) {
    pre {
      name.length == 5: "This name is not cool enough."
    }
    log(name)
  }

  // TODO
  // Dime si esta función devolverá o no un valor.
  // name: 'Jacob'
  pub fun numberTwo(name: String): String {
    pre {
      name.length >= 0: "You must input a valid name."
    }
    post {
      result == "Jacob Tucker"
    }
    return name.concat(" Tucker")
  }

  pub resource TestResource {
    pub var number: Int

    // TODO
    // Dígame si esta función registrará o no el número actualizado.
    // Además, dime el valor de 'self.number' después de que se ejecute.
    pub fun numberThree(): Int {
      post {
        before(self.number) == result + 1
      }
      self.number = self.number + 1
      return self.number
    }

    init() {
      self.number = 0
    }

  }

}
```
