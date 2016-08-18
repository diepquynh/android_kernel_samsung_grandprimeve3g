#!/bin/bash
##
#  Copyright (C) 2015, Samsung Electronics, Co., Ltd.
#  Written by System S/W Group, S/W Platform R&D Team,
#  Mobile Communication Division.
##

set -e -o pipefail

export CROSS_COMPILE=/home/a1/toolchain/linaro-5.2/bin/arm-eabi-
export ARCH=arm

PLATFORM=sc8830
DEFCONFIG=grandprimeve3g-dt_defconfig

KERNEL_PATH=$(pwd)
MODULE_PATH=${KERNEL_PATH}/modules
EXTERNAL_MODULE_PATH=${KERNEL_PATH}/external_module

JOBS=`grep processor /proc/cpuinfo | wc -l`

function build_kernel() {
	make ${DEFCONFIG}
	make -j${JOBS}
	make modules
	make dtbs
	#make -C ${EXTERNAL_MODULE_PATH}/wifi KDIR=${KERNEL_PATH}
	make -C ${EXTERNAL_MODULE_PATH}/mali MALI_PLATFORM=${PLATFORM} BUILD=release KDIR=${KERNEL_PATH}

	[ -d ${MODULE_PATH} ] && rm -rf ${MODULE_PATH}
	mkdir -p ${MODULE_PATH}

	find ${KERNEL_PATH}/drivers -name "*.ko" -exec mv -f {} ${MODULE_PATH} \;
	find ${EXTERNAL_MODULE_PATH} -name "*.ko" -exec mv -f {} ${MODULE_PATH} \;
}

function clean() {
	[ -d ${MODULE_PATH} ] && rm -rf ${MODULE_PATH}
	make mrproper
}

function main() {
	[ "${1}" = "clean" ] && clean || build_kernel
}

main $@
