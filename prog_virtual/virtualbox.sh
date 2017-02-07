#! /bin/bash
# vim:ts=2
# program: 用於將Ubuntu安裝在Virtual Box上，以及掛載或卸載Virtual Box分享資料夾
# made by: Engells
# date: Dec 19, 2011
# content: 
	
if [ -z $1 ]; then

	echo '請輸入處理方式 m:掛載分享資料夾 u:卸載分享資料夾 l:安裝輕量Linux s:安裝標準Linux t:安裝VB公用程式'

elif [ X$1 = X"m" ]; then

  #sudo modprobe vboxsf
	if [ ! -d ~/mnt/share ]; then mkdir -p ~/mnt/share ; fi
	sudo mount -t vboxsf Shared ~/share
	sudo chown -R engells:engells ~/mnt/share

elif [ X$1 = X"u" ]; then

	sudo umount -t vboxsf Shared 
	rmdir ~/mnt/share

elif [ X$1 = X"l" ]; then

	#安裝 command-line system (Ubuntu 10.04)

	case $2 in

	a)
		sudo apt-get update && apt-get -y dist-upgrade && reboot ;;

	b)
		sudo apt-get install python-software-properties
		sudo add-apt-repository ppa:lubuntu-desktop/ppa
		sudo apt-get install -y $( cat pkgs.list | grep '^light1' | awk '{ print $2 }' )
			#從清單中安裝套件
		sudo apt-get -y autoremove && sudo apt-get -y autoclean && sudo apt-get -y clean
			#清理系統
		if [ ! -d ~/profile ];	then mkdir -p ~/profile; fi && sudo chown -R engells:engells ~/profile
			#設定 ~/profile 目錄之用戶及群組身份
		mkdir -p ~/.config/openbox
		cp ~/profile/ob.menu.xml ~/.config/openbox/menu.xml
		cp ~/profile/ob.autostart.sh ~/.config/openbox/autostart.sh
			#設定openbox及ibus組態
		cp ~/profile/z.bashrc ~/.bashrc;
		cp ~/profile/z.bash_profile~/.bash_profile
			#bash組態
		mkdir {~/.icons,~/.themes}
		#cd ~/profile/mac/mac4lin && sudo ./Mac4Lin_Install_v1.0.sh
			#安裝Mac4Lin
		#cp ~/profile/z.gtkrc-2.0 ~/ob.gtkrc-2.0
			#gtk佈景
		#cd ~/profile && sudo ./vboxadd.run
			#VBox Module
		;;

	*)
		echo 'Just memo' > /dev/null
		;;

	esac

elif [ X$1 = X"s" ]; then

	#安裝標準之Ubuntu 10.04
	sudo apt-get purge gnome-bluetooth gnome-media gnome-disk-utility gnome-games-common gbrainy gcalctool
	sudo apt-get purge rhythmbox f-spot tomboy openoffice* ibus-m17n ibus-table
	sudo mv /etc/apt/sources.list /etc/apt/sources.bak
	sudo cp ~/ws/sources.list /etc/apt
	sudo apt-get update
	sudo apt-get install language-pack-zh-hant ibus-chewing
	sudo apt-get upgrade

elif [ X$1 = X"t" ]; then

	# Remember to mount the VBox iso file
	cd /media/VBOXADDITIONS_3.2.6_63112
	sudo ./VBoxLinuxAdditions-amd64.run

else

	echo '錯誤 未定義之處理方式'

fi

