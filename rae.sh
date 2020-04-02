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
    echo -e "${Red}Error fatal:${Normal} $1" >&2
    exit -1
}

advertencia() {
    echo -e "${Yellow}Advertencia: ${Normal}$1" >&2
}

exito() {
    echo -e "${Green}Exíto: ${Normal}$1"
}

LIST_GROUP=""
DISTRO=""

install_dependencies() {
    advertencia "Instalando dependencias necesarias"
    apt install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        wget && exito "Dependencias instaladas con exíto" || error_fatal "Error al instalar las dependencias necesarias"
}

get_os() {
    advertencia "Obteniendo información del sistema..."
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        if [[ "$ID" != "ubuntu" ]] && [[ "$ID_LIKE" != "ubuntu" ]]; then
            error_fatal "Este escript solo es compatible con Ubuntu y derivados"
        fi
        exito "Se detecto Sistema operativo $PRETTY_NAME ($VERSION_CODENAME)"
        advertencia "Salvador no se hace responsable de ningún daño a tu maquina. :D"
        read -n 1 -s -r -p "Presiona cualquier tecla para continuar"
        echo ""
        [ "$ID" == "ubuntu" ] && DISTRO=$VERSION_CODENAME || DISTRO=$UBUNTU_CODENAME

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

install_virtualbox() {
    advertencia "Instalando Virtualbox"
    wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add - &&
        wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | apt-key add - &&
        echo -e "#Repositorio agregado por Script de Salvador\n\
    \rdeb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $DISTRO contrib" \
            >"/etc/apt/sources.list.d/virtualbox-ubuntu-ppa-$DISTRO.list" &&
        apt update && apt install -y virtualbox && exito "VirtualBox instalado con exíto" || advertencia "No se pudo instalar VirtualBox"
    LIST_GROUP="vboxusers"
}

install_gns3() {
    #apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F88F6D313016330404F710FC9A2FD067A2E3EF7B &&
    advertencia "Instalando Gns3"
    wget -q "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xf88f6d313016330404f710fc9a2fd067a2e3ef7b" -O- | apt-key add - &&
        echo -e "#Repositorio agregado por Script de Salvador\n\
        \rdeb http://ppa.launchpad.net/gns3/ppa/ubuntu $DISTRO main\n\
          \r#deb-src http://ppa.launchpad.net/gns3/ppa/ubuntu $DISTRO main" >"/etc/apt/sources.list.d/gns3-ubuntu-ppa-$DISTRO.list" || error_fatal "Error al añadir repositorio de GNS3"

    dpkg --add-architecture i386 &&
        apt update &&
        apt install -y gns3-gui gns3-server &&
        exito "Gns3 instalado con exito" || advertencia "No se pudo instalar GNS3"

    advertencia "Reparando errores de GNS3"
    apt install -y python3-pip && pip3 install pyqt5==5.13.1 && exito "GNS3 reparando con exíto"

    advertencia "Agregando soporte iou en GNS3"
    apt install -y gns3-iou

    [ "$LIST_GROUP" != "" ] && LIST_GROUP="$LIST_GROUP,"

    LIST_GROUP="${LIST_GROUP}libvirt,kvm,wireshark,ubridge"
    check_group "wireshark" "wireshark-common"
    check_group "ubridge" "ubridge"
}

install_docker() {
    advertencia "Instalando Docker"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - &&
        echo -e "#Repositorio agregado por Script de Salvador\n\
    \rdeb [arch=amd64] https://download.docker.com/linux/ubuntu $DISTRO stable" >"/etc/apt/sources.list.d/docker-ubuntu-ppa-$DISTRO.list" || error_fatal "Error al añadir repositorio de Docker"
    apt update && apt install -y docker-ce docker-ce-cli containerd.io && exito "Docker-ce Instalado con exíto" || error_fatal "error al instalar Docker-ce"
    [ "$LIST_GROUP" != "" ] && LIST_GROUP="$LIST_GROUP,"
    LIST_GROUP="${LIST_GROUP}docker"
}

install_netgui() {
    advertencia "Instalando netgui"
    local NETGUI_VERSION=0.4.10
    local HAS_UBUNTU=$(cat /etc/issue | cut -f 1 -d " " | grep -i ubuntu)
    local HAS_LINUXMINT=$(cat /etc/issue | cut -f 2 -d " " | grep -i mint)
    local UBUNTU_VERSION=$(($(cat /etc/issue | cut -f 2 -d " " | cut -f1 -d ".")))
    local UBUNTU_MINORVERSION=$(($(cat /etc/issue | cut -f 2 -d " " | cut -f2 -d ".")))
    #local LINUXMINT_VERSION=$(($(cat /etc/issue | cut -f 3 -d " " | cut -f1 -d ".")))
    #local LINUXMINT_MINORVERSION=$(($(cat /etc/issue | cut -f 3 -d " " | cut -f2 -d ".")))
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
        rm -f netgui-${NETGUI_VERSION}.tar.bz2
        wget http://mobiquo.gsyc.es/netgui-${NETGUI_VERSION}/netgui-${NETGUI_VERSION}.tar.bz2
        cd /usr/local
        rm -rf netkit
        pv /tmp/netgui-${NETGUI_VERSION}.tar.bz2 | tar -xjSf -
        ln -fs /usr/local/netkit/netgui/bin/netgui.sh /usr/local/bin
        ln -fs /usr/local/netkit/netgui/bin/clean-netgui.sh /usr/local/bin
        ln -fs /usr/local/netkit/netgui/bin/clean-vm.sh /usr/local/bin
        echo
        apt install -y imagemagick
        if [ "$?" == 0 ]; then
            wget https://raw.githubusercontent.com/srealmoreno/rae/master/netgui.png -O /tmp/netgui.png
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

        rm /etc/apt/sources.list.d/webupd8team*

        exito "NetGui instalado con exíto"
    else
        error_fatal "autoinstall only works in Ubuntu >= 9.04 or Linux Mint >= 17, sorry"
    fi
}

importar_a_docker() {
    advertencia "Instalando imagen docker $1 de Salvador"
    if [ -f "$2" ]; then
        advertencia "Importando $2"
        docker load --input "$2"
    else
        advertencia "No se pudo encontrar la imagen local... Descargando imagen $2 desde internet: $3"
        docker pull $3
    fi && exito "Imagen $1 de Salvador instalada en docker" || advertencia "No se pudo instalar la imagen $1 de Salvador"
}

clean_cache() {
    advertencia "Limpiando caché"
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
else
    while getopts ":h :a :d :g :i :v :n" arg; do #a instala todo, d instala docker, g instala gns3, i instala images de salvador
        case "$arg" in
        a)
            gns3="true"
            docker="true"
            virtualbox="true"
            netgui="true"
            images="true"
            ;;
        g)
            gns3="true"
            ;;
        d)
            docker="true"
            ;;
        v)
            virtualbox="true"
            ;;
        n)
            netgui="true"
            ;;
        i)
            images="true"
            ;;
        *)
            error_fatal "Uso $0 [-a Instalar todo] [-d instalar docker] [-g instalar gns3] [-v instalar virtualbox] [-n instalar netgui] [-i importar images docker]"
            exit 1
            ;;
        esac
    done
fi

if [ -n "$docker" ] || [ -n "$gns3" ] || [ -n "$virtualbox" ] || [ -n "$netgui" ] || [ -n "$images" ]; then

    exito "Iniciando Script de instalación"

    if [ -n "$docker" ] || [ -n "$gns3" ] || [ -n "$virtualbox" ]; then
        get_os
        install_dependencies
    fi

    if [ -n "$virtualbox" ]; then
        install_virtualbox
    fi

    if [ -n "$gns3" ]; then
        install_gns3
    fi

    if [ -n "$docker" ]; then
        install_docker
    fi

    if [ -n "$images" ]; then
        importar_a_docker "ubuntu" "ubuntu_rae.tar" "srealmoreno/rae"
        #Descomentar para instalar la imagen con interfaz gráfica
        #importar_a_docker "ubuntu_graphic" "ubuntu_rae_graphic.tar" "srealmoreno/rae_graphic"
    fi

    if [ -n "$netgui" ]; then
        install_netgui
    fi

    if [ -n "$docker" ] || [ -n "$gns3" ] || [ -n "$virtualbox" ]; then
        advertencia "Añadiendo $SUDO_USER a los grupos necesarios"
        usermod -aG $LIST_GROUP $SUDO_USER
        clean_cache
    fi

    exito "Instalación completada\nby: Salvador Real, Redes de area extensa 2020"

else
    error_fatal "Argumentos no validos\n$*\nUso $0 [-a Instalar todo] [-d instalar docker] [-g instalar gns3] [-v instalar virtualbox] [-n instalar netgui] [-i importar images docker]"
    exit -1
fi
