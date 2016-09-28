#!/bin/bash
##
#  Copyright (C) 2015, Samsung Electronics, Co., Ltd.
#  Written by System S/W Group, S/W Platform R&D Team,
#  Mobile Communication Division.
#
#  Edited by Nguyen Tuan Quyen (koquantam)
##

set -e -o pipefail

PLATFORM=sc8830
DEFCONFIG=grandprimeve3g-dt_defconfig
NAME=CORE_kernel
VERSION=v2.3

export CROSS_COMPILE=/home/a1/toolchain/sabermod-6.0/bin/arm-eabi-
export ARCH=arm
export LOCALVERSION=-`echo ${VERSION}`

KERNEL_PATH=$(pwd)
KERNEL_ZIP=${KERNEL_PATH}/kernel_zip
KERNEL_ZIP_NAME=${NAME}_${VERSION}
EXTERNAL_MODULE_PATH=${KERNEL_PATH}/external_module

JOBS=`grep processor /proc/cpuinfo | wc -l`

# Colors
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

function make_zip() {
	cd ${KERNEL_PATH}/kernel_zip
	zip -r ${KERNEL_ZIP_NAME}.zip ./
	mv ${KERNEL_ZIP_NAME}.zip ${KERNEL_PATH}
}

function build_kernel() {
	echo -e "$cyan***********************************************"
	echo "          Compiling CORE(TM) kernel          	     "
	echo -e "***********************************************$nocol"

	echo -e "$red Initializing defconfig...$nocol"
	make ${DEFCONFIG}
	echo -e "$red Building kernel...$nocol"
	make -j${JOBS}
	make modules
	make dtbs
	find ${KERNEL_PATH}/drivers -name "*.ko" -exec mv -f {} ${KERNEL_ZIP}/system/lib/modules \;
	find ${KERNEL_PATH} -name "zImage" -exec mv -f {} ${KERNEL_ZIP}/tools \;

	echo -e "$red Making flashable zip...$nocol";
	make_zip;
}

function main() {
if [ "${1}" = "clean" ]; then
	echo -e "$red Cleaning build environment...$nocol"
	make mrproper;
	rm ${KERNEL_ZIP_NAME}.zip
	echo -e "$yellow Done!$nocol"
else
	BUILD_START=$(date +"%s")
	build_kernel

	BUILD_END=$(date +"%s")
	DIFF=$(($BUILD_END - $BUILD_START))
	echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
fi;
}

main $@
