# Capítulo 2 - Día 1 - Nuestro Primero Smart Contract

¡Hola personas bonitas! Bienvenidos al capítulo glorioso 2, en cúal vamos a empezar con algunos ejemplos de código de Cadence. 

Hoy, vamos a aprender los muy básicos de código de Cadence, mediante la implementación de nuestro primer Smart Contract. Eso es, como declarar una variable, cómo escribir una función, etc. 

## Video

Si quieres algunos videos para ver, puedes verlo estas dos videos (ellos son muy similar): 

1. https://www.youtube.com/watch?v=QbqNM4k76B0 (información general de smart contracts, cuentas, y desplegando nuestro primer contrato)

2. https://www.youtube.com/watch?v=DSwNNOEdBXU (explicación detras algunos sintaxis basic + desplegando un contrato)  **NOTA**: Mira este video de 00:00 - 07:23. Nada más allá de las 07:23 no es cubierto en esta lección. 

## Nuestro Primero Smart Contract

*Antes de empezar, asegúrate de haber leído Capitulo 1, Dia 1. Ese día cubrirá todo lo que necesitas saber sobre Smart Contracts hasta este punto.*

Para empezar haciendo nuestro primer Smart Contract, necesitamos encontrar un lugar para ponerlo realmente! Para hacerlo, lanza un navegador de tu elección (yo recomiendo Google Chrome), va a el Flow playground pegando este URL: https://play.onflow.org. Después de hacerlo, haga lo siguiente: 
1. En el lado izquierdo, haz clic el ‘0x01’ pestaña
2. Borrar todo en eso página.

Debe mirar como así:

<img src="../images/blanksc.png" alt="drawing" size="400" />

Lo que hemos hecho es hacer click en la cuenta con la dirección `0x01` y borramos el contrato en su cuenta. Eso trae un tema importante. 

## ¿Qué es una dirección de cuentas? 

Una dirección es algo que parece como `0x` y entonces un ramo de números y letras al azar. Aquí está un ejemplo de dirección en Flow: `0xe5a8b7f23e8b548f`. En el Flow playground, te vas a ver una dirección mucho más corta como `0x01`. Eso es solo para simplificar las cosas. 

Pero que es una dirección realmente? Pues, puede pensarlo como un usuario. Cuando yo quiero hacer algo en el blockchain, necesito tener una cuenta. Cada cuenta tiene una dirección asociada con el. Así que cuando ves algo como `0xe5a8b7f23e8b548f`, eso es realmente una cuenta de una persona que se usan para almacenar datos, enviar transacciones, etc.

## ¿Donde viven los Smart Contracts? 

Smart Contracts son cuentas desplegadas. Como hemos mencionado anteriormente, cuentas son prosperidad de un usuario, y cada cuenta tiene una dirección asociada con el que siempre empiezas con `0x`. En este caso, ya que estamos en el Flow playground, nos ha dado automáticamente 5 cuentas, a saber `0x01`, `0x02`, etc. Por lo tanto, los Smart Contracts viven en una dirección. Entonces, cuando nos despliega un contrato llamado "Hello World" para contabilizar `0x01`, así es como lo identificamos. Si queremos interactuar con él, tendríamos que saber ambos el nombre del contrato y la dirección. Vamos a ver esto más en profundidad cuando importemos cosas más adelante. 

## Volver a nuestro ejemplo…

En este caso, vamos a desplegar nuestro Smart Contract a la cuenta `0x01`. Esto significa que la cuenta `0x01` es el **propietario** de este Smart Contract. En el mundo real, habías desplegará tu Smart Contract a **tu** cuenta, pero porque este es un mundo simulación falso, podemos elegir cualquier cuenta que queramos, así que nos elegí `0x01`.

Hagamos nuestro contrato ahora. En este espacio vacío, escriba lo siguiente: 
```cadence
pub contract HelloWorld {

    init() {

    }
}
```

El parte de `pub contract [nombre de contrato]` siempre será lo que escribas cuando crees un nuevo contrato. Puedes rellenar `[nombre de contrato]` con lo que quieras llamar tu contrato.

El función de `init()` es una función que cada contrato debe tener. Es llamado cuando el Contract es desplegado inicialmente, cual en el mundo real, solo sucede 1 vez. Así que, podemos inicializar algunas cosas en él cuando nos queremos. 

Okay, ¡boom! Este es tu primer Smart Contract, aunque no hace nada ;( Hagamos que almacene un variable de `greeting` así que podemos almacenar algún data en este contrato.

Modificar el código de tu contrato así que se parece como así: 
```cadence
pub contract HelloWorld {

    pub let greeting: String

    init() {
        self.greeting = "Hello, World!"
    }
}
```

En Cadence, cuando declare un variable, te sigues este formato: 
`[modificador de acceso] [var/let] [nombre de variable]: [tipo]`

Usando nuestro ejemplo arriba… 
-Nuestro modificador de acceso es `pub`, lo cual significa que cualquier persona puede leer esta variable. En el futuro, vamos a ver muchos de otros modificadores de accesos, pero vamos a seguir con pub para las próxima lecciones, sólo para hacer la vida más fácil. 
- `let` significa que esta variable es un constante. Si has programado en otros idiomas de programación, un constante significa que una vez que esté variable igual a algo, no podemos cambiarlo. A la otra mano, var significa que podemos cambiarlo.
- Nuestro nombre de variable es `greeting`
El tipo de nuestra variable es un `String`. Esto significa que podemos poner cosas como “Hola”, “Jacob es el mejor”, “Amo Jacob”, cosas como eso.

Siguiente, nos poner `self.greeting = “¡Hola, Mundo!”` dentro de la función de `init()`. Recuerda, la función de `init()` se llama cuando el contrato se desplegó, el cual solo pasa una vez. `self` es una palabra clave en que significa, “el variable es un capa arriba.” En este caso, `self.greeting` se refiere a la variable de greeting que nos declaramos justo encima de él, y lo establecemos igual a “¡Hola, Mundo!”

Para desplegar este contrato, haz clic en el botón verde que dice “Deploy”. Tu página debe mirar como así: 

<img src="../images/helloworld.png" alt="drawing" size="400" />

NOTA: Si estás recibiendo errores, primero intenta actualizar la página. Si todavía estás viendo errores como: “GraphQL error”, intenta cambiar tu navegador a Google Chrome.

¡Genial! Has desplegado tu primera Smart Contract. 

## Leyendo nuestro Greeting

Asegurémonos de que nuestra variable de `greeting` en realidad es igual a “¡Hola, Mundo!” Recuerda, podemos ver la data desde el Blockchain usando un guión.

A el lado izquierdo, debajo de “Script Templates”, haz clic en la pestaña que dice “Script” y eliminar todo dentro de él. A continuación, escriba el código siguiente. 

```cadence
import HelloWorld from 0x01

pub fun main(): String {
    return HelloWorld.greeting
}
```

Este Guión se va a regresar el valor de `greeting`, cual es “¡Hola, Mundo!” Para hacer eso, veamos qué hicimos: 
1. Primero, nos importamos nuestro Smart Contract haciendo, `import HelloWorld from 0x01`. En Cadence, importa un contrato haciendo `import [nombre de contrat] from [dirección de eso contrato]`. Como hemos desplegado HelloWorld a `0x01`, escribimos lo anterior.
2. Siguiente, escribimos una función. En Cadence, escriba una función haciendo `[modificador de access] fun [nombre de función](): [tipo de devolución] {...}`. En este caso, hemos usado pub para nuestro modificador de acceso (mas en esto más tarde), nombrado nuestro función de `main`, y dice que vamos a regresar un tipo de `String`, cual recuerda, es el tipo de `greeting`. 
3. Entonces hemos accedido el variable de `greeting` desde el contrato usando `HelloWorld.greeting`.

Si haz click “Execute” en el lado derecho, vas a ver en el terminal que imprime, “¡Hola, Mundo!” cómo debajo:

<img src="../images/hwscript.png" alt="drawing" size="400">

Si el tuyo se ve así, ¡has ejecutado tu primer guión!

## Revisión de Conceptos

OK, así que acabamos de escribir un poco de código. Fue rápido. Pero ¿cómo se relaciona todo esto con lo que estaba diciendo en Capítulo 1, Día 1?

Recuerda que Smart Contracts son ambos programas y guías. Nos permiten hacer ciertas cosas, nada más y nada menos. En este ejemplo, nuestro Smart Contract permite inicializar `greeting` y leer `greeting`. Tenga en cuenta que no permite cambiar greeting para ser algo diferente. Si hubiera querido añadir esa funcionalidad, hubiéramos tenido que hacerlo antes de tiempo, antes de desplegar. Este es por que es muy crucial como un desarrollador de un Smart Contract, que te implemente todas las funcionalidades te quieres un usuario tener antes de desplegar tu contrato. (Claro que si, en el Flow playground, podemos desplegar el contrato de nuevo. Pero en el mundo real no puedes hacer esto.)

## En Conclusión

Hoy, hemos aprendi como desplegar nuestro primero contrato, declarar un variable, escribir una funccion, y ejecutar un guion. ¡Wow! Eso es mucho. ¿Pero no era tan mal, cierto?

# Búsquedas

Para las búsquedas de hoy, por favor cargar un nuevo Flow playground yendo a https://play.onflow.org, al igual que hicimos en la lección de hoy. 

1. Desplegar un contrato a la cuenta `0x03` llamado “JacobTucker”. Adentro eso contrató, declarar un variable **constante** nombrado `is`, y hacer que tenga el tipo de `String`. Inicializar a “the best” cuando tu contrato se despliegue. 

2. Asegúrate que tu variable `is` es igual a “the best”, ejecutando un guión para leer esa variable. Incluir una foto de tu resultado. 

Es genial poder hacer estas búsquedas. Me encanta esto. 

Por favor, recuerda almacenar tus repuestas en alguna manera así que puedo revisarlos si me las envias. ¡Buena suerte!
