# Capítulo 6 Día 2 - Interactuando Con Nuestro Contrato en TestNet

Ahora que hemos desplegado nuestro contrato a testnet, podemos interactuar con él en nuestro terminal usando el CLI de Flow. ¡Woooooo! Esto es sólo va a ser más complicado. ¡Espero que todos se pierdan! 

Hoy las cosas van a ser un poco diferentes. Va a involucrarse haciendo cosas juntos. No voy a darle todas las respuestas ;)

## Interactuando con nuestro Contrato

Ahora que hemos desplegado nuestro contrato a testnet, podemos interactuar con él en nuestro terminal usando el CLI de Flow.

### Leyendo nuestro TotalSupply

¡Leamos el totalSupply de nuestro smart contract!

> Paso 1: Hacer un guión que lee el totalSupply de nuestro contrato y devolverlo.

> Paso 2: Pegar ese guión en la carpeta de tus guiones y nombrarlo `read_total_supply.cdc`

> Paso 3: Abrir tu terminal en el directorio base de el proyecto y ejecutar: 

```bash
flow scripts execute ./scripts/read_total_supply.cdc --network=testnet
```

Si funciona correctamente, debes ver el totalSupply en tu consola (debe ser 0 si no has creado algo hasta ahora).

<img src="../images/read-total-supply.png" alt="read the total supply" />

### Configurar Nuestra Colección

Ejecutemos una transacción para configurar nuestra Colección de NFT en Testnet.

> Paso 1: Hacer una transacción para configurar la colección de usuario para almacenar sus NFTs. 

> Paso 2: Añadir un archivo de `setup_collection.cdc` en tu carpeta de transacciones con el código de Cadence dentro. 

> Paso 3: Abrir tu terminal en el diccionario base de el proyecto y ejecutar: 

```bash
flow transactions send ./transactions/setup_collection.cdc --network=testnet --signer=testnet-account
```

Si funciona correctamente, debes ver que el transaccion es sellado (completado) y funcionó! 

<img src="../images/setup-collection.png" alt="setup collection transaction" />

GENIALLLLLL!!! Configuramos con éxito nuestra colección NFT en la red de pruebas. Esto es genial.

### Como Pasar Los Argumentos Usando el CLI de Flow

Hasta ahora, no te hemos mostrado cómo pasar los argumentos en un guión o transacción usando el CLI de Flow. 

En orden a hacer eso, simplemente pone ellos después de los caminos de los archivos de la transacción o guión. 

Ejemplo #1:

```bash
flow transactions send ./transactions/mint_nft.cdc 0xfa88aefbb588049d --network=testnet --signer=testnet-account
```

Si tu transacción de `mint_nft.cdc` tomó en un `recipient: Address`, seria `0xfa88aefbb588049d` en este caso. 

Ejemplo #2:

```bash
flow scripts execute ./scripts/read_nft.cdc 0xfa88aefbb588049d 3  --network=testnet
```

Si tu guión de `read_nft.cdc` tomó en un `recipient: Address, id: UInt64`, sería `0xfa88aefbb588049d`  y `3` en este caso. 

Ejemplo #3:

```bash
flow transactions send ./transactions/mint_nft.cdc 0xfa88aefbb588049d "Jacob the Legend" --network=testnet --signer=testnet-account
```

Si tu transaccion de `mint_nft.cdc` tomo en un `recipient: Address, name: String`, seria `0xfa88aefbb588049d` y `Jacob the Legend` en este caso. 

## En Conclusión

Era mucho hoy, pero que genial es esto? Desplegamos nuestro propio contrato a el Testnet de Flow, ejecutamos un guión para leer nuestro `totalSupply`, y entonces ejecutamos una transacción para configurar nuestra colección. Estás haciendo genial! 

## Búsquedas

1. Averigüe cómo acuñar un NFT para usted mismo enviando una transacción utilizando la CLI de Flow, como lo hicimos hoy cuando configuramos nuestra colección. También es probable que tenga que pasar un argumento también.

*Consejo útil*: Recuerde que sólo el propietario del contrato tiene acceso al recurso de `Minter`. Esto funciona a nuestro favor porque el firmante de la transacción será el que despliegue el contrato, por lo que tenemos acceso al `Minter`.

*Consejo util #2*: También recuerda que en orden a configurar una colección, tienes que firmar una transacción así que la transacción tiene acceso a tu `AuthAccount`. En este caso, porque solo tenemos 1 cuenta de testnet creada (el uno quien ha desplegado el contrato), vamos a creando el NFT para nosotros mismos para ser más fácil. 

2. Ejecutar un guión para leer el nuevo `totalSupply` usando el CLI de Flow

3. Ejecutar un guión para leer los ids de los NFTs en la colección de alguien usando el CLI de Flow

4. Ejecutar un guión para leer la metadata de los NFTs especificado de la colección de alguien usando el CLI de Flow

5. Ejecutar un guión para leer el `totalSupply` de GoatedGoats en el **Mainnet de Flow**. Su contrato vive aqui: https://flow-view-source.com/mainnet/account/0x2068315349bdfce5/contract/GoatedGoats 

*Consejo util #1*: En orden a ejecutar guiones en Mainnet, simplemente cambiar el `–network=testnet flag` a `–network=mainnet`.

*Consejo util #2*: Porque vas a ejecutando el guión de un archivo local, tienes que codificar la dirección de mainnet del contrato de GoatedGoats en tu guión, como: 
```cadence
import GoatedGoats from 0x2068315349bdfce5
```

Desafortunadamente, ahora obtendrá errores de compilación (la extensión VSCode no podrá comprender la importación), pero seguirá funcionando.

6. Averigüe cómo leer los NFT de GoatedGoats de alguien de su colección y ejecute un script utilizando la CLI de Flow para hacerlo.
