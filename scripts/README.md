
![](https://img.shields.io/badge/%20-Bash-grey) ![](https://img.shields.io/badge/%20-Docker-blue) ![](https://img.shields.io/badge/%20-GNS3-green) ![](https://img.shields.io/badge/%20-Netgui-lightgrey) ![](https://img.shields.io/badge/%20-VirtalBox-lightblue") ![](https://img.shields.io/badge/Tutoriales-Srealmoreno-red?style=flat&logo=github)


# Scripts
Esta carpeta contiene los scripts de instalación de:
-   Docker
-   GNS3
-   VirtualBox
-   Netgui
-   Imágenes base 

### Requisitos
* Sistema operativo: Ubuntu o derivados 
	- Focal 20.0 (LTS)
	- Eoan 19.10
	- Bionic 18.04 (LTS)
	- Xenial 16.04 (LTS)
* Conexión a Internet.
* apt como gestor de paquetes.

## Uso del script de instalación
Hay 2 versiones del script. una lenta pero segura `rae.sh` y otra más rápida pero no tan segura `rae_fast.sh` yo probé ambos scripts en máquinas virtuales. Recomiendo usar `rae_fast.sh` y si da algún error usa `rae.sh`

Perdón por no comentar el código, no me dio tiempo en 3 días, es algo largo. cualquier duda envía un correo.

El script te da a escoger que paquetes deseas instalar. Cada paquete es la inicial de su nombre.

Descarga:
Puedes descargar el script desde la línea de ordenes o desde tu navegador favorito.

Descargar desde el navegador:  

Descargar [rae.sh](rae.sh)  
Descargar [rae_fast.sh](rae_fast.sh) 

`Click en  '`**`Raw`**`' -> Click derecho -> Guardar Como`

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

![](../assets/ejemplo_1.png "Ejemplo de salida del script")

Por ejemplo si solo se desea instalar Docker e importar imágenes:

```bash
sudo ./rae_fast.sh -d -i
```

Al finalizar debes cerrar sesión y notáras que los iconos de las aplicaciones se agregaron.

Docker no es [GUI](https://es.wikipedia.org/wiki/Interfaz_gr%C3%A1fica_de_usuario)

![](../assets/ejemplo_2.png "Menú de aplicaciones")  

## Netgui
Aclaro, tomé el [script](http://mobiquo.gsyc.es/netgui/netgui-autoinstall.sh) de auto instalación de netgui, modifique algunas cosas para hacerlo compatible con Ubuntu 20.0 LTS, crear un lanzador y registrar la asociación del fichero

## Wiki
- Documentación oficial de [Docker](https://docs.docker.com/)  
<a href="https://docs.docker.com/install/linux/docker-ce/ubuntu/" target="_blank"> Guía de instalación de Docker</a>  

- Documentación oficial de [Gns3](https://docs.gns3.com/)  
<a href="https://docs.gns3.com/1QXVIihk7dsOL7Xr7Bmz4zRzTsJ02wklfImGuHwTlaA4/" target="_blank"> Guía de instalación de Gns3</a>  

- Documentación oficial de [VirtualBox](https://www.virtualbox.org/wiki/Documentation)  
<a href="https://www.virtualbox.org/wiki/Linux_Downloads"> Guía de instalación de VirtualBox</a>  

- [Netgui](http://mobiquo.gsyc.es/netgui/)
    
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

