#!/bin/bash

# Auteur : Benjamin RABILLER
# Description : Ce script modifie l'interface réseau birdgee d'une VM et son ordre de boot avec
#				comme priorite 1 disk

network_list(){
        local INTERFACES=$(ifconfig | grep -o -e "eth[0-9]")
        for eth in $INTERFACES
        do
                echo "$eth"
        done
}

echo -n "Nom de la VM : "
read name
echo "Interface disponible sur la machine : "
network_list
echo -n "Nouvelle interface de bridge : "
read int

VBoxManage modifyvm $name --bridgeadapter1 $int 
VBoxManage modifyvm $name --boot1 disk --boot2 net --boot3 dvd --boot4 none

exit 0
