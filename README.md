# Manual de Uso
===================================

### Se explicará:
- Uso del script de instalación para:
	* VirtualBox
	* GNS3
	* Docker
	* Netgui
	* Imáganes Ubuntu elaboradas para el uso de Redes

- Integración de imágenes Docker a GNS3 para:
	* Uso como máquina host
	* Uso como Router
	* Uso como Switch

### Requisitos
* Sistema operativo: Ubuntu o derviados 
* Conexión a Internet.
* apt como gestor de paquetes.

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

<img src="/.assets/ejemplo_1.png"/>

Por ejemplo si solo se desea instalar Docker e importar imágenes:

```
sudo ./rae_fast.sh -d -i
```

Al finalizar debes cerrar sesión y notáras que los iconos de las aplicaciones se agregarón. [(Docker no es GUI)] (https://es.wikipedia.org/wiki/Interfaz_gr%C3%A1fica_de_usuario)

<img src="/.assets/ejemplo_2.png"/>

## Integración de GNS3 con Docker 