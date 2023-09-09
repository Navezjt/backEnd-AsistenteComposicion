# Plugin para Musescore
_Este es un Asistente de Composición, un plugin que consume una api con un modelo GPT, entrenado con partituras de musicas autoctonas de Bolivia._

## Comenzando 🚀

_Este Readme tiene instrucciones de instalación y uso del plugin._




## Pre-requisitos 📋

_Se requeire la instalación del Software Musescore._

* [Musescore](https://musescore.org/es) - Software que permite la edición de partituras.


## Instalación 🔧

_Para instalar el plugin en Musescore solo es necesario copiar los archivos en el path siguiente:_

_Copie los 4 archivos aqui_

```
C:\Users\{NAME}\Documents\MuseScore3\Plugins
```
### Configuración
_Se requiere configurar el archivo Asistente.qml_

_Si la api esta corriendo de manera local verifique que la urlBase sea la siguiente_
```
property string urlBase : "http://127.0.0.1:8000/"
```


Configuración del path de los archivos json.
_Verifique que el path de los archivos json este deacuerdo a su maquina._
```
source: "C:/Users/{NAME}/Documents/MuseScore3/Plugins/vocabulario2022.json"
source: "C:/Users/{NAME}/Documents/MuseScore3/Plugins/vocabulario_inverso_2022.json"
source: "C:/Users/{NAME}/Documents/MuseScore3/Plugins/vocabularioMIDI.json"
```
### Nota
_Para realizar la ejecución de la api de forma local revise el siguiente repositorio:_
* [BackEnd Api](https://github.com/Fernando123Duran/backEnd-AsistenteComposicion) - Codigo fuente del BackEnd y el modelo entrenado.

### Funcionamiento del plugin🔩

_El plugin en ejecución sacara a la vista una venta, como las siguiente imagen:_

![Venta desplegada](https://github.com/Fernando123Duran/backEnd-AsistenteComposicion/tree/main/plugin_musescore/img/ventana.png)

El boton ***Siguiente***, genera la siguiente Nota musical la cual se vera pintada en la partitura, como tambien en el centro de la ventana se muertra el tipo de nota y la octava en la cual se encuentra.

El boton ***Generar***, genera un rango de aleatorio de notas, este proceso puede demorar de 1 a 2 minutos.

El boton ***Salir***, detiene la ejecución del plugin.





## Autores ✒️



* **Luis Fenrando Duran Rosas** - *Desarrollo del Plugin* - [Fernando123Duran](https://github.com/Fernando123Duran)


## Licencia 📄

MIT




