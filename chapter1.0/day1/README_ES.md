# Capítulo 1 Dia 1 - Aprender Conceptos de Blockchain

¡Hola! Si, soy yo. Tu desarrollador favorito de todo el tiempo, Jacob. Actualmente estás viendo el primer día de todo el curso. Comencemos este viaje juntos. 

Comencemos nuestro primer día con algunas cosas que son importante a entender para tu viaje por delante.

## ¿Qué es un Blockchain? 

<img src="../../images/blockchain.png" alt="drawing" width="600"/>

*Si ya sabe que es el Blockchain o si no te importas, tú puedes omitir esta sección.*

Cuando aprendes sobre el Blockchain, puedes encontrar algunos artículos complicados. Es fácil perderse o sentir cómo quieres dejar. Así que voy a explicar el Blockchain en una manera muy fácil y puede que no tenga alguna información pero es para ayudarte a empezar. **Específicamente quiero ayudarlo a entender el Blockchain desde la perspectiva de alguien quien está buscando programar smart contracts o hacer algunas aplicaciones descentralizadas.(¡ambos de cuales vamos a hacer!)**

En un frase: el Blockchain es un abierto, descentralizado, base de datos compartida en que cualquier persona puede almacenar cosas públicamente.

Ok, wow. ¿Qué significa eso? 

1. **ABIERTO**: Cualquier persona puede interactuar con él. No hay restricciones. 
2. **DESCENTRALIZADO**: Nadie lo posee. No hay una autoridad central quien está controlando todo las cosas. 
3. **BASE DE DATOS COMPARTIDA**: Puedes almacenar cosas en el. 
4. **PÚBLICO**: Cualquier persona puede ver el data en el. 

Porqué de esas cosas, podemos interactuar con el Blockchain en cualquier manera que queramos. A veces, nos queremos hacer un "guía" que determine cómo una persona puede interactuar con partes específicas del Blockchain así que tiene alguna funcionalidad; especialmente nuestro proprio aplicaciones que vamos a definir. Esto es posible con Smart Contracts.

También es importante anotar que hay muchas Blockchains diferentes. Por ejemplo, Ethereum es el Blockchain más popular. En este curso, vamos a aprender sobre el Blockchain maravilloso de Flow.

## ¿Smart Contracts? ¡Ooo, eso suena interesante!

<img src="../../images/smart contract.png" alt="drawing" width="600"/>

Si es así. Los Smart Contracts son super genial. Smart Contracts son programas o "guías" que los desarrolladores hacen. Con Smart Contracts podemos especificar algún funcionalidad en que personas interactúen con. Por ejemplo, si quiero hacer un aplicación que permitirá una persona a almancer su fruta favorita en el Blockchain, necesito hacer un Smart Contract que:
1. Tiene un función cualquier persona puede llamar
2. Toma un parámetro (la fruta favorita de la persona)
3. Guarda el parámetro en algun data 
4. Envía los datos actualizados a el Blockchain (esto sucede automáticamente)

Si yo hiciera este Smart Contract y “desplegarse” a el Blockchain (esto significa que ponemos el contrato en la Blockchain así que las personas pueden interactuar con él), entonces cualquier persona puede poner su fruta favorita en el Blockchain, y viviría por allí para siempre. A menos que tengamos una función para quitar esa data.

Entonces, ¿por qué usamos Smart Contracts? 

1. **La velocidad, la eficiencia, y la exactitud**: Los Smart Contracts son rápidos y no hay un intermediario. También no hay papeleo. Si quiero actualizar la data en el Blockchain usando un contrato inteligente que me permite llamar a alguna función, yo puedo hacerlo. No tengo conseguir la aprobación de mis padres o mi banco.
2. **La confianza y transparencia**: El Blockchain y los Smart Contracts, son extremadamente seguros si se hace de esa manera. Es casi imposible hackear o cambiar el estado de la Blockchain, y mientras es porque de otras razones, es una gran parte de los smart contracts. Si un contrato inteligente no me permite hacer algo, yo simplemente no puedo hacer nada.

¿Cuáles son algunos de los inconvenientes? 

1. **Es difícil conseguir correcto**: Mientras que los smart contracts son buenos, ellos no son inteligentes. Ellos requieren niveles sofisticados de experiencia del lado de los desarrolladores para asegurarse de que ellos no van a tener problemas de seguridad, ellos son baratos, y también ellos hacen lo que queremos a hacer. Vamos a aprender todo más tarde. 
2. **Pueden ser maliciosos si el desarrollador es maleducado**: Si el desarrollador quiere hacer un smart contract que roba tu dinero, y trucos que llaman una función para hacer esto, tu dinero se va a ser robado. 
3. **No se puede deshacer algo**: No puedes simplemente deshacer algo. A menos que tenga una función para hacerlo. 

## Transacciones & Guiones

<img src="../../images/transaction.jpeg" alt="drawing" width="600"/>

*“Bueno, tenemos un Smart Contract. ¿Cómo puedo realmente interactuar con él? Eres diciendo a llamar una función, pero qué significa?”*

**Una transacción es como un llamado de función de pago.** Lo que es más importante para conocer es que una transacción cambió los datos en el Blockchain, y es usualmente la única manera en que podemos cambiar el data en el Blockchain. Las transacciones pueden costar cantidades de dinero diferentes dependiendo de que Blockchain estas usando. En Ethereum, para almacenar tu fruta favorita en el Blockchain, puede costar cerca de 100 dólares. En Flow, es solo una fracción de un centavo.

A la otra mano, un guión es usado para VER datos en el Blockchain, ellos no cambian él. Los guiones no cuestan dinero, eso sería ridículo. 

Aquí es un ‘workflow’ normal:

1. Un desarrollador “despliega” un Smart Contract a el Blockchain
2. Un usuario hace un transacción, que toma alguna tipo de pago (para pagar por los ‘gas fees’, ejecución, etc) se llama algunas funciones en el Smart Contract
3. **El Smart Contract cambió su datas en alguna manera**

## “MainNet” v. “TestNet”

<img src="../../images/tvm.PNG" alt="drawing" width="600"/>

Es posible que haya oído estas cosas, pero ¿qué significa realmente?

**TestNet** es un medio ambiente donde desarrolladores prueben sus aplicaciones antes de liberarlas al público. Este es un espacio perfecto para resolver los errores en tu aplicación antes de liberarla al público para usarla. Aquí son un algunas notas adicionales:
- Todo es falso
- No hay dinero real involucrado
- Transacciones cuesta dinero falso
- Un buen manera para desarrolladores a prueba sus smart contracts y aplicaciones antes de liberarlas al público
- Si algo malo paso, a nadie le importa

**MainNet** es un medio ambiente donde todo es real. Cuando liberas tu aplicación al público, la pones en MainNet. En MainNet, todo es en vivo, asi que cosas cuestan dinero real, hay riesgos, y debe asegurarse todo esté funcionando correctamente. Aquí son algunas notas adicionales:
- Todo es real
- Dinero real es involucrado
- Transacciones cuesta dinero real
- Cuando tu aplicación es totalmente listo, le pones en MainNet para usuarios a interactuarlo. 
- Si algo malo pasó, eso es muy malo.

## Aplicaciones Descentralizadas (dApps)

<img src="../../images/dapps.jpeg" alt="drawing" width="300"/>

Ay no, esto suena complicado. No, no es! DApps son literalmente aplicaciones normales (Javascript, Python, etc) que también tiene Smart Contracts involucrado. Eso es todo. 

También vamos a construir este :)

## ¿Por qué me importa sobre todo esto? 

Pues, porque eso es que este curso es sobre todo. En este curso, vamos a hacer nuestro propio Smart Contracts, específicamente en el Blockchain Flow. En adición, vamos a hacer un aplicación descentralizada que se *usan* esos Smart Contracts.

## En conclusión

Jacob es lo mejor. No, no. Esa no es la conclusión. La conclusión es que aunque todo esto suena muy complicado, realmente no es. Y si todavía no entiendes cualquier de este, está totalmente bien. A veces es mejor saltar en algunos ejemplos para hacer que las cosas tengan más sentido. Vamos a hacer esto en los próximos días.

## Busquedas 

Eres libre de contestar estas preguntas en tu idioma de elección. Y no, no quiero decir idioma de programación de computadoras, jaja. 

1. Explicar que es el Blockchain en tus propias palabras. Puedes leer este para ayudarlo, pero no tienes que hacer: https://www.investopedia.com/terms/b/blockchain.asp

2. Explicar que es un Smart Contract. Puedes leer este para ayudarlo, pero no tienes que hacer: https://www.ibm.com/topics/smart-contracts 

3. Explicar la diferencia entre un guión y una transacción. 
