# Manual de Uso
===================================

### Se explicará:
- <a href="#script"> Uso del script de instalación para: </a>
	* VirtualBox
	* GNS3
	* Docker
	* Netgui
	* Imáganes Ubuntu elaboradas para el uso de Redes

- <a href="#gns3"> Integración de imágenes Docker a GNS3 para: </a>
	* Uso como máquina host
	* Uso como Router
	* Uso como Switch

### Requisitos
* Sistema operativo: Ubuntu o derviados 
* Conexión a Internet.
* apt como gestor de paquetes.

<a name="script" id="script"></a>

## Uso del script de instalación
Hay 2 versiones del script. una lenta pero segura (rae.sh) y otra más rápida pero no tan segura (rae_fast.sh) yo probé ambos scripts en máquinas virtuales. Recomiendo usar rae_fast.sh y si da algún error usa rae.sh

El script te da a escoger que paquetes deseas instalar. Cada paquete es la inicial de su nombre.

Descarga:
Puedes descargar el script desde la línea de ordenes o desde tu navegador favorito.

```
wget https://raw.githubusercontent.com/srealmoreno/rae/master/rae_fast.sh
```

Dar permisos de ejecución
```
chmod +x rae_fast.sh
```

Ejecución del script
```
sudo ./rae_fast.sh
```

Para ver ayuda -h (help en inglés)
```
sudo ./rae_fast.sh -h
```

Nota: Si no se pasa ningún parametro, se  instalan todos los paquetes dichos.

<img align="left" src="/.assets/ejemplo_1.png"> </img>

Por ejemplo si solo se desea instalar Docker e importar imágenes:

```
sudo ./rae_fast.sh -d -i
```

Al finalizar debes cerrar sesión y notáras que los iconos de las aplicaciones se agregarón.

Docker no es [GUI](https://es.wikipedia.org/wiki/Interfaz_gr%C3%A1fica_de_usuario)

<img align="left" src="/.assets/ejemplo_2.png"> </img>\

<a name="gns3" id="gns3"></a>

## Integración de GNS3 con Docker

**Configuración inicial de GNS3.**

Seleccionar la opción 2.  
<p><img align="left" src="/.assets/gns3_1.png"> </img></p>

Dejar sin cambios.
<p><img align="left" src="/.assets/gns3_2.png"> </img></p>
¡Listo!
<p><img align="left" src="/.assets/gns3_3.png"> </img></p>
<p><img align="left" src="/.assets/gns3_4.png"> </img></p>

_**Corrigiendo / Cambiando consola predeterminada.**_
Ir a Edición -> Preferencias.  
Click en Aplicaciones de consola (Console applications)  
Click en Editar (Edit)  
<img align="left" src="/.assets/gns3_console_1.png"> </img>  

Elegir la predeterminada del sistema o la que más te guste.  
**Ubuntu** (gnome) utiliza gnome-terminal  
**Kubuntu** (kde plasma) utliza Konsole  
<img align="left" src="/.assets/gns3_console_2.png"> </img>  

Luego Aplicar cambios y listo.  

**Agregar imágenes Ubuntu a GNS3.**  

Click en Nueva plantilla (new template)  
<img align="left" src="/.assets/gns3_5.png"> </img>  

Selecionar la opción 3.  
<img align="left" src="/.assets/gns3_6.png"> </img>  
---