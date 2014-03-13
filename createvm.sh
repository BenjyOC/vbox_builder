#!/bin/bash
# Auteur : Benjamin RABILLER
# Version 1.0
# Descritpion : Permet de creer une machine virtuelle VirtualBox pour l'OS Debian 64 bits 
# Dependance : Necessite l'installation de Virtualbox

DATE=$(date +%k%M%S)
PATHVB="/space/virtualbox/"
GUEST_ISO="/space/VBoxGuestAdditions_4.3.8.iso"
# Configuration par defaut d'une VM 
NAME="oxavag$DATE"
RAM="2048"
DISK="20000"
NET="eth1"

vm_builder(){
	VBoxManage createvm --name $1 --ostype Debian_64 --register
	VBoxManage modifyvm $1 --memory $2
	VBoxManage modifyvm $1 --bridgeadapter1 $4 --nic1 bridged
	VBoxManage createhd --filename $PATHVB$1/$1.vdi --size $3 --format VDI
	VBoxManage storagectl $1 --name "SATA Controller" --add sata --controller IntelAhci
	VBoxManage storageattach "$1" --storagectl "SATA Controller" --port 0 --type hdd --medium $PATHVB$1/$1.vdi
	VBoxManage modifyvm $1 --vrde on
	VBoxManage modifyvm "$1" --natpf1 "SSH,tcp,,2222,,22"
    VBoxManage storagectl "$1" --name "IDE Controller" --add ide
    VBoxManage storageattach "$1" --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium $GUEST_ISO
	VBoxManage modifyvm $1 --boot1 net --boot2 disk --boot3 dvd --boot4 none
}

man_conf(){
	echo -n "Nom de la VM : "
	read name
	echo -n "Taille de la RAM (en MB) : "
	read ram
	echo -n "Taille du disque (en MB) : "
	read disk
	echo "Liste des interfaces disponible : "
	network_list
	echo -n "Interface de Bridge (eth*) : "
	read int

}

network_list(){
	local INTERFACES=$(ifconfig | grep -o -e "eth[0-9]")
	for eth in $INTERFACES 
	do
		echo "$eth"
	done
}

echo -n "Souhaitez-vous réaliser une configuration automatique ? (y/n) : "
read choix

if [ "$choix" == "y" ];then
	vm_builder $NAME $RAM $DISK $NET
elif [ "$choix" ==  "n" ];then
	man_conf
	vm_builder $name $ram $disk $int
else
	echo "Choix invalide"
fi

exit 0
