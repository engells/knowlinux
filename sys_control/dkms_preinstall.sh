#!/bin/bash
# vim:ts=4
# preinstall.sh

#Usage
if [ $# -ne 1 -a $# -ne 2 ]; then
	echo "Usage:"
	echo $0 DRIVERVERSION [INSTALLERNAME]
	exit 1
fi

# 1st arg. (Version)
readonly driver_version=$1
if [ ${#driver_version} -lt 1 ]; then
	echo Error: DRIVERVERSION must be a nonempty string
	exit 1
fi

# 2nd arg. (filename of NVIDIA-Installer)
if [ $# -ge 2 ]; then
	readonly installer_name=$2
else
	# generate the Filename (if 2nd arg. is NULL)
	if [ "$(uname -m)" = "x86_64" ]; then
		readonly archname=x86_64
	else
		readonly archname=x86
	fi

	for var1 in ./NVIDIA-Linux-$archname-$driver_version-pkg?.run
	do readonly installer_name=$var1
		break
	done

	unset archname var1
fi

# Privilege : for root 
if [ "root" != "$USER" ]; then
	echo "Are you root ? Must be root to continue ..."
	exit 1
fi

sh $installer_name -N --no-kernel-module --no-runlevel-check --accept-license -s

if [ ! -e /etc/X11/xorg.conf ]; then
	echo > /etc/X11/xorg.conf 'Section "Device"
		Identifier "Device0"
		Driver "nvidia"
		VendorName "NVIDIA Corporation"
		EndSection'
fi

sh ./install.sh $driver_version $installer_name

#EOF
