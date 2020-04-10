<a name="docker"></a>
![](https://img.shields.io/badge/%20-Bash-grey) ![](https://img.shields.io/badge/%20-Docker-blue) ![](https://img.shields.io/badge/%20-GNS3-green) ![](https://img.shields.io/badge/%20-Netgui-lightgrey) ![](https://img.shields.io/badge/%20-VirtalBox-lightblue") ![](https://img.shields.io/badge/Tutoriales-Srealmoreno-red?style=flat&logo=github)


# DockerFile

### Ir a:
* [Inicio](../)
* [Scripts](../scripts/#scripts)
* [Docker](#docker)
* [Assets](../assets/#assets)

## ¿Que es un DockerFile?  
Un Dockerfile es un archivo de texto plano que contiene una serie de instrucciones necesarias para crear una imagen que, posteriormente, se convertirá en una sola aplicación utilizada para un determinado propósito.

<a name="from"></a>

## From
<div class="background_table">
<table class="table">
  <tr>
    <th class="line">
        <a href="https://github.com/srealmoreno/rae/blob/ca026ab7afb782e8a3d7bad424c1b08e7f44fb17/docker/dockerfile#L1">
            1
        </a>
    </th>
    <th class="command">
        FROM
    </th>
    <th class="value">
        ubuntu:bionic
    </th>
  </tr>
</table>
</div>


Indica la imagen base sobre la que se construirá la aplicación dentro del contenedor.

Sintaxis:
```docker
FROM  <imagen>
FROM  <imagen>:<tag>
```
Por ejemplo la imagen puede ser un sistema operativo como Ubuntu, Centos, etc. O una imagen ya existente en la cual con base a esta queramos construir nuestra propia imagen.

<a name="workdir"></a>

## Workdir

<div class="background_table">
<table class="table">
  <tr>
    <th class="line">
        <a href="https://github.com/srealmoreno/rae/blob/ca026ab7afb782e8a3d7bad424c1b08e7f44fb17/docker/dockerfile#L3">
            3
        </a>
    </th>
    <th class="command">
        WORKDIR
    </th>
    <th class="value">
        /root
    </th>
  </tr>
</table>
</div>

Es el directorio de trabajo predeterminado, en nuestro caso el directorio pasa de `/` a `root`  

Sintaxis:
```docker
WORKDIR ruta_absoluta
```

<a name="run"></a>


## Run

<div class="background_table">
<table class="table">
  <tr>
    <th class="line">
        <a href="https://github.com/srealmoreno/rae/blob/ca026ab7afb782e8a3d7bad424c1b08e7f44fb17/docker/dockerfile#L5-L60">
            5
        </a>
    </th>
    <th class="command">
        RUN
    </th>
    <th class="value">
        apt-get update && apt-get install -y --no-install-suggests --no-install-recommends ...
    </th>
  </tr>
  <tr>
    <th class="line">
        <a href="https://github.com/srealmoreno/rae/blob/ca026ab7afb782e8a3d7bad424c1b08e7f44fb17/docker/dockerfile#L5-L60">
            6
        </a>
    </th>
    <th class="command">
        &#32;
    </th>
    <th class="value">
        ...
    </th>
  </tr>
  <tr>
    <th class="line">
        <a href="https://github.com/srealmoreno/rae/blob/ca026ab7afb782e8a3d7bad424c1b08e7f44fb17/docker/dockerfile#L5-L60">
            59
        </a>
    </th>
    <th class="command">
        &#32;
    </th>
    <th class="value">
        ...
    </th>
  </tr>
  <tr>
    <th class="line">
        <a href="https://github.com/srealmoreno/rae/blob/ca026ab7afb782e8a3d7bad424c1b08e7f44fb17/docker/dockerfile#L5-L60">
            60
        </a>
    </th>
    <th class="command">
        &#32;
    </th>
    <th class="value">
        rm -rf /var/lib/apt/lists/* /etc/apt/apt.conf.d/docker-clean
    </th>
  </tr>
</table>
</div>


Nos permite ejecutar comandos en el contenedor, por ejemplo, instalar paquetes o librerías (apt-get, yum install, etc.).

Sintaxis:
```docker
RUN <comando>
```
No se puede interactuar con los comandos a ejecutar. Por ejemplo no se puede escribir `y` ni `enter` al comando `apt-get`. Todos los comandos tienen que ser sin interacción 

En lugar de:
```docker
RUN apt-get install bla
```

Usar:
```docker
RUN apt-get install -y bla
```
<a name="#env"></a>

## ENV

<div class="background_table">
<table class="table">
  <tr>
    <th class="line">
        <a href="https://github.com/srealmoreno/rae/blob/ca026ab7afb782e8a3d7bad424c1b08e7f44fb17/docker/dockerfile#L62">
            62
        </a>
    </th>
    <th class="command">
        ENV
    </th>
    <th class="value">
        LANG es_NI.UTF-8
    </th>
  </tr>
  <tr>
    <th class="line">
        <a href="https://github.com/srealmoreno/rae/blob/ca026ab7afb782e8a3d7bad424c1b08e7f44fb17/docker/dockerfile#L63">
            63
        </a>
    </th>
    <th class="command">
        ENV
    </th>
    <th class="value">
        LANGUAGE es_NI:es
    </th>
  </tr>
</table>
</div>


Establece variables de entorno para nuestro contenedor, en este caso la variable de entorno. por ejemplo `DEBIAN_FRONTEND noninteractive` el cual nos permite instalar un montón de archivos .deb sin tener que interactuar con ellos o `LANGUAGE` que nos permite establecer el idioma, en este caso a español Nicaragua

Sintaxis:
```docker
ENV <key><valor>
```

<a name="cmd"></a>

## CMD 

<div class="background_table">
<table class="table">
  <tr>
    <th class="line">
        <a href="https://github.com/srealmoreno/rae/blob/ca026ab7afb782e8a3d7bad424c1b08e7f44fb17/docker/dockerfile#L73">
            73
        </a>
    </th>
    <th class="command">
        CMD
    </th>
    <th class="value">
        [ "bash" ]
    </th>
  </tr>
</table>
</div>

Esta instrucción nos provee valores por defecto a nuestro contenedor, es decir, mediante esta podemos definir una serie de comandos que solo se ejecutarán una vez que el contenedor se ha inicializado, pueden ser comandos Shell con parámetros establecidos. En nuestro caso como queremos una línea de ordenes así que el comando de inicio es `bash`  

Sintaxis:
```docker
CMD [“ejecutable”, “parámetro1”, “parámetro2”, ...]
```

<a name="#escribir_dockerfile"></a>

## ¿Cómo escribir un buen Dockerfile?  
Una imagen esta construida por capas (layers) cada instrucción en nuestro Dockerfile agregará una capa nueva a nuestra imagen. Una imagen es en realidad un snapshot (captura, paquete) de un sistema de archivos creado a partir de distintas capas; internamente docker utiliza UnionFS para unir las capas en un sistema de archivos coherente que será la base de ejecución para los contenedores.

```
├─57d778d0fe7c Virtual Size: 125 B
│ └─9a18766ec419 Virtual Size: 125 B
│   └─8ddbcc5eda76 Virtual Size: 125 B
│     └─158b25bed325 Virtual Size: 125 B
│       └─721ae1d579d6 Virtual Size: 125 B
│         └─c4b831f07e97 Virtual Size: 125 B
│           └─5e3bae472293 Virtual Size: 273.9 kB
│             └─a534b2ce02fb Virtual Size: 4.36 MB
│               └─d43e924c7d1c Virtual Size: 4.36 MB
│                 └─14326b840671 Virtual Size: 134.36 MB srealmoreno/rae:latest
```
- Optimizar Instrucciones  

En lugar de:
```docker
RUN apt-get update
RUN apt-get install -y nano
RUN apt-get install -y nmap
RUN apt-get install -y ssh
```
Podemos reescribirlo de esta forma:
```docker
RUN apt-get update &&\
    apt-get install -y\
    nano\
    nmap\
    ssh
```
De esta manera solo se crea 1 capa y no 4. Haciendo más liviana la imagen resultante.

El comando `apt` por defecto también instala paquetes recomendados o sugeridos. Esto no es bueno si queremos una imagen lo más liviana posible.
```docker
RUN apt-get update &&\
    apt-get install -y --no-install-suggests --no-install-recommends\
    nano\
    nmap\
    ssh
```

Además eliminar paquetes incensarios y limpiar caché apt al finalizar.
```docker
RUN apt-get update &&\
    apt-get install -y --no-install-suggests --no-install-recommends\
    nano\
    nmap\
    ssh &&\
    apt-get auto-remove -y &&\
    rm -rf /var/lib/apt/lists/*
```

<a name="#build"></a>

## ¿Cómo se construye una imagen a partir de un Dockerfile?
Con el comando docker build se construye la imagen siguiendo cada instrucción escrita en el dockerfile.  

Sintaxis:
```bash
docker build [OPTIONS] ruta
```
<a name="descargar"></a>

## Descargar
Desde el navegador:  

[DockerFile](https://srealmoreno.github.io/rae/docker/dockerfile)  

Descargar desde línea de ordenes:
```bash
wget https://raw.githubusercontent.com/srealmoreno/rae/master/docker/dockerfile
```

Construir:

```bash
docker build -t username/repo:tag .

docker build -t srealmoreno/rdc:latest .
```

<a name="entorno"></a>

## Entorno gráfico

Para tener entorno gráfico hay que descomentar `wireshark`, `lxde`, `CMD["startlxde"]` y comentar `CMD["bash"]`  
Nota: Puedes instalar otro entorno gráfico, por ejemplo `xfce4`

De:
<div class="background_table">
<table class="table">
  <tr>
    <th class="line">
        <a href="https://github.com/srealmoreno/rae/blob/ca026ab7afb782e8a3d7bad424c1b08e7f44fb17/docker/dockerfile#L52">
            52
        </a>
    </th>
    <th class="command">
        &#32;
    </th>
    <th class="value commend">
        #wireshark\
    </th>
  </tr>
  <tr>
    <th class="line">
        <a href="https://github.com/srealmoreno/rae/blob/ca026ab7afb782e8a3d7bad424c1b08e7f44fb17/docker/dockerfile#L53">
            56
        </a>
    </th>
    <th class="command"></th>
    <th class="value commend"> 
        #lxde\
    </th>
  </tr>
  <tr>
    <th class="line">
       ..
    </th>
    <th class="command"></th>
    <th class="value"></th>
  </tr>
  <tr>
    <th class="line">
        <a href="https://github.com/srealmoreno/rae/blob/ca026ab7afb782e8a3d7bad424c1b08e7f44fb17/docker/dockerfile#L73">
            73
        </a>
    </th>
    <th class="command">
        CMD
    </th>
    <th class="value">
        [ "bash" ]
    </th>
  </tr>
  <tr>
    <th class="line">
        <a href="https://github.com/srealmoreno/rae/blob/ca026ab7afb782e8a3d7bad424c1b08e7f44fb17/docker/dockerfile#L75">
            75
        </a>
    </th>
    <th class="command commend">
        #CMD
    </th>
    <th class="value commend">
        [ "startlxde" ]
    </th>
  </tr>
</table>
</div>

A:
<div class="background_table">
<table class="table">
  <tr>
    <th class="line">
        <a href="https://github.com/srealmoreno/rae/blob/ca026ab7afb782e8a3d7bad424c1b08e7f44fb17/docker/dockerfile#L52">
            52
        </a>
    </th>
    <th class="command"></th>
    <th class="value">
        wireshark\
    </th>
  </tr>
  <tr>
    <th class="line">
        <a href="https://github.com/srealmoreno/rae/blob/ca026ab7afb782e8a3d7bad424c1b08e7f44fb17/docker/dockerfile#L53">
            56
        </a>
    </th>
    <th class="command"></th>
    <th class="value">
        lxde\
    </th>
  </tr>
  <tr>
    <th class="line">
       ..
    </th>
    <th class="command"></th>
    <th class="value"></th>
  </tr>
  <tr>
    <th class="line">
        <a href="https://github.com/srealmoreno/rae/blob/ca026ab7afb782e8a3d7bad424c1b08e7f44fb17/docker/dockerfile#L73">
            73
        </a>
    </th>
    <th class="command commend">
        #CMD
    </th>
    <th class="value commend">
        [ "bash" ]
    </th>
  </tr>
  <tr>
    <th class="line">
        <a href="https://github.com/srealmoreno/rae/blob/ca026ab7afb782e8a3d7bad424c1b08e7f44fb17/docker/dockerfile#L75">
            75
        </a>
    </th>
    <th class="command">
        CMD
    </th>
    <th class="value">
        [ "startlxde" ]
    </th>
  </tr>
</table>
</div>

<a name="wiki"></a>

## Wiki  
- Documentación oficial de [Docker](https://docs.docker.com/)  
    [FROM](https://docs.docker.com/engine/reference/builder/#from)  
    [WORKDIR](https://docs.docker.com/engine/reference/builder/#workdir)
    [RUN](https://docs.docker.com/engine/reference/builder/#run)  
    [ENV](https://docs.docker.com/engine/reference/builder/#env)  
    [CMD](https://docs.docker.com/engine/reference/builder/#cmd)  
    [Como&#32;construir&#32;una&#32;imagen&#32;con&#32;haciendo&#32;uso&#32;de&#32;buenas&#32;prácticas](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)  

- Cursos en español en youtube  
Curso [básico](https://www.youtube.com/watch?v=UZpyvK6UGFo&list=PLqRCtm0kbeHAep1hc7yW-EZQoAJqSTgD-)  
Curso [avanzado](https://www.youtube.com/watch?v=62r32R75iZs&list=PLqRCtm0kbeHDt4UYoRDkx-w7d-7l8aRXS)
    
<a name="autores"></a>
## Autores  

* **Salvador Real** - [srealmoreno](https://github.com/srealmoreno)

También puedes mirar la lista de todos los [contribuyentes](https://github.com/srealmoreno/rae/contributors) quíenes han participado en este proyecto.

<a name="licencia"></a>
## Licencia

Este proyecto está bajo la Licencia GNU General Public License v3.0 - mira el archivo [LICENSE.md](LICENSE.md) para más detalles

---
Redes de área extensa 2020 - Salvador real   
<img src="https://upload.wikimedia.org/wikipedia/commons/f/fd/UNAN.png" height="50px" align="right">

[![](https://img.shields.io/badge/%20-%20-grey?style=social&logo=gmail&label=Gmail)](https://mail.google.com/mail/u/0/?view=cm&fs=1&to=salvadorreal77@gmail.com&su=Manua%20de%20uso%20RAE&body=Hola,%20Salvador%20tengo%20una%20pregunta%20acerca%20del%20manual%20del%20repositorio%20RAE.) [![](https://img.shields.io/badge/%20-%20-grey?style=social&logo=facebook&label=facebook)](https://facebook.com/srealmoreno) [![](https://img.shields.io/github/followers/srealmoreno?label=Follow&style=social)](https://github.com/srealmoreno/)
<style>
.background_table{
    border: 1px solid #e5e5e5;
    background:#f8f8f8;
    padding: 2px;
    margin-bottom: 10px;
    overflow-x: auto; 
    border-radius: 5px;
}

.table{
    display:contents;
    width: 100%; 
}

.line, .command, .value{
    border: none;
    font-family: Monaco, Bitstream Vera Sans Mono, Lucida Console, Terminal, Consolas, Liberation Mono, DejaVu Sans Mono, Courier New, monospace;
    white-space: nowrap;
}

.line, .value{
    font-weight: normal;
}

.line{
    text-align: right;
    font-size: 14px;
    -webkit-touch-callout: none;
	-webkit-user-select: none;
	-khtml-user-select: none;
	-moz-user-select: none;
	-ms-user-select: none;
	-o-user-select:none;
	user-select: none;
    color: #adadad;
    border-right: 1px solid #e5e5e5;
}
.line > a:link, .line > a:visited{
    color: #adadad;
}
.command{
    color: #000000;
    font-weight: bold;
    text-align: center;
}
.value{
    color: #d14;
    text-align: left;
}
.commend{
    color: gray;
}
</style>
