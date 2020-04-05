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

<img  src="/.assets/ejemplo_1.png"> </img>

Por ejemplo si solo se desea instalar Docker e importar imágenes:

```
sudo ./rae_fast.sh -d -i
```

Al finalizar debes cerrar sesión y notáras que los iconos de las aplicaciones se agregaron.

Docker no es [GUI](https://es.wikipedia.org/wiki/Interfaz_gr%C3%A1fica_de_usuario)

<img src="/.assets/ejemplo_2.png"> </img>

<a name="gns3" id="gns3"></a>

## Integración de GNS3 con Docker

* **Configuración inicial de GNS3**

Seleccionar la opción 2.  
<img src="/.assets/gns3_1.png">  

Dejar sin cambios.  
<img src="/.assets/gns3_2.png">  

¡Listo!  
<img src="/.assets/gns3_3.png">  
<img src="/.assets/gns3_4.png">  


* **Corrigiendo / Cambiando consola predeterminada**  
Ir a Edición -> Preferencias.  
Click en Aplicaciones de consola (Console applications)  
Click en Editar (Edit)  
<img  src="/.assets/gns3_console_1.png">  

Elegir la predeterminada del sistema o la que más te guste.  
**Ubuntu** (gnome) utiliza gnome-terminal  
**Kubuntu** (kde plasma) utliza Konsole  
<img src="/.assets/gns3_console_2.png">  

Luego Aplicar cambios y listo.  

* **Agregar imágenes Ubuntu a GNS3**

*Plantilla de maquina host*  

Click en Nueva plantilla (new template)  
<img src="/.assets/gns3_5.png">  

Selecionar la opción 3.  
<img src="/.assets/gns3_6.png">  

Click en Nuevo (new)
<img src="/.assets/gns3_7.png">  

Click en existente  
Selecciona la imagen `srealmoreno/rae:latest`
<img src="/.assets/gns3_8.png">  

Cambia el nombre a 'ubuntu' o 'pc'  
<img src="/.assets/gns3_9.png">  

Dejas la cantidad de adaptadores que gustes (adaptadores de red)  
<img src="/.assets/gns3_10.png">  

Comando de inicio lo dejas vacío  
<img src="/.assets/gns3_11.png">  

Tipo de consola: Telnet ya que es en modo texto  
<img src="/.assets/gns3_12.png">

Variables de entorno lo dejas vacío  
<img src="/.assets/gns3_13.png">

Ya que se lo hayas añadido
Click en editar
<img src="/.assets/gns3_14.png">

Marca la opción de 'Auto start console'  
Click en 'Browse' para cambiar el icono  
<img src="/.assets/gns3_15.png">  

Filtras por la palabra 'Computer'    
<img src="/.assets/gns3_16.png">  

Ahora ve a avanzado y agrega las siguientes líneas en la segunda caja de texto (volumenes persistentes)  
```
/save/
/etc/network
/etc/hosts
/root/.bash_history
/root/.bashsrc
```
<img src="/.assets/gns3_17.png">  

GNS3 + Docker está pensado para gastar lo menos recursos posibles. Ya sea memoria Ram y Disco duro.
**Cada vez que se cierra un contenedor de docker todos los ficheros _eliminan_**  
Estas rutas a ficheros y carpetas quedarán **guardadas** aunque el contenedor se cierre.
**Si quieres guardar un script hazlo en el directorio `/save/`**
Si quieres que otro fichero o carpeta se guarde, simplemente agrega la ruta **absoluta**.

De esta manera cada práctica pesa lo menos posible, a excepción de Netgui que es muy pesado en Disco.

Nota importante: 
**JAMÁS agregues todo el sistema de ficheros o `/` porque puede dañar la maquina física.**

[leer_más  ](https://docs.gns3.com/1KGkv1Vm5EgeDusk1qS1svacpuQ1ZUQSVK3XqJ01WKGc/index.html#h.7s4z7hjkewuv)  

Listo, se agrego el icono.  
<img src="/.assets/gns3_18.png">  

¡Listo!

*Plantilla de router*  

Para plantilla de router es el mismo procedimiento pero con algunas modificaciones.  

Cambia el nombre  
<img src="/.assets/gns3_19.png">  

Número de adaptadores  
<img src="/.assets/gns3_20.png">  

Comando de inicio  
```
bash -c "/etc/init.d/frr start; vtysh; bash"
```
<img src="/.assets/gns3_21.png">  
De esta forma nos aseguramos que cada vez que arranque el contenedor arranque el servicio y entre a modo Cisco automaticamente  

Cambia la categoría de 'End devices' a 'Router'  
<img src="/.assets/gns3_22.png">  

Cambia el icono  
<img src="/.assets/gns3_23.png">   

y por ultimo se agregan 2 rutas a los volumenes persistentes  

```
/save/
/etc/network
/etc/hosts
/root/.bash_history
/root/.bashsrc
/root/.history_frr
/etc/frr
```
<img src="/.assets/gns3_24.png">  

¡Listo!

*Plantilla de Switch*

La plantilla para usar la imagen como switch es similar a la plantilla de Host
Simplemente clona la plantilla

Cambia el nombre a 'Switch'  
<img src="/.assets/gns3_25.png">    


Cambia la categoría de 'End devices' a 'Switch'  
Cambia el icono  
Cambia el número de adaptadores      
<img src="/.assets/gns3_26.png">    

¡Listo!

**Topología de prueba**
<img align="left" src="/.assets/gns3_27.png">  
<img align="right" src="/.assets/gns3_28.png">  

---