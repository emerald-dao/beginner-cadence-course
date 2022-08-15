# Capítulo 4 Día - Capacidades

En el capítulo de ayer, hablamos sobre el camino de `/storage/` de el almacenamiento de una cuenta. Hoy vamos hablar sobre los caminos de `/public/` y `/privado/`, y qué son las capacidades. 

NOTA: ESTE CAPÍTULO PUEDE SER MUY CONFUSO. Si te sientes perdida en el camino, voy a darte un abrazo virtual. Prometo, si lees esta lección unas cuantas veces, vas a entender pronto.

## Video

Puedes ver este video desde las 14:45 hasta el fin (vimos la primera mitad en el último día): https://www.youtube.com/watch?v=01zvWVoDKmU 

## Reviso de Ayer

<img src="../images/accountstorage1.PNG" />

Notas Rápidas:
1. `/storage/` es solamente accesible al propietario de la cuenta. Usamos las funciones de `.save()`, `.load()`, y `.borrow()` para interactuar con él. 
2. `/public/` es accesible a todos. 
3. `/private/` es accesible al propietario de la cuenta y las personas a las que el propietario da acceso. 

Para el capítulo de hoy, vamos a usar el código de nuestro contrato de ayer: 

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

Y no te olvides que guardamos el recurso a nuestro almacenamiento como así: 
```cadence
import Stuff from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    let testResource <- Stuff.createTest()
    signer.save(<- testResource, to: /storage/MyTestResource) 
    // le guarda `testResource` a el almacenamiento de mi cuenta a este camino:
    // /storage/MyTestResource
  }

  execute {

  }
}
```

Bueno, estamos listos. 

## Camino de `/public/`

Previamente, cuando guardamos algo en el almacenamiento de nuestra cuentas, solo el propietario de la cuenta puede accederlo. Eso es porque estaba guardado en el camino de `/storage/`. Pero si queremos otras personas a leer el campo de `name` de mi recurso? Pues, usted puede haber adivinado. Hagamos nuestro recurso accesible públicamente. 

```cadence 
import Stuff from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // Se conecta nuestro recurso a el público así otras personas puede acceder él ahora
    signer.link<&Stuff.Test>(/public/MyTestResource, target: /storage/MyTestResource)
  }

  execute {

  }
}
```

En el ejemplo de arriba, usamos la función de `.link()` para conectar nuestro recurso a el camino de `/public/`. En términos más sencillos, tomamos la cosa a `/storage/MyTestResource` y expuesto un `&Stuff:Test` a el publico asi que ellos puede leerlo. 

`.link()` toma dos parámetros: 
1. Un camino de `/public/` o `/private/`
2. Un parámetro target que es el camino de `/storage/` donde los datos que estás conectando vive

Ahora, cualquier persona puede ejecutar un guión para leer el campo de `name` en nuestro recurso. Voy a mostrarte como hacer eso, pero primero necesito presentarte algunas cosas. 

## Capacidades

Cuando te “conectas" algo a los caminos de `/public/` o `/private/`, estás creando algo llamado una capacidad. Nada vive en los caminos de `/public/` o `/private/`, pero todo vive en tu `/storage/`. Sin embargo, podemos pensar sobre las capacidades como “agujas” que te apuntan de un camino de `/public/` o `/private/` a su camino asociado de `/storage/`. Aquí es un visualización útil: 

<img src="../images/capabilities.PNG" />

La parte genial es que puedes hacer tus capacidades de `/public/` o `/private/` *mas restrictivo* que cual es dentro tu camino de `/storage/`. Este es súper genial porque puedes limitar lo que otras personas pueden hacer, pero todavía permite que ellos a hacer algunas cosas. Vamos a hacer esto con las interfaces de los recursos. 

## `PublicAccount` v. `AuthAccount`

Ya aprendimos que `AuthAccount` permite hacer cualquier cosa que quieras con una cuenta. A la otra mano, `PublicAccount` permite a cualquier persona leer de él. Puedes conseguir el tipo de `PublicAccount` usando la funcion de `getAccount` como así:

```cadence
let account: PublicAccount = getAccount(0x1)
// `account` ahora tienes el PublicAccount de la dirreción 0x1
```

La razón porque estoy diciendo esto, es porque la única manera para conseguir una capacidad de un camino de `/public/` es usar `PublicAccount`. A la otra mano, sólo puedes conseguir un capacidad del camino de `/private/` con un `AuthAccount`.

## Volver a `/public/`

Bueno, conectamos nuestro recurso a público. Ahora leamos de él en un guión, y aplicamos algunas de las cosas que aprendimos!

```cadence
import Stuff from 0x01
pub fun main(address: Address): String {
  // Consigue la capacidad de public que está señalando a el tipo de `&Stuff.Test`
  let publicCapability: Capability<&Stuff.Test> =
    getAccount(address).getCapability<&Stuff.Test>(/public/MyTestResource)

  // Tomar prestado el `&Stuff.Test` de la capacidad de public
  let testResource: &Stuff.Test = publicCapability.borrow() ?? panic("La capacidad no exista o no especificó el tipo correcto cuando obtuvo la capacidad.")

  return testResource.name // "Jacob"
}
```

¡Genial! Leemos el nombre de nuestro recurso de el camino de `'/public/`. Estos son los pasos:
1. Obtenga la cuenta pública de la dirección que estamos leyendo de: `getAccount(address)`
2. Obtenga la capacidad que apunta a un tipo `&Stuff.Test` en la ruta `/public/MyTestResource`: `getCapability<&Stuff.Test>(/public/MyTestResource)` 
3. Pida prestada la capacidad para devolver la referencia real: `let testResource: &Stuff.Test = publicCapability.Borrow() ?? Pánico(“La capacidad no es válida”)`
4. Devuelve el nombre: `return testResource.name`

Te estarás preguntando, ¿por qué no tenemos que especificar el tipo de la referencia cuando hacemos `.borrow()`? La respuesta es porque la capacidad ya especifica el tipo, así que es asumi que es el tipo que es pedir prestado. Si pide prestado un tipo diferente, o la capacidad no existen en primer lugar, devuelve `nil` y pánico. 

## Usando Las Capacidades Públicos para Restricta un Tipo  

¡Genial! Por fin llegamos aquí, estoy orgulloso de ti. El tema siguiente es entender cómo restringir ciertas cosas de nuestra referencia así que el público no puede hacer cosas que no queremos que. 

Definamos un otro contrato:

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

En este ejemplo, sumé un función de `changeName` que permite a cambiar el nombre en el recurso. Pero y si no queremos que el público haga esto? Ahora que tenemos una problema: 

```cadence
import Stuff from 0x01
transaction(address: Address) {

  prepare(signer: AuthAccount) {

  }

  execute {
    let publicCapability: Capability<&Stuff.Test> =
      getAccount(address).getCapability<&Stuff.Test>(/public/MyTestResource)

    let testResource: &Stuff.Test = publicCapability.borrow() ?? panic("La capacidad no existe o no especifica el tipo correcto cuando consiguió la capacidad.")

    testResource.changeName(newName: "Sarah") // ESTE ES UN PROBLEMA DE SEGURIDAD!!!!!!!
  }
}
```

¿Ves el problema? Porque hemos conectado nuestro recurso al público, cualquier persona puede llamar `changeName` y cambiar nuestra nombre! Eso no es justo. 

La manera para resolver este es para: 
1. Definir un nuevo interfaz de recurso que solamente expone el campo de `name`, y NO `changeName`
2. Cuando usamos `.link()` para conectar el recurso al camino de `/public/`, restrinjamos la referencias para usar esa interfaz de recurso en paso 1). 

Sumemos un interfaz de recurso a nuestro contrato: 

```cadence
pub contract Stuff {

  pub resource interface ITest {
    pub var name: String
  }

  // `Test` ahora implementa `ITest`
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

¡Genial! Ahora `Test` implementa un interfaz de recurso llamado `ITest` que solamente tiene `name` dentro. Ahora podemos conectar nuestro recurso al público haciendo este: 

```cadence 
import Stuff from 0x01
transaction() {
  prepare(signer: AuthAccount) {
    // Guarda el recurso a la almacenamiento de la cuenta
    signer.save(<- Stuff.createTest(), to: /storage/MyTestResource)

    // Ves lo que hice aquí? Solo he conectado `&Stuff.Test{Stuff.ITest}`, NO `&Stuff.Test`.
    // Ahora solo el público tiene acceso a las cosas en `Stuff.ITest`.
    signer.link<&Stuff.Test{Stuff.ITest}>(/public/MyTestResource, target: /storage/MyTestResource)
  }

  execute {

  }
}
```

Así que, ¿qué pasa si intentamos acceder a toda la referencia ahora en un guión, como hacíamos antes? 

```cadence
import Stuff from 0x01
transaction(address: Address) {
  prepare(signer: AuthAccount) {

  }

  execute {
    let publicCapability: Capability<&Stuff.Test> =
      getAccount(address).getCapability<&Stuff.Test>(/public/MyTestResource)

    // ERROR: “La capacidad no existe o no
    // especifica el tipo correcto cuando consiguió la capacidad”
    let testResource: &Stuff.Test = publicCapability.borrow() ?? panic("La capacidad no existe o no especifica el tipo correcto cuando consiguió la capacidad.")

    testResource.changeName(newName: "Sarah")
  }
}
```

¡Ahora, conseguimos un error! No se puede tomar prestada la capacidad porque ha intentado tomar prestada una capacidad a `&Stuff.Test`, y no puse eso a tu disposición. Solo hice `&Stuff.Test{Stuff.ITest}` disponsible. ;)

¿Qué pasa si intentamos esto? 

```cadence
import Stuff from 0x01
transaction(address: Address) {

  prepare(signer: AuthAccount) {

  }

  execute {
    let publicCapability: Capability<&Stuff.Test{Stuff.ITest}> =
      getAccount(address).getCapability<&Stuff.Test{Stuff.ITest}>(/public/MyTestResource)

    // Este funciona....
    let testResource: &Stuff.Test{Stuff.ITest} = publicCapability.borrow() ?? panic("La capacidad no existe o no especifica el tipo correcto cuando consiguió la capacidad.")

    // ERROR: “Miembro de tipo restringido no es accesible: changeName”
    testResource.changeName(newName: "Sarah")
  }
}
```

Y de nuevo. Aunque ha tomado prestado el tipo correcto, no puedes llamar `changeName` porque no es accesible a través de el tipo de `&Stuff.Test{Stuff.ITest}`.

Pero, esto funcionará: 

```cadence
import Stuff from 0x01
pub fun main(address: Address): String {
  let publicCapability: Capability<&Stuff.Test{Stuff.ITest}> =
    getAccount(address).getCapability<&Stuff.Test{Stuff.ITest}>(/public/MyTestResource)

  let testResource: &Stuff.Test{Stuff.ITest} = publicCapability.borrow() ?? panic(("La capacidad no existe o no especifica el tipo correcto cuando consiguió la capacidad.")

  // Este funciona porque `name` es en `&Stuff.Test{Stuff.ITest}`
  return testResource.name
}
```

¡Hurra! Exactamente como queríamos! 

## En Conclusión

¡Guau! Eso era mucho. ¿Las buenas noticias? Aprendiste un montón sobre Cadence hasta ahora. Y aun mejor, aprendiste todas las cosas complicadas. Estoy super orgulloso de ti.

También, intencionalmente no hablé super en profundidad sobre `/private/`. Esto es porque, en el mundo real, nunca usas `/private/` realmente, y no quería meter demasiada información en tu cabeza. 

Y, pues… tengo hambre. Así que voy a comer. Tal vez voy a añadir más a este capítulo un poco más tarde. 

## Búsquedas

Por favor responder en el idioma de tu preferencia.

1. ¿Que hace .link()?

2. En tus propias palabras (sin código), explicar cómo podemos usar las interfaces de los recursos para solamente exponer cosas ciertas a el camino de /public/.

3. Desplegar un contrato que contiene un recurso que implementa una interfaz de recurso. Entonces, hacer lo siguiente: 
    - En una transacción, guarda el recurso a el almacenamiento y conectarlo al público con la interfaz restrictiva. 
    - Ejecutar un guión que intenta acceder un campo no expuesto en la interfaz de recurso, y vea la ventana emergente de error.
    - Ejecutar un guión y acceder algo que PUEDES leer de. Devolverlo desde el guión. 
