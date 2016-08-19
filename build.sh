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
KERNEL_OUT=${KERNEL_PATH}/kernel_out
EXTERNAL_MODULE_PATH=${KERNEL_PATH}/external_module

JOBS=`grep processor /proc/cpuinfo | wc -l`

function build_kernel() {
	make ${DEFCONFIG}
	make -j${JOBS}
	make modules
	make dtbs
	#make -C ${EXTERNAL_MODULE_PATH}/wifi KDIR=${KERNEL_PATH}
	make -C ${EXTERNAL_MODULE_PATH}/mali MALI_PLATFORM=${PLATFORM} BUILD=release KDIR=${KERNEL_PATH}

	[ -d ${KERNEL_OUT} ] && rm -rf ${KERNEL_OUT}
	mkdir -p ${KERNEL_OUT}

	find ${KERNEL_PATH}/drivers -name "*.ko" -exec mv -f {} ${KERNEL_OUT} \;
	find ${EXTERNAL_MODULE_PATH} -name "*.ko" -exec mv -f {} ${KERNEL_OUT} \;
	find ${KERNEL_PATH} -name "*Image" -exec mv -f {} ${KERNEL_OUT} \;
}

function clean() {
	[ -d ${KERNEL_OUT} ] && rm -rf ${KERNEL_OUT}
	make mrproper
}

function main() {
	[ "${1}" = "clean" ] && clean || build_kernel
}

main $@
