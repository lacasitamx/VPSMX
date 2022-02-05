#!/bin/bash
#Soporte Remoto (SPR)
echo -e "\033[0;37m BIENVENIDO A SOPORTE ONLINE (APLICANDO FIX's)8.4g-5-2-22"

export LANGUAGE=en_US.UTF-8\
  && export LANG=en_US.UTF-8\
  && export LC_ALL=en_US.UTF-8\
  && export LC_CTYPE="en_US.UTF-8"\
  && locale-gen en_US.UTF-8\
  && sudo apt-get -y install language-pack-en-base\
  && sudo dpkg-reconfigure locales

echo -e "\033[0;92m Parche Online Aplicado.... OK"
