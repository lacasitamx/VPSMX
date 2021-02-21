#!/bin/bash

#--UPDATE 22-01-2021
clear
echo -ne '\e[97mCARGANDO:\033[1;37m\e[93m #######                        (25%)\r'
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
apt install python -y > /dev/null 2>&1
echo -ne '\e[97mCARGANDO:\033[1;37m\e[93m ###############                (50%)\r'
cd /usr/bin/
wget https://www.dropbox.com/s/8fhez5kna5vetpd/pytransform.tar >/dev/null 2>&1
tar -xf pytransform.tar > /dev/null 2>&1 
rm -rf pytransform.tar > /dev/null 2>&1
cd
echo -ne '\e[97mCARGANDO:\033[1;37m\e[93m ######################         (75%)\r'
wget https://raw.githubusercontent.com/lacasitamx/VPSMX/master/instalador//VPS-MX.py -O /usr/bin/VPS-MX &> /dev/null
chmod +x /usr/bin/VPS-MX
echo -ne '\e[97mCARGANDO:\033[1;37m\e[93m ############################## (100%)\r'
echo -ne '\n'
sleep 2s
VPS-MX
rm -rf /root/VPS-MX
exit

#HOLAS CREA TU PROPIO SCRIPT PAPU