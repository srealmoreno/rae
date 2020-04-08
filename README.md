
![](https://img.shields.io/badge/%20-Bash-grey) ![](https://img.shields.io/badge/%20-Docker-blue) ![](https://img.shields.io/badge/%20-GNS3-green) ![](https://img.shields.io/badge/%20-Netgui-lightgrey) ![](https://img.shields.io/badge/%20-VirtalBox-lightblue") ![](https://img.shields.io/badge/Tutoriales-Srealmoreno-red?style=flat&logo=github)


# Manual de Uso
===================================

### Se explicará:
- <a href="#script"> Uso del script de instalación para: </a>
	* VirtualBox
	* GNS3
	* Docker
	* Netgui
	* Imágenes Ubuntu elaboradas para el uso de Redes

- <a href="#gns3"> Integración de imágenes Docker a GNS3 para: </a>
	* <a href="#ubuntu_host"> Uso como máquina host </a>
	* <a href="#ubuntu_router"> Uso como Router </a>
	* <a href="#ubuntu_switch"> Uso como Switch </a>

### Requisitos
* Sistema operativo: Ubuntu o derivados 
	- Focal 20.0 (LTS)
	- Eoan 19.10
	- Bionic 18.04 (LTS)
	- Xenial 16.04 (LTS)
* Conexión a Internet.
* apt como gestor de paquetes.

<a name="script" id="script"></a>

## Uso del script de instalación
Hay 2 versiones del script. una lenta pero segura `rae.sh` y otra más rápida pero no tan segura `rae_fast.sh` yo probé ambos scripts en máquinas virtuales. Recomiendo usar `rae_fast.sh` y si da algún error usa `rae.sh`

El script te da a escoger que paquetes deseas instalar. Cada paquete es la inicial de su nombre.

Descarga:
Puedes descargar el script desde la línea de ordenes o desde tu navegador favorito.

Descargar desde el navegador:  
Click derecho -> Guardar Como  
Descargar [rae.sh](scripts/rae.sh)  
Descargar [rae_fast.sh](scripts/rae_fast.sh)  

Descargar desde línea de ordenes:
```bash
wget https://raw.githubusercontent.com/srealmoreno/rae/master/scripts/rae_fast.sh
```

Dar permisos de ejecución
```bash
chmod +x rae_fast.sh
```

Ejecución del script
```bash
sudo ./rae_fast.sh
```

Para ver ayuda -h (help en inglés)
```bash
sudo ./rae_fast.sh -h
```

Nota: Si no se pasa ningún parámetro, se  instalan todos los paquetes dichos.

![](assets/ejemplo_1.png "Ejemplo de salida del script")

Por ejemplo si solo se desea instalar Docker e importar imágenes:

```bash
sudo ./rae_fast.sh -d -i
```

Al finalizar debes cerrar sesión y notáras que los iconos de las aplicaciones se agregaron.

Docker no es [GUI](https://es.wikipedia.org/wiki/Interfaz_gr%C3%A1fica_de_usuario)

![](assets/ejemplo_2.png "Menú de aplicaciones")  

<a name="gns3" id="gns3"></a>

## Integración de GNS3 con Docker

* **Configuración inicial de GNS3**

Seleccionar la opción 2.  
![](assets/gns3_1.png "Correr la topología en la computadora local")

Dejar sin cambios.  
![](assets/gns3_2.png "Establecer parámetros del servidor")

¡Listo!  
![](assets/gns3_3.png "Conexión a servidor") ![](assets/gns3_4.png "Finalizando")

<a name="consola" id="consola"></a>

* **Corrigiendo / Cambiando consola predeterminada**  
Ir a Edición -> Preferencias.  
Click en Aplicaciones de consola (Console applications)  
Click en Editar (Edit)  
![](assets/gns3_console_1.png "Menú de preferencias")

Elegir la predeterminada del sistema o la que más te guste.  
**Ubuntu** (gnome) utiliza gnome-terminal  
**Kubuntu** (kde plasma) utiliza Konsole  
![](assets/gns3_console_2.png "Editando consola predeterminada")

Luego Aplicar cambios y listo.  
Nota: Si se desea ejecutar una imagen con entorno gráfico, ir al apartado de 'VNC' y elegir la que más te guste. Por ejemplo *vinagre*

* **Agregar imágenes Ubuntu a GNS3**

<a name="ubuntu_host" id="ubuntu_host"></a>

*Plantilla de maquina host*  

Click en Nueva plantilla (new template)  

![](assets/gns3_5.png "Creando nueva plantilla (Este menú se encuentra al lado izquierdo)")

Seleccionar la opción 3.  
![](assets/gns3_6.png "Opción manual")

Click en Nuevo (new)  
![](assets/gns3_7.png "Creando nueva plantilla")

Click en existente  
Selecciona la imagen `srealmoreno/rae:latest`  
![](assets/gns3_8.png "Esta es la imagen Ubuntu que se utilizará")

Cambia el nombre a 'ubuntu' o 'pc'  
![](assets/gns3_9.png "Este nombre se verá en la topología")

Dejas la cantidad de adaptadores que gustes (adaptadores de red)  
![](assets/gns3_10.png "Son adaptadores ethernet")

Comando de inicio lo dejas vacío  
![](assets/gns3_11.png "El comando predeterminado es 'bash', es decir, entrará a la línea de ordenes automáticamente")

Tipo de consola: `telnet` ya que es en modo texto, si se desea agregar una con entorno gráfico elegir `vnc`  
![](assets/gns3_12.png "Debes de tener instalado la terminal a utilizar en la máquina física")

Variables de entorno lo dejas vacío    
![](assets/gns3_13.png)

Ya que se lo hayas añadido  
Click en editar  
![](assets/gns3_14.png)

Marca la opción de 'Auto start console'  
Click en 'Browse' para cambiar el icono  
![](assets/gns3_15.png "Este icono se verá en la topología")

Filtras por la palabra 'Computer'  
![](assets/gns3_16.png "Puedes escoger el que más te guste")

**Volúmenes persistentes**
<a name="volumen_persistente_host" id="volumen_persistente_host"></a>

Ahora ve a avanzado y agrega las siguientes líneas en la segunda caja de texto (volúmenes persistentes)  
```
/save
/etc/network
/etc/default
/root
```
GNS3 + Docker está pensado para gastar los menos recursos posibles. Ya sea memoria Ram y Disco duro.
**Cada vez que se cierra un contenedor de docker todos los ficheros _eliminan_**  
Estas rutas a ficheros y carpetas quedarán **guardadas** aunque el contenedor se cierre.
**Si quieres guardar un script hazlo en el directorio `/save/`**
Si quieres que otro fichero o carpeta se guarde, simplemente agrega la ruta **absoluta**.

De esta manera cada práctica pesa lo menos posible, a excepción de Netgui que es muy pesado en Disco.

Nota importante: 
**JAMÁS agregues todo el sistema de ficheros o `/` porque puede dañar la maquina física.**

[Leer&#32;más&#32;en&#32;docs&#32;GNS3](https://docs.gns3.com/1KGkv1Vm5EgeDusk1qS1svacpuQ1ZUQSVK3XqJ01WKGc/index.html#h.7s4z7hjkewuv)  

[Leer&#32;más&#32;en&#32;docs&#32;Docker](https://docs.docker.com/storage/volumes/)  

![](assets/gns3_17.png "Todo lo que se encuentre dentro de esos directorios, quedará conservado aunque se apague la máquina física")

Listo, se agrego el icono.  
![](assets/gns3_18.png)

¡Listo!


<a name="ubuntu_router" id="ubuntu_router"></a>
*Plantilla de router*  

Para plantilla de router es el mismo procedimiento pero con algunas modificaciones.  

Cambia el nombre  
![](assets/gns3_19.png "Este nombre se verá en la topología")

Número de adaptadores  
![](assets/gns3_20.png "Son adaptadores ethernet")

Comando de inicio  
```bash
bash -c "/etc/init.d/frr start; vtysh; bash"
```
De esta forma nos aseguramos que cada vez que arranque el contenedor arranque el servicio y entre a modo Cisco automáticamente  

![](assets/gns3_21.png)

Cambia la categoría de 'End devices' a 'Router'  
![](assets/gns3_22.png "Esto es para tener orden")

Cambia el icono  
![](assets/gns3_15.png "Este icono se verá en la topología")

<a name="volumen_persistente_router" id="volumen_persistente_router"></a>

y por ultimo se agregan los volúmenes persistentes  

```
/save
/etc/network
/etc/default
/etc/dhcp
/etc/frr
/root
```
![](assets/gns3_24.png "Todo lo que se encuentre dentro de esos directorios, quedará conservado aunque se apague la máquina física")

¡Listo!


<a name="ubuntu_switch" id="ubuntu_switch"></a>

*Plantilla de Switch*

La plantilla para usar la imagen como switch es similar a la plantilla de Host
Simplemente clona la plantilla

Cambia el nombre a 'Switch'  
![](assets/gns3_25.png "Este nombre se verá en la topología")

Cambia la categoría de 'End devices' a 'Switches'  
Cambia el icono  
Cambia el número de adaptadores      
![](assets/gns3_26.png)

¡Listo!

**Topología de prueba**  
![](assets/gns3_27.png)![](assets/gns3_28.png)

Para ver el consumo de los contenedores:
```bash
docker stats
```
¡WOW, Cada contenedor consume 4MiB de memoria RAM!  

![](assets/gns3_29.png "Este comando se ejecuta en la máquina física")

<a name="tipsgns3" id="tipsgns3"></a>
* **Tips de GNS3**  
Video de tips de GNS3 próximamente / [video](https://www.youtube.com/channel/UCXqFPKVslL_2b40djJWEc5A)

<a name="dockerfile" id="dockerfile"></a>
* **DockerFile**  
Puedes [ver](https://github.com/srealmoreno/rae/blob/master/dockerfile) el archivo [DockerFile](dockerfile/dockerfile) que construye la imagen base  
Si falta algún comando puedes agregarlo al dockerfile y reconstruir la imagen.  
Leer [tutorial](https://docs.docker.com/get-started/part2/) oficial de Docker para construir una imagen  
Ver [video](https://youtu.be/a8sf54TCRN4) tutorial construir una imagen   

<a name="wiki" id="wiki"></a>
## Wiki  
- Documentación oficial de [Docker](https://docs.docker.com/)  
<a href="https://docs.docker.com/install/linux/docker-ce/ubuntu/" target="_blank"> Guía de instalación de Docker</a>  

- Documentación oficial de [Gns3](https://docs.gns3.com/)  
<a href="https://docs.gns3.com/1QXVIihk7dsOL7Xr7Bmz4zRzTsJ02wklfImGuHwTlaA4/" target="_blank"> Guía de instalación de Gns3</a>  

- Documentación oficial de [VirtualBox](https://www.virtualbox.org/wiki/Documentation)  
<a href="https://www.virtualbox.org/wiki/Linux_Downloads"> Guía de instalación de VirtualBox</a>  

- [Netgui](http://mobiquo.gsyc.es/netgui/)

<a name="autores" id="autores"></a>
## Autores  

* **Salvador Real** - [srealmoreno](https://github.com/srealmoreno)

También puedes mirar la lista de todos los [contribuyentes](https://github.com/srealmoreno/rae/contributors) quíenes han participado en este proyecto.

<a name="licencia" id="licencia"></a>
## Licencia

Este proyecto está bajo la Licencia GNU General Public License v3.0 - mira el archivo [LICENSE.md](LICENSE.md) para más detalles

---
Redes de área extensa 2020 - Salvador real   
<img src="https://upload.wikimedia.org/wikipedia/commons/f/fd/UNAN.png" height="50px" align="right">

[![](https://img.shields.io/badge/%20-%20-grey?style=social&logo=gmail&label=Gmail)](https://mail.google.com/mail/u/0/?view=cm&fs=1&to=salvadorreal77@gmail.com&su=Manua%20de%20uso%20RAE&body=Hola,%20Salvador%20tengo%20una%20pregunta%20acerca%20del%20manual%20del%20repositorio%20RAE.) [![](https://img.shields.io/badge/%20-%20-grey?style=social&logo=facebook&label=facebook)](https://facebook.com/srealmoreno) [![](https://img.shields.io/github/followers/srealmoreno?label=Follow&style=social)](https://github.com/srealmoreno/)

