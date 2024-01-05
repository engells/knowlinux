#!/bin/sh
# vim:ts=4
# install.sh : dkms Case Study  for Nvidia-Installer

#Usage
if [ $# -ne 1 -a $# -ne 2 ]; then
	echo "Usage:"
	echo $0 DRIVERVERSION [INSTALLERNAME]
	exit 1
fi


# 1st argument (Version of NV)
readonly driver_version=$1
if [ ${#driver_version} -lt 1 ]; then
	echo DRIVERVERSION must be a nonempty string
	exit 1
fi

# 2nd argument (filename of NV-Installer)
if [ $# -ge 2 ]; then
	readonly installer_name=$2
else
	# generate the Filename 
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

# Relative path to the kernel_source from the unpacked NV-Installer
readonly installer_src_dir=usr/src/nv

# The place to save the sources for this driver-version
# Note: Format required by DKMS: /usr/src/-
readonly dest_src_dir=/usr/src/nvidia-$driver_version

# required Packages for building the kernel-module
readonly package_depency="dkms build-essential make"

# =============================SANITY TEST (Start)=============================================
sanity=1

if [ ! -e $installer_name ]; then
	echo "Error: Could not find the NVIDIA-Driver Installer:"
	echo $installer_name
	echo
	sanity=0
fi

echo "* Checking for kernel-sources for the running kernel"

if [ -e /usr/src/linux-headers-$(uname -r) ]; then
	echo "Kernel-sources were installed"
else
	echo "ERROR: Kernel-sources were not installed"
	sanity=0
fi

echo "Important Note: You should install the correct Packages"
echo "for ALL kernels you are using :)"
echo

if [ -e $dest_src_dir ]; then
	echo "Warning: Found previous source directory: $dest_src_dir" 
	echo "Contents would be overwritten !!!"
	echo
fi

if [ $sanity -ne 1 ]; then
	echo "Exiting in case of Errors"
	exit 1
fi
# =====================================SANITY TEST (END) ====================================


# exit on all Errors
set -e

# privilege : root user
if [ "root" != "$USER" ]; then
	echo "Are you root? Must be root to continue ..."
	exit 1
fi

echo "* Installing necessary packages"
apt-get >/dev/null install $package_depency

echo
echo "Nvidia Driver Version $driver_version"
echo "Nvidia Installer Binary $installer_name"
echo "DKMS Module Directory $dest_src_dir"
echo
echo "Running Kernel $(uname -r)"
echo "Expect Kernel-Sources in /usr/src/linux-headers-$(uname -r)"
echo 
echo "DKMS Version $(dkms -V)"


# ******************* Preparing kmodule-srcs (Start) *************************************************
readonly tempdir=$(mktemp -d) || exit 1

echo "* Unpacking installer"
sh $installer_name >/dev/null --extract-only --target $tempdir/installer 

# delete previously existing source directory for the same driver version
if [ -e $dest_src_dir ]; then
	rm -rf $dest_src_dir
fi

echo "* Moving kmodule-source to $dest_src_dir"
mkdir $dest_src_dir
cp -r $tempdir/installer/$installer_src_dir/* $dest_src_dir

# create the dkms.conf File, which tells DKMS how to compile the kmodule
echo "* Creating dkms-configuration $dest_src_dir/dkms.conf"
echo > $dest_src_dir/dkms.conf 'PACKAGE_NAME="nvidia"
	PACKAGE_VERSION="'$driver_version'"
	CLEAN="make clean"
	BUILT_MODULE_NAME[0]="nvidia"
	MAKE[0]="make module KERNDIR=/lib/modules/$kernelver IGNORE_XEN_PRESENCE=1 IGNORE_CC_MISMATCH=1 SYSSRC=$kernel_source_dir"
	DEST_MODULE_LOCATION[0]="/kernel/drivers/video/nvidia"
	AUTOINSTALL="yes"'

echo "* Delete temporary directory"
rm -rf $tempdir
# ************************** Preparing kmodule-src (End) ***************************************



# ignore errors
set +e

# =========================== Adding DKMS Module (Start)=========================================
echo "* Removing eventual existing DKMS-Modules for the same driver_version"
dkms remove -m nvidia -v $driver_version --all -q
echo "*** Done. ***"

echo "* Adding Module to DKMS build system"
echo "** Module Name: nvidia $driver_version"
dkms add -m nvidia -v $driver_version

echo "* Doing initial module build"
dkms build -m nvidia -v $driver_version

echo "* Installing initial module"
dkms install -m nvidia -v $driver_version
# ========================Adding DKMS Module (End) =============================================



echo "****** Done. Current Status of DKMS is:"
dkms status
#EOF
