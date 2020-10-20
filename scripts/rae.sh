#!/bin/bash
#####################################
#             UNAN-LEÓN             #
#  Script creado por Salvador Real  #
#     Redes de Area extensa 2020    #
#       Soporte para IPv6 2021      #
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
        advertencia "Salvador no se hace responsable de ningún daño a tu maquina. :D"
        read -n 1 -s -r -p "Presiona cualquier tecla para continuar"
        echo ""

        [ "$ID" == "ubuntu" ] && DISTRO=$VERSION_CODENAME || DISTRO=$UBUNTU_CODENAME

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
    info "Instalando Virtualbox"
    wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add - &&
        wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | apt-key add - &&
        echo -e "#Repositorio agregado por Script de Salvador\ndeb [arch=amd64] http://download.virtualbox.org/virtualbox/debian $DISTRO contrib" \
            >"/etc/apt/sources.list.d/virtualbox-ubuntu-ppa-$DISTRO.list" &&
        apt update && apt install -y virtualbox && exito "VirtualBox instalado con exíto" || advertencia "No se pudo instalar VirtualBox"
    LIST_GROUP="vboxusers"
}

install_gns3() {
    #apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F88F6D313016330404F710FC9A2FD067A2E3EF7B &&
    info "Instalando Gns3"

    wget -q "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xf88f6d313016330404f710fc9a2fd067a2e3ef7b" -O- | apt-key add - &&
        echo -e "#Repositorio agregado por Script de Salvador\ndeb http://ppa.launchpad.net/gns3/ppa/ubuntu $DISTRO main\n#deb-src http://ppa.launchpad.net/gns3/ppa/ubuntu $DISTRO main" >"/etc/apt/sources.list.d/gns3-ubuntu-ppa-$DISTRO.list" || error_fatal "Error al añadir repositorio de GNS3"

    dpkg --add-architecture i386 &&
        apt update && apt install -y gns3-gui gns3-server vinagre

    if [ "$?" == "0" ]; then
        sed -i "81,87s/^#*/#/" /usr/share/gns3/gns3-server/lib/python3.7/site-packages/gns3server/compute/docker/resources/init.sh 2>/dev/null
        exito "Gns3 instalado con exito"
        advertencia "Comprobando si hay errores en el entorno de GNS3"
        apt install -y python3-pip
        if [ "$?" == "0" ]; then
            local version_pyqt_installed=$(pip3 show pyqt5 | grep -oP "(?<=Version: ).+")
            local version_min=5.13.1
            [ "$version_pyqt_installed" != "" ] &&
                if [ ${version_pyqt_installed//./} -lt ${version_min//./} ]; then
                    advertencia "Se encontró un error: librería Pyqt5.\nGns3 necesita version mínima: $version_min, tienes instalada: $version_pyqt_installed"
                    pip3 install pyqt5==$version_min && exito "GNS3 reparando con exíto"
                else
                    exito "No se encontraron errores"
                fi

        else
            advertencia "No se pudo comprobar"
        fi
        info "Agregando soporte iou en GNS3"
        apt install -y gns3-iou && exito "Soporte IOU agrego en gns3 con exíto" || advertencia "No se pudo agregar soporte IOU en Gns3"

        [ "$LIST_GROUP" != "" ] && LIST_GROUP="$LIST_GROUP,"

        LIST_GROUP="${LIST_GROUP}libvirt,kvm,wireshark,ubridge"
        check_group "wireshark" "wireshark-common"
        check_group "ubridge" "ubridge"

        if [ ! -f "/home/$SUDO_USER/.config/GNS3/2.2/gns3_controller.conf" ]; then
            sudo -u $SUDO_USER gns3server >/dev/null &
            sleep 1s
            killall gns3server
        fi
    else
        info "No se pudo instalar GNS3"
    fi
}

install_docker() {
    advertencia "Instalando Docker"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - &&
        echo -e "#Repositorio agregado por Script de Salvador\ndeb [arch=amd64] https://download.docker.com/linux/ubuntu $DISTRO stable" >"/etc/apt/sources.list.d/docker-ubuntu-ppa-$DISTRO.list" || error_fatal "Error al añadir repositorio de Docker"
    apt update && apt install -y docker-ce docker-ce-cli containerd.io && exito "Docker-ce Instalado con exíto" || error_fatal "error al instalar Docker-ce"
    [ "$LIST_GROUP" != "" ] && LIST_GROUP="$LIST_GROUP,"
    LIST_GROUP="${LIST_GROUP}docker"
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
            local size_internet=$(curl -sI http://mobiquo.gsyc.es/netgui-${NETGUI_VERSION}/netgui-${NETGUI_VERSION}.tar.bz2 | grep -oP "(?<=Content-Length: )\d+")
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

info_computer=("pc_docker" "aaaabbbb-cccc-dddd-eeee-ffff12345678")
info_router=("router_docker" "aaaabbbb-cccc-dddd-eeee-ffff12345677")
info_switch=("switch_docker" "aaaabbbb-cccc-dddd-eeee-ffff12345676")

create_template() {
    if [ $1 == "computer" ]; then
        local default_name_format="pc{0}"
        local symbol=":/symbols/classic/computer.svg"
        local category="guest"
        local name=${info_computer[0]}
        local adapters="1"
        local extra_volumes='["/save", "/etc/network", "/etc/default", "/root"]'
        local template_id=${info_computer[1]}
    elif [ $1 == "router" ]; then
        local default_name_format="r{0}"
        local symbol=":/symbols/classic/router.svg"
        local category="router"
        local name=${info_router[0]}
        local adapters="5"
        local extra_volumes='["/save","/etc/network","/etc/default","/etc/dhcp","/etc/frr","/root"]'
        local template_id=${info_router[1]}
    else
        local default_name_format="s{0}"
        local symbol=":/symbols/classic/ethernet_switch.svg"
        local category="switch"
        local name=${info_switch[0]}
        local adapters="8"
        local extra_volumes='["/save","/etc/network","/etc/default","/root"]'
        local template_id=${info_switch[1]}
    fi

    echo "
{
\"default_name_format\": \"$default_name_format\",
\"usage\": \"\",
\"symbol\": \"$symbol\",
\"category\": \"$category\",
\"start_command\": \"\",
\"name\": \"$name\",
\"image\": \"srealmoreno/rae:latest\",
\"adapters\": 1,
\"custom_adapters\": [],
\"environment\": \"\",
\"console_type\": \"telnet\",
\"console_auto_start\": true,
\"console_resolution\": \"800x600\",
\"console_http_port\": 80,
\"console_http_path\": \"/\",
\"extra_hosts\": \"\",
\"extra_volumes\": $extra_volumes,
\"compute_id\": \"local\",
\"template_id\": \"$template_id\",
\"template_type\": \"docker\",
\"builtin\": false
}
"

}

import_templates_gns3() {
    local gns3_config="/home/$SUDO_USER/.config/GNS3/2.2/gns3_controller.conf"

    info "Importando plantillas para GNS3"
    apt install -y jq

    if [ -f "$gns3_config" ]; then
        gns3_controller=$(jq . $gns3_config)
        if [ "$?" == 0 ]; then
            exits=$(jq ".templates[] | select(.template_id==\"${info_computer[1]}\" or .name==\"${info_computer[0]}\")" <<<$gns3_controller)
            if [ "$?" == 0 ]; then
                if [ "$exits" == "" ]; then
                    advertencia "Importando plantilla de computadora"
                    computer=$(create_template "computer")
                    gns3_controller=$(jq ".templates += [$computer]" <<<$gns3_controller)
                    changes="true"
                else
                    advertencia "La plantilla de computadora ya existe"
                fi
            else
                advertencia "Ocurrio un error al leer el $gns3_config"
            fi
            exits=$(jq ".templates[] | select(.template_id==\"${info_router[1]}\" or .name==\"${info_router[0]}\")" <<<$gns3_controller)
            if [ "$?" == 0 ]; then
                if [ "$exits" == "" ]; then
                    advertencia "Importando plantilla de router"
                    router=$(create_template "router")
                    gns3_controller=$(jq ".templates += [$router]" <<<$gns3_controller)
                    changes="true"
                else
                    advertencia "La plantilla de router ya existe"
                fi
            else
                advertencia "Ocurrio un error al leer el $gns3_config"
            fi

            exits=$(jq ".templates[] | select(.template_id==\"${info_switch[1]}\" or .name ==\"${info_switch[0]}\")" <<<$gns3_controller)
            if [ "$?" == 0 ]; then
                if [ "$exits" == "" ]; then
                    advertencia "Importando plantilla de switch"
                    switch=$(create_template "switch")
                    gns3_controller=$(jq ".templates += [$switch]" <<<$gns3_controller)
                    changes="true"
                else
                    advertencia "La plantilla de switch ya existe"
                fi
            else
                advertencia "Ocurrio un error al leer el $gns3_config"
            fi

            if [ -n "$changes" ]; then
                mv "$gns3_config" "$gns3_config.backup" && jq . <<<$gns3_controller >$gns3_config
                [ "$?" == "0" ] && exito "Plantillas agregadas exitosamente" || advertencia "No se pudo agregar las plantillas, deberá hacerlo manualmente"
                chown $SUDO_USER:$SUDO_USER $gns3_config $gns3_config.backup
            fi
        else
            advertencia "Ocurrio un error al leer el $gns3_config"
        fi
    else
        advertencia "No existe el fichero $gns3_config"
    fi
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
    plantillas="true"
else
    while getopts ":h :a :d :g :p :i :v :n" arg; do #a instala todo, d instala docker, g instala gns3, i instala images de salvador, p importa las plantillas para GNS3
        case "$arg" in
        a)
            gns3="true"
            docker="true"
            virtualbox="true"
            netgui="true"
            images="true"
            config="true"
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
        p)
            plantillas="true"
            ;;
        h)
            echo -e "Uso: $0 [-a instalar todo]   [-d instalar docker]\n\t\t   [-g instalar gns3]   [-v instalar virtualbox]\n\t\t   [-n instalar netgui] [-i importar images docker]\n\t\t   [-p importar plantillas para GNS3]"
            exit 0
            ;;
        *)
            error_fatal "Argumentos no validos: $*\nUso $0 [-a instalar todo]   [-d instalar docker]\n\t\t  [-g instalar gns3]   [-v instalar virtualbox]\n\t\t  [-n instalar netgui] [-i importar images docker]\n\t\t  [-p importar plantillas para GNS3]"
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

if [ -n "$plantillas" ]; then
    import_templates_gns3
fi

if [ -n "$netgui" ]; then
    install_netgui
fi

if [ -n "$docker" ] || [ -n "$gns3" ] || [ -n "$virtualbox" ]; then
    info "Añadiendo $SUDO_USER a los grupos necesarios"
    usermod -aG $LIST_GROUP $SUDO_USER
    clean_cache
fi

exito "Instalación completada\nby: Salvador Real, Redes de area extensa 2020"
