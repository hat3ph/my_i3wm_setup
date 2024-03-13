#!/bin/bash

# optional components installation
my_i3wm_config=yes # set no if just want an empty i3wm setup
audio=yes # set no if do not want to use pipewire audio server
extra_pkg=yes # set no if do not want to install the extra packages
nm=yes # set no if do not want to use network-manager for network interface management
nano_config=yes # set no if do not want to configure nano text editor

install () {
	# install swaywm and other packages
	sudo apt-get update && sudo apt-get upgrade -y
	sudo apt-get install i3 suckless-tools xorg xinit xterm feh lxappearance papirus-icon-theme fonts-font-awesome \
		fonts-noto-color-emoji qt5ct xdg-utils xdg-user-dirs policykit-1 libnotify-bin dunst nano less \
		iputils-ping software-properties-gtk policykit-1-gnome dex -y

	# copy my i3 configuration
	if [[ $my_i3wm_config == "yes" ]]; then
		if [[ -d $HOME/.config/i3 ]]; then mv $HOME/.config/i3 $HOME/.config/i3_`date +%Y_%d_%m_%H_%M_%S`; fi
		#mkdir -p $HOME/{Documents,Downloads,Music,Pictures,Videos}
		mkdir -p $HOME/.config/i3
		cp -r ./config/i3/* $HOME/.config/i3/
		chmod +x $HOME/.config/i3/scripts/*.sh
	fi

	# configure nano with line number
	if [[ $nano_config == "yes" ]]; then
		if [[ -f $HOME/.nanorc ]]; then mv $HOME/.nanorc $HOME/.nanorc_`date +%Y_%d_%m_%H_%M_%S`; fi
		cp /etc/nanorc $HOME/.nanorc
		sed -i 's/# set const/set const/g' $HOME/.nanorc
	fi

	# use pipewire with wireplumber or pulseaudio-utils
	if [[ $audio == "yes" ]]; then
		# install pulseaudio-utils to audio management for Ubuntu 22.04 due to out-dated wireplumber packages
		if [[ ! $(cat /etc/os-release | awk 'NR==3' | cut -c12- | sed s/\"//g) == "22.04" ]]; then
			sudo apt-get install pipewire pipewire-pulse wireplumber -y
			rm $HOME/.config/i3/config.d/keybindings_pactl
		else
			sudo apt-get install pipewire pipewire-media-session pulseaudio pulseaudio-utils -y
			rm $HOME/.config/i3/config.d/keybindings_wpctl
		fi
	fi

	# optional to insstall the extra packages
	if [[ $extra_pkg == "yes" ]]; then
		sudo apt-get install thunar gvfs gvfs-backends thunar-archive-plugin thunar-media-tags-plugin avahi-daemon \
			lximage-qt geany qpdfview -y
	fi

	# optional install NetworkManager
	if [[ $nm == yes ]]; then
	sudo apt-get install network-manager -y
		if [[ -n "$(uname -a | grep Ubuntu)" ]]; then
			for file in `find /etc/netplan/* -maxdepth 0 -type f -name *.yaml`; do
				sudo mv $file $file.bak
			done
			echo -e "# Let NetworkManager manage all devices on this system\nnetwork:\n  version: 2\n  renderer: NetworkManager" | \
				sudo tee /etc/netplan/01-network-manager-all.yaml
		else
			sudo cp /etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/NetworkManager.conf.bak
			sudo sed -i 's/managed=false/managed=true/g' /etc/NetworkManager/NetworkManager.conf
			sudo mv /etc/network/interfaces /etc/network/interfaces.bak
			sudo cp ./config/interfaces /etc/network/interfaces
			sudo systemctl disable networking.service
		fi
	fi

}

printf "\n"
printf "Start installation!!!!!!!!!!!\n"
printf "88888888888888888888888888888\n"
printf "My Custom i3WM Config   : $my_i3wm_config\n"
printf "Pipewire Audio          : $audio\n"
printf "Extra Packages          : $extra_pkg\n"
printf "NetworkManager          : $nm\n"
printf "Nano's configuration    : $nano_config\n"
printf "88888888888888888888888888888\n"

while true; do
read -p "Do you want to proceed with above settings? (y/n) " yn
	case $yn in
		[yY] ) echo ok, we will proceed; install; echo "Remember to reboot system after the installation!";
			break;;
		[nN] ) echo exiting...;
			exit;;
		* ) echo invalid response;;
	esac
done
