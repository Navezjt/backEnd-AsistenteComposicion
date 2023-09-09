# Api Rest, Asistente de Composición
Este proyecto implementa una Api desarrollada con FastApi, que consume un modelo de inteligencia artificial generador de partituras con generos autoctonos de Bolivia.

## Comenzando 🚀

_Este Readme tiene instrucciones de instalación y ejecución de la Api de manera local._

## Pre-requisitos 📋

_Se requeire la instalación de los siguientes programas._

* **Anaconda** [instalador](https://www.anaconda.com/products/distribution) 
* **Visual Studio Code** [instalador](https://code.visualstudio.com/) 
* **Git** [instalador](https://git-scm.com/) 
### Sugerencia
para la instalacion de estos programas existen diferentes tutoriales de instalacion en Youtube.
## Instalación 🔧
Para ejecutar el programa siga los siguientes pasos:

_Clonar este repositorio, ejecutando el siguiente comando en una terminal de gitbach:_
```
-> git clone https://github.com/Fernando123Duran/backEnd-AsistenteComposicion.git
```
Una ves descargado el repositorio abra la carpeta con Visual Studio Code.
_Cree un entorno virutal con python, ejecutando el siguiente comando en la terminal de visual studio_

```
-> python -m venv fast-env
```
_Active el entorno virtual con:_

```
-> .\fast-env\Scripts\activate
```
_Instale las dependencias con:_

```
-> pip install -r requirements.txt
```
_Finalmente ejecute el servidor local con:_

```
-> uvicorn main:app --reload
```

_Si todo salio bien la api estara corriendo en la url:_

```
-> http://127.0.0.1:8000/
```
### Nota
Esta api podra ser consumida desde el plugin del siguiente repositorio:
* [Plugin](https://github.com/Fernando123Duran/backEnd-AsistenteComposicion/tree/main/plugin_musescore) - Codigo fuente del plugin.



## Autores ✒️

* **Luis Fenrando Duran Rosas** - *Desarrollo del Api Rest* - [Fernando123Duran](https://github.com/Fernando123Duran)


## Licencia 📄

MIT


