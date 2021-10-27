#!/bin/bash
#======================================================
#   System Required: CentOS 7+ / Debian 8+ / Ubuntu 16+
#   Description: Manage v2-ui
#   Author: sprov
#   Blog: https://blog.sprov.xyz
#   Github - v2-ui: https://github.com/sprov065/v2-ui
#======================================================

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}Error: ${plain}¡Debe utilizar el usuario root para ejecutar este script!\n" && exit 1

# check os
if [[ -f /etc/redhat-release ]]; then
    release="centos"
elif cat /etc/issue | grep -Eqi "debian"; then
    release="debian"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
elif cat /proc/version | grep -Eqi "debian"; then
    release="debian"
elif cat /proc/version | grep -Eqi "ubuntu"; then
    release="ubuntu"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
    release="centos"
else
    echo -e "${red} No se detecta la versión del sistema, póngase en contacto con el autor del script.${plain}\n" && exit 1
fi

os_version=""

# os version
if [[ -f /etc/os-release ]]; then
    os_version=$(awk -F'[= ."]' '/VERSION_ID/{print $3}' /etc/os-release)
fi
if [[ -z "$os_version" && -f /etc/lsb-release ]]; then
    os_version=$(awk -F'[= ."]+' '/DISTRIB_RELEASE/{print $2}' /etc/lsb-release)
fi

if [[ x"${release}" == x"centos" ]]; then
    if [[ ${os_version} -le 6 ]]; then
        echo -e "${red}Por Favor Use - CentOS 7 o sistema superior!${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"ubuntu" ]]; then
    if [[ ${os_version} -lt 16 ]]; then
        echo -e "${red}¡Utilice Ubuntu 16 o una versión superior del sistema!${plain}\n" && exit 1
    fi
elif [[ x"${release}" == x"debian" ]]; then
    if [[ ${os_version} -lt 8 ]]; then
        echo -e "${red}¡Utilice Debian 8 o un sistema de versión superior!${plain}\n" && exit 1
    fi
fi

confirm() {
    if [[ $# > 1 ]]; then
        echo && read -p "$1 [Defauld$2]: " temp
        if [[ x"${temp}" == x"" ]]; then
            temp=$2
        fi
    else
        read -p "$1 [y/n]: " temp
    fi
    if [[ x"${temp}" == x"y" || x"${temp}" == x"Y" ]]; then
        return 0
    else
        return 1
    fi
}

confirm_restart() {
    confirm "Ya sea para reiniciar el panel, reiniciar el panel también reiniciará xray" "y"
    if [[ $? == 0 ]]; then
        restart
    else
        show_menu
    fi
}

before_show_menu() {
    echo && echo -n -e "${yellow}Presione enter para regresar al menú principal: ${plain}" && read temp
    show_menu
}

install() {
    wget https://raw.githubusercontent.com/lacasitamx/VPSMX/master/SCRIPT-8.4/EXTRA/v2uimenu.sh; chmod 777 v2uimenu.sh; ./v2uimenu.sh
    if [[ $? == 0 ]]; then
        if [[ $# == 0 ]]; then
            start
            rm v2uimenu.sh &>/dev/null
        else
            start 0
        fi
    fi
}

update() {
    confirm "Esta función reinstalará a la fuerza la última versión actual y los datos no se perderán. ¿Desea continuar?" "n"
    if [[ $? != 0 ]]; then
        echo -e "${red}Cancelado${plain}"
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 0
    fi
    bash <(curl -Ls https://blog.sprov.xyz/v2-ui.sh)
    if [[ $? == 0 ]]; then
        echo -e "${green}La actualización está completa y el panel se ha reiniciado automáticamente${plain}"
        exit
#        if [[ $# == 0 ]]; then
#            restart
#        else
#            restart 0
#        fi
    fi
}

uninstall() {
    confirm "¿Está seguro de que desea desinstalar el panel, xray también lo desinstalará? "
     "n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi
    systemctl stop v2-ui
    systemctl disable v2-ui
    rm /etc/systemd/system/v2-ui.service -f
    systemctl daemon-reload
    systemctl reset-failed
    rm /etc/v2-ui/ -rf
    rm /usr/local/v2-ui/ -rf

    echo ""
    echo -e "La desinstalación se realizó correctamente. Si desea eliminar esta secuencia de comandos, salga de la secuencia de comandos y ejecute${green}rm /usr/bin/v2-ui -f${plain}Borrar"
    echo ""
    echo -e "Telegram Grupo: ${green}https://t.me/lacasitamx${plain}"
    echo -e "Github issues: ${green}https://github.com/lacasitamx/v2-ui/issues${plain}"
    echo -e "Blog Oficial: ${green}https://blog.sprov.xyz/v2-ui${plain}"

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

reset_user() {
    confirm "¿Está seguro de que desea restablecer el nombre de usuario y la contraseña a admin " "n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi
    /usr/local/v2-ui/v2-ui resetuser
    echo -e "El nombre de usuario y la contraseña se han restablecido a ${green}admin${plain}, Reinicia el panel ahora"
    confirm_restart
}

reset_config() {
    confirm "¿Está seguro de que desea restablecer todas las configuraciones del panel? No se perderán los datos de la cuenta, ni se cambiará el nombre de usuario ni la contraseña""n"
    if [[ $? != 0 ]]; then
        if [[ $# == 0 ]]; then
            show_menu
        fi
        return 0
    fi
    /usr/local/v2-ui/v2-ui resetconfig
    echo -e "Todos los paneles se han restablecido a los valores predeterminados, ahora reinicie los paneles y utilice los valores predeterminados. ${green}65432${plain}Panel de acceso al puerto"
    confirm_restart
}

set_port() {
    echo && echo -n -e "Ingrese el número de puerto [1-65535]: " && read port
    if [[ -z "${port}" ]]; then
        echo -e "${yellow}Cancelado${plain}"
        before_show_menu
    else
        /usr/local/v2-ui/v2-ui setport ${port}
        echo -e "Después de configurar el puerto, reinicie el panel y use el puerto recién configurado${green} ${port} ${plain}Panel de acceso"
        confirm_restart
    fi
}

start() {
    check_status
    if [[ $? == 0 ]]; then
        echo ""
        echo -e "${green}El panel ya se está ejecutando, no es necesario comenzar de nuevo, si necesita reiniciar, seleccione reiniciar${plain}"
    else
        systemctl start v2-ui
        sleep 2
        check_status
        if [[ $? == 0 ]]; then
            echo -e "${green}v2-ui Comenzó exitosamente${plain}"
        else
            echo -e "${red}El panel no pudo iniciarse. Puede deberse a que tardó más de dos segundos en iniciarse. Verifique la información de registro más tarde.${plain}"
        fi
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

stop() {
    check_status
    if [[ $? == 1 ]]; then
        echo ""
        echo -e "${green}El panel se ha detenido, no es necesario volver a parar${plain}"
    else
        systemctl stop v2-ui
        sleep 2
        check_status
        if [[ $? == 1 ]]; then
            echo -e "${green}v2-ui y xray se detuvieron correctamente${plain}"
        else
            echo -e "${red}El panel no se detuvo. Puede deberse a que el tiempo de parada supera los dos segundos. Verifique la información de registro más tarde.${plain}"
        fi
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

restart() {
    systemctl restart v2-ui
    sleep 2
    check_status
    if [[ $? == 0 ]]; then
        echo -e "${green}v2-ui y xray se reinician con éxito${plain}"
    else
        echo -e "${red}El reinicio del panel falló, puede deberse a que el tiempo de inicio supera los dos segundos, verifique la información de registro más tarde${plain}"
    fi
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

status() {
    systemctl status v2-ui -l
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

enable() {
    systemctl enable v2-ui
    if [[ $? == 0 ]]; then
        echo -e "${green}v2-ui Configure el inicio automático de encendido correctamente${plain}"
    else
        echo -e "${red}v2-ui No se pudo configurar el inicio automático después del inicio${plain}"
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

disable() {
    systemctl disable v2-ui
    if [[ $? == 0 ]]; then
        echo -e "${green}v2-ui Cancelar el inicio automático de encendido con éxito${plain}"
    else
        echo -e "${red}v2-ui Cancelar falla de inicio${plain}"
    fi

    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

show_log() {
    echo && echo -n -e "Es posible que se generen muchos registros de ADVERTENCIA durante el uso del panel. Si no hay ningún problema con el uso del panel, no hay problema. Presione Enter para continuar: " && read temp
    tail -500f /etc/v2-ui/v2-ui.log
    if [[ $# == 0 ]]; then
        before_show_menu
    fi
}

install_bbr() {
    bash <(curl -L -s https://raw.githubusercontent.com/sprov065/blog/master/bbr.sh)
    if [[ $? == 0 ]]; then
        echo ""
        echo -e "${green}Bbr instalado con éxito${plain}"
    else
        echo ""
        echo -e "${red}No se pudo descargar el script de instalación de bbr, verifique si la máquina se puede conectar a Github${plain}"
    fi

    before_show_menu
}

update_shell() {
    wget -O /usr/bin/v2-ui -N --no-check-certificate https://github.com/sprov065/v2-ui/raw/master/v2-ui.sh
    if [[ $? != 0 ]]; then
        echo ""
        echo -e "${red}No se pudo descargar el script, verifique si la máquina se puede conectar a Github${plain}"
        before_show_menu
    else
        chmod +x /usr/bin/v2-ui
        echo -e "${green}La secuencia de comandos de actualización se ha realizado correctamente. Vuelva a ejecutar la secuencia de comandos.${plain}" && exit 0
    fi
}

# 0: running, 1: not running, 2: not installed
check_status() {
    if [[ ! -f /etc/systemd/system/v2-ui.service ]]; then
        return 2
    fi
    temp=$(systemctl status v2-ui | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
    if [[ x"${temp}" == x"running" ]]; then
        return 0
    else
        return 1
    fi
}

check_enabled() {
    temp=$(systemctl is-enabled v2-ui)
    if [[ x"${temp}" == x"enabled" ]]; then
        return 0
    else
        return 1;
    fi
}

check_uninstall() {
    check_status
    if [[ $? != 2 ]]; then
        echo ""
        echo -e "${red}El panel se ha instalado, no repita la instalación${plain}"
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 1
    else
        return 0
    fi
}

check_install() {
    check_status
    if [[ $? == 2 ]]; then
        echo ""
        echo -e "${red}Primero instale el panel${plain}"
        if [[ $# == 0 ]]; then
            before_show_menu
        fi
        return 1
    else
        return 0
    fi
}

show_status() {
    check_status
    case $? in
        0)
            echo -e "Estado del panel: ${green}Ejecutando${plain}"
            show_enable_status
            ;;
        1)
            echo -e "Estado del panel: ${yellow}DETENiDo${plain}"
            show_enable_status
            ;;
        2)
            echo -e "Estado del panel: ${red}No instalado${plain}"
    esac
    show_xray_status
}

show_enable_status() {
    check_enabled
    if [[ $? == 0 ]]; then
        echo -e "AutoEjecucion: ${green}Encendida${plain}"
    else
        echo -e "AutoEjecucion: ${red}Apagada${plain}"
    fi
}

check_xray_status() {
    count=$(ps -ef | grep "xray-v2-ui" | grep -v "grep" | wc -l)
    if [[ count -ne 0 ]]; then
        return 0
    else
        return 1
    fi
}

show_xray_status() {
    check_xray_status
    if [[ $? == 0 ]]; then
        echo -e "Estado de XRAY - V2-UI : ${green}Iniciado y Ejecutandose ${plain}"
    else
        echo -e "Estado de XRAY - V2-UI : ${red}No Ejecutandose${plain}"
    fi
}

show_usage() {
    echo "v2-ui Cómo usar scripts de administración (web): "
    echo "------------------------------------------"
    echo "v2-ui              - Menú de gestión de pantalla (más funciones)"
    echo "v2-ui start        - Inicie el panel v2-ui"
    echo "v2-ui stop         - Detener el panel v2-ui"
    echo "v2-ui restart      - Reinicie el panel v2-ui"
    echo "v2-ui status       - Ver el estado de v2-ui"
    echo "v2-ui enable       - AutoEjecutar al Arranque"
    echo "v2-ui disable      - Desactivar AutoEjecutar al Arranque "
    echo "v2-ui log          - Ver registro v2-ui"
   # echo "v2-ui update       - Actualizar el panel v2-ui"
    echo "v2-ui install      - Instalar el panel v2-ui"
    echo "v2-ui uninstall    - Desinstalar el panel v2-ui"
    echo "------------------------------------------"
}

show_menu() {
    echo -e "
  ${green}v2-ui Script de gestión del panel ( web )${plain}
--- https://blog.sprov.xyz/v2-ui ---
  ${green}0.${plain} Salir 
————————————————
  ${green}1.${plain}Instalar v2-ui
  #${green}2.${plain}Actualizar v2-ui
  ${green}2.${plain}Desinstalar v2-ui
————————————————
  ${green}3.${plain}Restablecer nombre de usuario y contraseña
  ${green}4.${plain}Restablecer la configuración del panel
  ${green}5.${plain}Establecer el puerto del panel
————————————————
  ${green}6.${plain}Iniciar v2-ui
  ${green}7.${plain}Detener v2-ui
  ${green}8.${plain}Reiniciar v2-ui
 ${green}9.${plain}Ver el estado de v2-ui
 ${green}10.${plain}Ver registro v2-ui
————————————————
 ${green}11.${plain} Encender AutoEjecucion
 ${green}12.${plain} Cancelar AutoEjecucion
————————————————
 ${green}13.${plain} Instalación de bbr (el último kernel)
 "
    show_status
    echo && read -p "SELECIONE UN NUMERO [0-14]: " num

    case "${num}" in
        0) exit 0
        ;;
        1) check_uninstall && install
        ;;
    #    2) check_install && update
 #       ;;
        2) check_install && uninstall
        ;;
        3) check_install && reset_user
        ;;
        4) check_install && reset_config
        ;;
        5) check_install && set_port
        ;;
        6) check_install && start
        ;;
        7) check_install && stop
        ;;
        8) check_install && restart
        ;;
        9) check_install && status
        ;;
        10) check_install && show_log
        ;;
        11) check_install && enable
        ;;
        12) check_install && disable
        ;;
        13) install_bbr
        ;;
        *) echo -e "${red}SOLO ESCOJE Entre [0-13]${plain}"
        ;;
    esac
}


if [[ $# > 0 ]]; then
    case $1 in
        "start") check_install 0 && start 0
        ;;
        "stop") check_install 0 && stop 0
        ;;
        "restart") check_install 0 && restart 0
        ;;
        "status") check_install 0 && status 0
        ;;
        "enable") check_install 0 && enable 0
        ;;
        "disable") check_install 0 && disable 0
        ;;
        "log") check_install 0 && show_log 0
        ;;
      #  "update") check_install 0 && update 0
   #     ;;
        "install") check_uninstall 0 && install 0
        ;;
        "uninstall") check_install 0 && uninstall 0
        ;;
        *) show_usage
    esac
else
    show_menu
fi
