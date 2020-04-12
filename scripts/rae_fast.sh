#!/bin/bash
#####################################
#             UNAN-LEÓN             #
#  Script creado por Salvador Real  #
#   Redes de Area extensa 2020      #
#####################################

Green=$(tput setaf 10)
Blue=$(tput setaf 45)
Red=$(tput setaf 9)
Yellow=$(tput setaf 11)
White=$(tput setaf 15)
Normal=$(tput sgr0)

error_fatal() {
    echo -e "${Red}x Error fatal:${Normal} $@" >&2
    exit -1
}

info() {
  printf "${Blue}> Info: ${Normal} $@\n"
}

advertencia() {
    echo -e "${Yellow}! Advertencia: ${Normal}$@" >&2
}

exito() {
    echo -e "${Green}✓ Exíto: ${Normal}$@"
}


LIST_GROUP=""
LIST_PACKAGES=""
LIST_INSTALL=""
DISTRO=""

install_dependencies() {
   info "Instalando dependencias necesarias"
    apt install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        wget && exito "Dependencias instaladas con exíto" || error_fatal "Error al instalar las dependencias necesarias"
}

get_os() {
   info "Obteniendo información del sistema..."
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        if [[ "$ID" != "ubuntu" ]] && [[ "$ID_LIKE" != "ubuntu" ]]; then
            error_fatal "Este escript solo es compatible con Ubuntu y derivados"
        fi
        exito "Se detecto Sistema operativo $PRETTY_NAME ($VERSION_CODENAME)"
        advertencia "Este es una implementación de rapida instalación de los paquetes: $LIST_PACKAGES\nSalvador no se hace responsable de ningún daño a tu maquina. :D"
        read -n 1 -s -r -p "Presiona cualquier tecla para continuar"
        echo ""

        [ "$ID" == "ubuntu" ] && DISTRO=$VERSION_CODENAME || DISTRO=$UBUNTU_CODENAME

        if [ "$DISTRO" == "focal" ]; then
            DISTRO="eoan"
            DISTRO_TMP="focal"
        fi

        [ "$DISTRO" == "" ] && DISTRO="bionic"
    else
        error_fatal "No se puede determinar el SO"
    fi
}
check_group() {
    if [ ! "$(getent group "$1")" ]; then
        advertencia "No existe el grupo $1\nPor favor elige 'Sí' en el siguiente dialogo"
        read -n 1 -s -r -p "Presiona cualquier tecla para continuar"
        echo ""
        dpkg-reconfigure $2 || error_fatal "No se pudo crear el grupo $1"
    fi
}

add_repository_virtualbox() {
   info "Agregando repositorio de VirtualBox"
    wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add - &&
        wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | apt-key add - &&
        echo -e "#Repositorio agregado por Script de Salvador\n\
    \rdeb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $DISTRO contrib" \
            >"/etc/apt/sources.list.d/virtualbox-ubuntu-ppa-$DISTRO.list" || error_fatal "Error al añadir repositorio de VirtualBox"

    LIST_INSTALL="${LIST_INSTALL} virtualbox"
    LIST_GROUP="vboxusers"
}

add_repository_gns3() {
   info "Agregando repositorio de GNS3"
    [ -n "$DISTRO_TMP" ] && DISTRO=$DISTRO_TMP
    wget -q "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xf88f6d313016330404f710fc9a2fd067a2e3ef7b" -O- | apt-key add - &&
        echo -e "#Repositorio agregado por Script de Salvador\n\
        \rdeb http://ppa.launchpad.net/gns3/ppa/ubuntu $DISTRO main\n\
          \r#deb-src http://ppa.launchpad.net/gns3/ppa/ubuntu $DISTRO main" >"/etc/apt/sources.list.d/gns3-ubuntu-ppa-$DISTRO.list" || error_fatal "Error al añadir repositorio de GNS3"

    [ -n "$DISTRO_TMP" ] && DISTRO="eoan"

    dpkg --add-architecture i386

    [ "$LIST_GROUP" != "" ] && LIST_GROUP="$LIST_GROUP,"

    LIST_GROUP="${LIST_GROUP}libvirt,kvm,wireshark,ubridge"

    LIST_INSTALL="${LIST_INSTALL} gns3-gui gns3-server gns3-iou vinagre python3-pip"
}

add_repository_docker() {
   info "Agregando repositorio de Docker"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - &&
        echo -e "#Repositorio agregado por Script de Salvador\n\
    \rdeb [arch=amd64] https://download.docker.com/linux/ubuntu $DISTRO stable" >"/etc/apt/sources.list.d/docker-ubuntu-ppa-$DISTRO.list" || error_fatal "Error al añadir repositorio de Docker"

    [ "$LIST_GROUP" != "" ] && LIST_GROUP="$LIST_GROUP,"

    LIST_GROUP="${LIST_GROUP}docker"

    LIST_INSTALL="${LIST_INSTALL} docker-ce docker-ce-cli containerd.io"

}

create_launcher_shortcut_netgui() {
    if [ ! -f "/usr/share/mime/packages/netgui.xml" ] || [ ! -f "/usr/share/applications/netgui.desktop" ]; then
        apt install -y imagemagick
        if [ "$?" == 0 ]; then
           info "Creando Acceso directo y Creando asociacion de extensión .nkp (Project of Netgui)"
            wget https://raw.githubusercontent.com/srealmoreno/rae/master/assets/netgui.png -O /tmp/netgui.png
            for i in "256" "128" "96" "72" "64" "48" "32" "24" "16"; do
                convert "/tmp/netgui.png" -resize ${i}x${i} "/usr/share/icons/hicolor/${i}x${i}/apps/netgui.png"
                ln -sf "/usr/share/icons/hicolor/${i}x${i}/apps/netgui.png" "/usr/share/icons/hicolor/${i}x${i}/mimetypes/netgui.png"
            done
            update-icon-caches /usr/share/icons/hicolor

            echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<mime-info xmlns=\"http://www.freedesktop.org/standards/shared-mime-info\">
   <mime-type type=\"application/x-nkp\">
     <comment>Netgui Project File</comment>
     <glob pattern=\"*.nkp\"/>
     <icon name=\"netgui\"/>
   </mime-type>
</mime-info>" >/usr/share/mime/packages/netgui.xml

            update-mime-database /usr/share/mime

            echo "[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Exec=netgui.sh %f
Name=Netgui
Comment=Netgui Graphical Network Simulator
Icon=netgui
Categories=Education;Network;
MimeType=application/x-nkp;
Keywords=simulator;network;netsim;" >/usr/share/applications/netgui.desktop

            echo "[Desktop Entry]
Version=1.0
Type=Application
Terminal=true
Exec=clean-netgui.sh %f
Name=Clean-Netgui
Comment=Clean Netgui
Icon=netgui" >/usr/share/applications/clean_netgui.desktop
        fi
    fi
}

install_netgui() {
   info "Instalando netgui"
    if [ ! -d "/usr/local/netkit" ]; then
        local NETGUI_VERSION=0.4.10
        [ "$ID" == "ubuntu" ] && local HAS_UBUNTU="$ID"
        [ "$ID" == "mint" ] && local HAS_LINUXMINT="$ID"
        local UBUNTU_VERSION=${VERSION_ID%.*}
        local LINUXMINT_VERSION=${VERSION_ID%.*}
        local HAS_64BITS=$(uname -a | grep x86_64)

        if [ ! -z "$HAS_UBUNTU" -a $UBUNTU_VERSION -gt 8 ]; then
            AUTO=OK
        elif [ ! -z "$HAS_LINUXMINT" -a $LINUXMINT_VERSION -ge 17 ]; then
            AUTO=OK
        fi

        if [ ! -z "$AUTO" ]; then
            apt update
            if [ ! -z "$HAS_UBUNTU" -a $UBUNTU_VERSION -ge 16 ]; then
                apt -y install default-jre
                if [ ! -z "$HAS_64BITS" ]; then
                    apt -y install lib32z1 lib32ncurses5 libbz2-1.0:i386
                    apt -y install libc6-i386 lib32readline6
                fi
                DEBIAN_FRONTEND=noninteractive apt install -y -q wireshark
            elif [ ! -z "$HAS_LINUXMINT" -a $LINUXMINT_VERSION -ge 18 ]; then
                apt -y install default-jre
                if [ ! -z "$HAS_64BITS" ]; then
                    apt -y install lib32z1 lib32ncurses5 libbz2-1.0:i386
                    apt -y install libc6-i386 lib32readline6
                fi
                DEBIAN_FRONTEND=noninteractive apt install -y -q wireshark
            else
                apt -y install openjdk-6-jre
                apt -y install openjdk-8-jre
                if [ -d /usr/lib/jvm ]; then
                    if [ ! -e /usr/lib/jvm/default-java ]; then
                        if [ -e /usr/lib/jvm/java-8-openjdk-amd64 ]; then
                            ln -s /usr/lib/jvm/java-8-openjdk-amd64 /usr/lib/jvm/default-java
                        elif [ -e /usr/lib/jvm/java-6-openjdk-amd64 ]; then
                            ln -s /usr/lib/jvm/java-6-openjdk-amd64 /usr/lib/jvm/default-java
                        fi
                    fi
                fi
                if [ ! -z "$HAS_64BITS" ]; then
                    apt -y install ia32-libs libc6-i386 lib32readline6
                    apt -y install libc6-i386 lib32readline6
                    apt -y install lib32z1 lib32ncurses5 lib32bz2-1.0
                    apt -y install lib32bz2-1.0
                    apt -y install libbz2-1.0:i386
                fi
                apt -y install wireshark
            fi
            apt -y install xterm xwit telnetd pv
            cd /tmp

            local size_tmp=$(stat --format=%s netgui-${NETGUI_VERSION}.tar.bz2 2>/dev/null)
            local size_internet=$(curl -sI http://mobiquo.gsyc.es/netgui-${NETGUI_VERSION}/netgui-${NETGUI_VERSION}.tar.bz2 | grep Content-Length | cat -v | cut -d ' ' -f 2 | sed -e "s/\^M//")
            if [ "$size_tmp" != "$size_internet" ]; then
                rm -f netgui-${NETGUI_VERSION}.tar.bz2
               info "Descargando Netgui"
                wget http://mobiquo.gsyc.es/netgui-${NETGUI_VERSION}/netgui-${NETGUI_VERSION}.tar.bz2
            else
               info "Utilizando fichero tempral /tmp/netgui-${NETGUI_VERSION}.tar.bz2"
            fi
            cd /usr/local
            rm -rf netkit
           info "Desempaquetando Netgui"
            pv /tmp/netgui-${NETGUI_VERSION}.tar.bz2 | tar -xjSf -
            ln -fs /usr/local/netkit/netgui/bin/netgui.sh /usr/local/bin
            ln -fs /usr/local/netkit/netgui/bin/clean-netgui.sh /usr/local/bin
            ln -fs /usr/local/netkit/netgui/bin/clean-vm.sh /usr/local/bin
            echo

            create_launcher_shortcut_netgui

            rm /etc/apt/sources.list.d/webupd8team* 2>/dev/null

            exito "NetGui instalado con exíto"
        else
            error_fatal "autoinstall only works in Ubuntu >= 9.04 or Linux Mint >= 17, sorry"
        fi
    else
        exito "Netgui ya se encuentra instalado"
        create_launcher_shortcut_netgui
    fi

}

importar_a_docker() {
   info "Instalando imagen docker $1 de Salvador"
    if [ -f "$2" ]; then
       info "Importando $2"
        docker load --input "$2"
    else
        advertencia "No se pudo encontrar la imagen local... Descargando imagen $2 desde internet: $3"
        docker pull $3
    fi && exito "Imagen $1 de Salvador instalada en docker" || advertencia "No se pudo instalar la imagen $1 de Salvador"
}

install_packages() {
    local LIST_PACKAGES_INSTALLED=""
    for i in virtualbox gns3 docker; do
        if [ -n "${!i}" ]; then
            [ "$LIST_PACKAGES_INSTALLED" != "" ] && LIST_PACKAGES_INSTALLED="$LIST_PACKAGES_INSTALLED, "
            LIST_PACKAGES_INSTALLED="${LIST_PACKAGES_INSTALLED}${i^}"
        fi
    done
   info "Instalando $LIST_PACKAGES_INSTALLED"
    
    apt update && apt install -y $LIST_INSTALL && exito "$LIST_PACKAGES_INSTALLED instalado(s) con exíto" || error_fatal "No se pudo instalar $LIST_PACKAGES"

    if [ -n "$gns3" ]; then
        advertencia "Comprobando si hay errores en el entorno de GNS3"
        local version_pyqt_installed=$(pip3 show pyqt5 | grep Version: | cut -d ' ' -f2)
        local version_min=5.13.1
        [ "$version_pyqt_installed" != "" ] &&
            if [ ${version_pyqt_installed//./} -lt ${version_min//./} ]; then
                advertencia "Se encontró un error: librería Pyqt5.\nGns3 necesita version mínima: $version_min, tienes instalada: $version_pyqt_installed"
                pip3 install pyqt5==$version_min && exito "GNS3 reparando con exíto"
            else
                exito "No se encontraron errores"
            fi
        check_group "wireshark" "wireshark-common"
        check_group "ubridge" "ubridge"
    fi

   info "Añadiendo $SUDO_USER a los grupos necesarios"
    usermod -aG $LIST_GROUP $SUDO_USER
}

clean_cache() {
   info "Limpiando caché"
    apt autoremove -y
    [ -f /tmp/netgui.png ] && rm /tmp/netgui.png
}

############## Inicio del Script ###################

if [ "$EUID" != "0" ]; then #Si no es el usuario root, se sale
    error_fatal "Debe de ejecutar el script con permisos root\nsudo $0"
fi

if [ "$#" == "0" ]; then #Si no se pasa ningún argumento, instala todo
    gns3="true"
    docker="true"
    virtualbox="true"
    netgui="true"
    images="true"
    LIST_PACKAGES="VirtualBox, GNS3, Docker, Imágenes docker de Salvador, Netgui"
else
    while getopts ":h :a :d :g :i :v :n" arg; do #a instala todo, d instala docker, g instala gns3, i instala images de salvador
        case "$arg" in
        a)
            gns3="true"
            docker="true"
            virtualbox="true"
            netgui="true"
            images="true"
            LIST_PACKAGES="VirtualBox, GNS3, Docker, Imágenes docker de Salvador, Netgui"
            ;;
        g)
            gns3="true"
            [ "$LIST_PACKAGES" != "" ] && LIST_PACKAGES="$LIST_PACKAGES, "
            LIST_PACKAGES="${LIST_PACKAGES}GNS3"
            ;;
        d)
            docker="true"
            [ "$LIST_PACKAGES" != "" ] && LIST_PACKAGES="$LIST_PACKAGES, "
            LIST_PACKAGES="${LIST_PACKAGES}Docker"
            ;;
        v)
            virtualbox="true"
            [ "$LIST_PACKAGES" != "" ] && LIST_PACKAGES="$LIST_PACKAGES, "
            LIST_PACKAGES="${LIST_PACKAGES}VirtualBox"
            ;;
        n)
            netgui="true"
            [ "$LIST_PACKAGES" != "" ] && LIST_PACKAGES="$LIST_PACKAGES, "
            LIST_PACKAGES="${LIST_PACKAGES}Netgui"
            ;;
        i)
            images="true"
            [ "$LIST_PACKAGES" != "" ] && LIST_PACKAGES="$LIST_PACKAGES, "
            LIST_PACKAGES="${LIST_PACKAGES}Imágenes docker de Salvador"
            ;;
        h)
            echo "Uso: $0 [-a instalar todo] [-d instalar docker] [-g instalar gns3] [-v instalar virtualbox] [-n instalar netgui] [-i importar images docker]"
            exit 0
            ;;
        *)
            error_fatal "Argumentos no validos\n$*\nUso $0 [-a Instalar todo] [-d instalar docker] [-g instalar gns3] [-v instalar virtualbox] [-n instalar netgui] [-i importar images docker]"
            ;;
        esac
    done
fi

exito "Iniciando Script de instalación"

if [ -n "$docker" ] || [ -n "$gns3" ] || [ -n "$virtualbox" ] || [ -n "$netgui" ]; then
    get_os
    install_dependencies
fi

if [ -n "$virtualbox" ]; then
    add_repository_virtualbox
fi

if [ -n "$gns3" ]; then
    add_repository_gns3
fi

if [ -n "$docker" ]; then
    add_repository_docker
fi

if [ -n "$docker" ] || [ -n "$gns3" ] || [ -n "$virtualbox" ]; then
    install_packages
fi

if [ -n "$images" ]; then
    importar_a_docker "ubuntu" "ubuntu_rae.tar" "srealmoreno/rae"
    #Descomentar para instalar la imagen con interfaz gráfica
    #importar_a_docker "ubuntu_graphic" "ubuntu_rae_graphic.tar" "srealmoreno/rae_graphic"
fi

if [ -n "$netgui" ]; then
    install_netgui
fi

if [ -n "$docker" ] || [ -n "$gns3" ] || [ -n "$virtualbox" ] || [ -n "$netgui" ]; then
    clean_cache
fi

exito "Instalación completada\nby: Salvador Real, Redes de area extensa 2020"
