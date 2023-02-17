# Capítulo 6 Día 1 - Creando una Cuenta de TestNet & Desplegando a TestNet

Hola. En la lección de hoy, vamos aprender como crear una nueva cuenta de testnet y desplegar nuestro contrato de NFT a el Testnet de Flow. 

## Instalando la Extensión de Cadence de VSCode

*Si no has installado VSCode antes, puedes hacerlo aquí: https://code.visualstudio.com/*

Ahora que no estamos usando el playground, queremos poder tener errores en nuestro VSCode cuando estamos codificando Cadence. ¡Hay una extensión para hacer eso! 

> Abrir VSCode. En el lado izquierdo de VSCode, hay un icono que parece como 4 cuadradas. Haga clic en ese y buscar “Cadence”.

> Haga clic en la extensión siguiente y presione “Install”:

<img src="https://github.com/emerald-dao/beginner-cadence-course/raw/main/images/cadence-vscode-extension.png" />

## Instalando el CLI de Flow & flow.json

El CLI de Flow permite ejecutar transacciones y guiones desde el terminal, y permite hacer otras cosas de Flow como desplegando un contrato. 

> Instalar el [CLI de Flow](https://docs.onflow.org/flow-cli/install/). Puedes hacer eso cómo así: 

**Mac**
- Pegando sh -ci "$(curl -fsSL https://storage.googleapis.com/flow-cli/install.sh)" en un terminal

**Windows**
- Pegando iex "& { $(irm 'https://storage.googleapis.com/flow-cli/install.ps1') }” en PowerShell

**Linux** 
- Pegando sh -ci "$(curl -fsSL https://storage.googleapis.com/flow-cli/install.sh)" en un terminal

Puedes confirmar que el CLI de Flow se instala yendo a un terminal y escribiendo `flow versión`. Si una versión aparece, todo está bien. 

## La Carpeta de Flow

Dentro nuestro directorio base, hagamos una nueva carpeta llamada `flow`. 

Dentro de la carpeta de flow, hagamos una otra carpeta llamada `cadence`. 

Dentro la carpeta de cadence, hagamos una carpeta de contratos (`contracts`), una carpeta de transacciones (`transactions`), y una carpeta de guiones (`scripts`). 

Dentro la carpeta de los `contracts`, añadir una nuevo archivo llamado `CONTRACT_NAME.cdc`. Reemplazar CONTRACT_NAME con el nombre de tu contrato. En ese archivo, poner el código de tu contrato de Capítulo 5. Para este lección, vamos a llamar este contrato “ExampleNFT”, pero por favor asegurar que te remplacer eso con tu propio nombre de contrato. 

Tenga en cuenta en la parte superior, ahora tenemos que importar de un camino de archivo local en lugar de una dirección al azar de el playground de Flow. No estamos importando de `0x01`, eso solo era una cosa de playground. En este caso, estamos importando un contrato local que existe en nuestro proyecto. 

> Cambiar el import en la parte superior para ser: `import NonFungibleToken from “./NonFungibleToken.cdc”`

Para esto funciona, también tenemos que añadir la interfaz de contrato de `NonFungibleToken` a nuestras carpeta de `contracts` también. Asegurar a nombrar el archivo, `NonFungibleToken.cdc`. 

---

Dentro de la carpeta de transacciones, hacer muchos archivos llamados `TRANSACTION_NAME.cdc`. Reemplazar TRANSACTION_NAME con los nombres de tus transacciones. 

Tenga en cuenta que los importes son también incorrectos. No estamos importando de `0x01`, eso era solo para el playground. En este caso, estamos importando un contrato local que existe en nuestro proyecto. Entonces cambiar los imports a algo como este formato:

```cadence
import ExampleNFT from "../contracts/ExampleNFT.cdc"
```

---

Dentro de la carpeta de los guiones, hacer muchos archivos llamados `SCRIPT_NAME.cdc`. Reemplazar SCRIPT_NAME con los nombres de tus guiones. 

---

### flow.json

> Ahora que tenemos nuestro contrato en el directorio de nuestro proyecto, ir a tu terminal y cd dentro a la base de nuestro directorio de proyecto. 

> Escribir `flow init`

Este crea un archivo de `flow.json` dentro tu proyecto. Este es necesario para desplegar contratos y darnos errores de compilación dentro nuestro código de Cadence. 

## Desplegando nuestro Contrato de NFT a TestNet

¡Genial! Ahora desplegamos nuestro contrato a TestNet así que podemos empezar interactuando con él. 

## Configurar `flow.json`

> Dentro tu archivo de `flow.json`, hacer el objeto de “contratos” parece como así: 

```json
"contracts": {
  "ExampleNFT": "./contracts/ExampleNFT.cdc",
  "NonFungibleToken": {
    "source": "./contracts/NonFungibleToken.cdc",
    "aliases": {
      "testnet": "0x631e88ae7f1d7c20"
    }
  }
},
```

> Asegurar que te reemplacen “ExampleNFT” con el nombre de tu contrato.

Este permite a tu `flow.json` saber dónde viven tus contratos. Tenga en cuenta que `NonFungibleToken` ya existen en el TestNet de Flow, lo cual es por que parece más complicado. 

### Creando una Cuenta

> 🔐 Generar una dirección de la desplegar escribiendo `flow keys generate –network=testnet` en un terminal. Asegurar que guardes tu clave pública y tu clave privada en algún lugar, los necesitaría pronto. 

<img src="https://i.imgur.com/HbF4C73.png" alt="generate key pair" />

> 👛 Crear de tu **cuenta de desplegando** yendo a https://testnet-faucet.onflow.org/, pegando en tu clave publico de arriba, y haga clic en `CREATE ACCOUNT`: 

<img src="https://i.imgur.com/73OjT3K.png" alt="configure testnet account on the website" />

> Una vez finalizado, haz clic en `COPY ADDRESS` y asegúrate que te guardes esa dirección en algún lugar. ¡Lo necesitarás! 

> ⛽️ Añadir tu nueva cuenta de testnet a tu `flow.json` modificando las siguientes líneas de código. Pegar tu dirección que te copió de arriba a donde dice “YOUR GENERATED ADDRESS”, y pegar tu clave privada donde dice “YOUR PRIVATE KEY”. 

```json
"accounts": {
  "emulator-account": {
    "address": "f8d6e0586b0a20c7",
    "key": "5112883de06b9576af62b9aafa7ead685fb7fb46c495039b1a83649d61bff97c"
  },
  "testnet-account": {
    "address": "YOUR GENERATED ADDRESS",
    "key": {
      "type": "hex",
      "index": 0,
      "signatureAlgorithm": "ECDSA_P256",
      "hashAlgorithm": "SHA3_256",
      "privateKey": "YOUR PRIVATE KEY"
    }
  }
},
"deployments": {
  "testnet": {
    "testnet-account": [
      "ExampleNFT"
    ]
  }
}
```

> Asegurar a cambiar “ExampleNFT” a el nombre de tu contrato. 

> 🚀 Desplegar tu smart contract de “ExampleNFT”: 

```sh
flow project deploy --network=testnet
```

<img src="https://github.com/emerald-dao/beginner-cadence-course/raw/main/images/deploy-contract.png" alt="deploy contract to testnet" />

## Búsquedas

1. Ir a https://flow-view-source.com/testnet/. Donde dice “Account”, pegar la dirección de Flow que generaste y haz clic “Go”. En la mano izquierda, debes ver tu contrato de NFT. ¿No es tan genial verlo en vivo en Testnet? Entonces, enviar la URL a la página. 
- EJEMPLO: https://flow-view-source.com/testnet/account/0x90250c4359cebac7/
