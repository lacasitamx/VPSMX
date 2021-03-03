#!/bin/bash
clear
clear
rm $(pwd)/$0 &> /dev/null
#--- 20/01/2021

#------- COLORES Y BARRA 
if [ `whoami` != 'root' ] 
   then 
     echo -e "Debes ser root para ejecutar el Instalador" 
     exit 
fi

msg () {
BRAN='\033[1;37m' && VERMELHO='\e[31m' && VERDE='\e[32m' && AMARELO='\e[33m'
AZUL='\e[34m' && MAGENTA='\e[35m' && MAG='\033[1;36m' &&NEGRITO='\e[1m' && SEMCOR='\e[0m'
 case $1 in
  -ne)cor="${VERMELHO}${NEGRITO}" && echo -ne "${cor}${2}${SEMCOR}";;
  -ama)cor="${AMARELO}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
  -verm)cor="${AMARELO}${NEGRITO}[!] ${VERMELHO}" && echo -e "${cor}${2}${SEMCOR}";;
  -azu)cor="${MAG}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
  -verd)cor="${VERDE}${NEGRITO}" && echo -e "${cor}${2}${SEMCOR}";;
  -bra)cor="${VERMELHO}" && echo -ne "${cor}${2}${SEMCOR}";;
  "-bar2"|"-bar")cor="${VERMELHO}————————————————————————————————————————————————————" && echo -e "${SEMCOR}${cor}${SEMCOR}";;
 esac
}

#------- BARRA DE ESPERA

fun_bar () {
comando="$1"
 _=$(
$comando > /dev/null 2>&1
) & > /dev/null
pid=$!
while [[ -d /proc/$pid ]]; do
echo -ne "  \033[1;33m["
   for((i=0; i<40; i++)); do
   echo -ne "\033[1;31m>"
   sleep 0.1
   done
echo -ne "\033[1;33m]"
sleep 1s
echo
tput cuu1 && tput dl1
done
echo -ne "  \033[1;33m[\033[1;31m>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>\033[1;33m] - \033[1;32m OK \033[0m\n"
sleep 1s
}

updater () {
 
 if [ ! -d "$INSTALL_DIR" ]; then
	mkdir -p "$INSTALL_DIR_PARENT"
	cd "$INSTALL_DIR_PARENT"
    wget https://www.dropbox.com/s/hd9umxsjkukaqqb/zzupdate.default-si.conf -O /usr/local/vpsmxup/vpsmxup.default.conf  &> /dev/null
else
	echo ""
fi
 
 }
####------- REINICIAR UPDATER Y RECONFIGURAR HORARIO
passs(){
msg -bar
echo -e "\e[97mDIGITE UNA NUEVA CONTRASEÑA:\033[0;37m"; read -p " " pass
(echo $pass; echo $pass)|passwd root 2>/dev/null
sleep 1s
msg -bar
echo -e "\033[97m      CONTRASEÑA AGREGADA O EDITADA CORECTAMENTE"
echo -e "\033[97m SU CONTRASEÑA AHORA ES: \e[41m $pass \033[0;37m"
}

msg -bar2
echo -e " \e[97m\033[1;41m   =====>>►► 🐲 SCRIPT - VPS•MX ®️ 🐲 ◄◄<<=====     \033[1;37m"
msg -bar2
msg -ama "               PREPARANDO INSTALACION"
msg -bar2
## Script name
SCRIPT_NAME=vpsmxup
## Install directory
WORKING_DIR_ORIGINAL="$(pwd)"
INSTALL_DIR_PARENT="/usr/local/vpsmxup/"
INSTALL_DIR=${INSTALL_DIR_PARENT}${SCRIPT_NAME}/
mkdir -p "/etc/vpsmxup/" &> /dev/null
## ------ AUTO ACTULIZADOR

if [ ! -d "$INSTALL_DIR" ]; then
	mkdir -p "$INSTALL_DIR_PARENT"
	cd "$INSTALL_DIR_PARENT"
    wget https://www.dropbox.com/s/p5bclg6gv74oyoy/zzupdate.default.conf -O /usr/local/vpsmxup/vpsmxup.default.conf  &> /dev/null
else
	echo ""
fi
##PAKETES
echo ""
echo -e "\033[97m    ◽️ INTENTANDO DETENER UPDATER SECUNDARIO " 
fun_bar " killall apt apt-get > /dev/null 2>&1 "
echo -e "\033[97m    ◽️ INTENTANDO RECONFIGURAR UPDATER "
fun_bar " dpkg --configure -a > /dev/null 2>&1 "
echo -e "\033[97m    ◽️ INSTALANDO S-P-C "
fun_bar " apt-get install software-properties-common -y > /dev/null 2>&1"
echo -e "\033[97m    ◽️ INSTALANDO LIBRERIA UNIVERSAL "
fun_bar " sudo apt-add-repository universe -y > /dev/null 2>&1"
echo -e "\033[97m    ◽️ INSTALANDO PYTHON "
fun_bar " sudo apt-get install python -y > /dev/null 2>&1"
apt-get install python -y &>/dev/null
echo -e "\033[97m    ◽️ INSTALANDO NET-TOOLS "
fun_bar "apt-get install net-tools -y > /dev/null 2>&1"
apt-get install net-tools -y &>/dev/null
apt-get install curl -y > /dev/null 2>&1
service ssh restart > /dev/null 2>&1
pasvult(){
echo -e "\033[97m    ◽️ DESACTIVANDO PASS ALFANUMERICO "
sed -i 's/.*pam_cracklib.so.*/password sufficient pam_unix.so sha512 shadow nullok try_first_pass #use_authtok/' /etc/pam.d/common-password > /dev/null 2>&1 
}
echo -e "\033[97m    ◽️ DESEA DESACTIVAR EL ALFANUMERICA DE VULTR "
read -p "solo si es de Vultr (deafult s)  [s/n]: " -e -i n pasvult
[[ "$pasvult" = "s" || "$pasvult" = "S" ]] && pasvult
echo -e "\033[97m    ◽️ REINICIANDO SERVICIO SSH RESTART"
fun_bar "service ssh restart > /dev/null 2>&1 "
msg -bar2
echo -e "${cor[2]} VERIFICAR POSIBLE ACTUALIZACION DE S.O (Default n)"
echo -e "\033[1;34m     (Este proceso puede demorar mucho Tiempo)"
msg -bar2
read -p "   [ s | n ]: " -e -i n updater   
[[ "$updater" = "s" || "$updater" = "S" ]] && updater
msg -bar2
echo -e "\033[93m              AGREGAR/EDITAR PASS ROOT\033[97m" 
msg -bar
read -p " default (n)  [ s | n ]: " -e -i n passs
[[ "$passs" = "s" || "$passs" = "S" ]] && passs

## VERIFICAR KEY AUTENTICA VS IP BOT
cd /usr/bin/
rm -rf pytransform.tar > /dev/null 2>&1
rm -rf pytransform > /dev/null 2>&1
wget https://www.dropbox.com/s/ud0ti1pxbmuxrrf/pytransform.tar >/dev/null 2>&1
tar -xf pytransform.tar > /dev/null 2>&1 
rm -rf pytransform.tar > /dev/null 2>&1
cd
wget https://raw.githubusercontent.com/lacasitamx/VPSMX/master/instalador//VPS-MX.py -O /usr/bin/VPS-MX &> /dev/null
chmod +x /usr/bin/VPS-MX
msg -bar2
read -t 20 -n 1 -rsp $'\033[1;39m           Preciona Enter Para continuar\n'
## Restore working directory 
cd $WORKING_DIR_ORIGINAL 
rm -rf VPS-MX.sh
clear
VPS-MX
exit
rm -rf VPS-MX.sh

