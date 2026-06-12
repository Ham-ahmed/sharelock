#!/bin/sh

#remove unnecessary files and folders
if [  -d "/CONTROL" ]; then
rm -r  /CONTROL >/dev/null 2>&1
fi
rm -rf /control >/dev/null 2>&1
rm -rf /postinst >/dev/null 2>&1
rm -rf /preinst >/dev/null 2>&1
rm -rf /prerm >/dev/null 2>&1
rm -rf /postrm >/dev/null 2>&1
rm -rf /tmp/*.ipk >/dev/null 2>&1
rm -rf /tmp/*.tar.gz >/dev/null 2>&1

#config
plugin=Sherlockmod
version=1.4.4
url=https://raw.githubusercontent.com/Ham-ahmed/sharelock/refs/heads/main/Sherlockmod.tar.gz
package=/var/volatile/tmp/$plugin-$version.tar.gz

#download & install
echo "> Downloading $plugin-$version package  please wait ..."
sleep 3s

wget --show-progress -qO $package --no-check-certificate $url
tar -xzf $package -C /
extract=$?
rm -rf $package >/dev/null 2>&1

echo ''
if [ $extract -eq 0 ]; then
echo "#########################################################"
echo "#                INSTALLED SUCCESSFULLY                 #"
echo "#              ON - NagicPanelGold v10.12               #"
echo "#             Enigma2 restart is required               #"
echo "#        .::UPLOADED BY  >>>>   HAMDY_AHMED::.          #"
echo "#     https://www.facebook.com/share/g/18qCRuHz26/      #"
echo "#########################################################"
echo "#           your Device will RESTART Now                #"
echo "#########################################################"
sleep 3s

# Receiver restart
echo "> Restarting receiver in 3 seconds..."
sleep 3s

killall -9 enigma2 >/dev/null 2>&1
sleep 2s
enigma2 >/dev/null 2>&1 &

else

echo "> $plugin-$version package installation failed"
sleep 3s
fi