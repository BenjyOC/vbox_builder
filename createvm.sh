#!/bin/bash

# Auteur : Benjamin RABILLER
# Version 1.0
# Descritpion : Permet de creer une machine virtuelle VirtualBox pour l'OS Debian 64 bits 
# Dependance : Necessite l'installation de Virtualbox

DATE=$(date +%k%M%S)
PATHVB="/space/virtualbox/"
GUEST_ISO="/space/VBoxGuestAdditions_4.3.8.iso"

INTERFACES=$(ifconfig | grep -o -e "eth[0-9]")

# Configuration par defaut d'une VM 
NAME="oxavag$DATE"
RAM="2048"
DISK="25000"

get_ip(){
	ip=$(ip addr | grep inet | grep $1 | grep -o -E "*10.1.1.[0-9]{1,3}" | head -1)
	echo $ip
}

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
	VBoxManage modifyvm $1 --boot1 disk --boot2 net --boot3 dvd --boot4 none
}

vm_launch(){
	VBoxHeadless -startvm $NAME
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
	for eth in $INTERFACES 
	do
		echo $eth
	done
}

search_network(){
	for eth in $INTERFACES 
	do
		ip_tmp=$(get_ip $eth)
		ip_target=$(echo $ip_tmp | grep -o -e "10.1.1")
		if [ -n "$ip_target" ]; then
			NET=$eth			
		fi
	done
}

check_network(){
	if [ -z "$NET"  ]; then
		echo "AUCUNE INTERFACE SUR LE VLAN PXE BOOT (10.1.1.0/24)" >&2
		exit 1
	fi
}

echo -n "Souhaitez-vous réaliser une configuration automatique ? (y/n) : "
read choix

if [ "$choix" == "y" ];then
	search_network
	check_network
	vm_builder $NAME $RAM $DISK $NET
	vm_launch
elif [ "$choix" ==  "n" ];then
	man_conf
	vm_builder $name $ram $disk $int
	vm_launch
else
	echo "Choix invalide"
fi

exit 0
