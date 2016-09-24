#!/bin/bash
##
#  Copyright (C) 2015, Samsung Electronics, Co., Ltd.
#  Written by System S/W Group, S/W Platform R&D Team,
#  Mobile Communication Division.
##

set -e -o pipefail

PLATFORM=sc8830
DEFCONFIG=grandprimeve3g-dt_defconfig
NAME=CORE_kernel
VERSION=v2.1

export CROSS_COMPILE=/home/a1/toolchain/sabermod-6.0/bin/arm-eabi-
export ARCH=arm
export LOCALVERSION=-`echo ${VERSION}`

KERNEL_PATH=$(pwd)
KERNEL_ZIP=${KERNEL_PATH}/kernel_zip
KERNEL_ZIP_NAME=${NAME}_${VERSION}
EXTERNAL_MODULE_PATH=${KERNEL_PATH}/external_module

JOBS=`grep processor /proc/cpuinfo | wc -l`

function make_zip() {
	cd ${KERNEL_PATH}/kernel_zip
	zip -r ${KERNEL_ZIP_NAME}.zip ./
	mv ${KERNEL_ZIP_NAME}.zip ${KERNEL_PATH}
}

function build_kernel() {
	make ${DEFCONFIG}
	make -j${JOBS}
	make modules
	make dtbs
	make -C ${EXTERNAL_MODULE_PATH}/mali MALI_PLATFORM=${PLATFORM} BUILD=release KDIR=${KERNEL_PATH}

if [ ! -e ${KERNEL_ZIP}/system/lib/modules ]; then
	mkdir -p ${KERNEL_ZIP}/system/lib/modules
fi;
	find ${KERNEL_PATH}/drivers -name "*.ko" -exec mv -f {} ${KERNEL_ZIP}/system/lib/modules \;
	find ${EXTERNAL_MODULE_PATH} -name "*.ko" -exec mv -f {} ${KERNEL_ZIP}/system/lib/modules \;
	find ${KERNEL_PATH} -name "zImage" -exec mv -f {} ${KERNEL_ZIP}/tools \;
	make_zip;
}

function main() {
if [ "${1}" = "clean" ]; then
	make mrproper;
	rm ${KERNEL_ZIP_NAME}.zip
else
	build_kernel
fi;
}

main $@
