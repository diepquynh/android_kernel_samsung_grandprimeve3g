#!/bin/bash

# Scripts to create dt.img from Spreadtrum device tree files (dts)
# Originally edited from sprd_tool repo
# (see https://github.com/koquantam/sprd_tool)
# Edited for kernel tree support by Nguyen Tuan Quyen

filename=$(basename $0)
dtimg="dt.img"
status="none"
declare -a dts_array

TOOL_DTC_FOLDER=$(pwd)/scripts/dtc
TOOL_DTC=$TOOL_DTC_FOLDER/dtc
TOOL_DTBTOOL=$(pwd)/scripts/dtbTool

function help() {
	echo "$filename [-h|-i <dts>|-o <img>]"
	echo "  -h: help"
	echo "  -i: input dts files"
	echo "  -o: output dt.img file"

	exit
}

function push_content {
	if [[ $status == "input" ]]; then
		dts_array[${#dts_array[@]}]=$1
	elif [[ $status == "output" ]]; then
		dtimg=$1
	fi
}

if (($#>0)); then
	while [ -n "$1" ]; do
		case $1 in
			-h) help ;;
			-i) status="input" ;;
			-o) status="output" ;;
			*) push_content $1 ;;
		esac
		shift 1
	done
else
	help
fi

if ((${#dts_array[@]} == 0)); then
	help
fi

echo "input: ${dts_array[@]}"
echo "output: $dtimg"

for dts_file in ${dts_array[@]}; do
	if [ -e $dts_file ]; then
		$TOOL_DTC -I dts -O dtb $dts_file -o $(pwd)/arch/arm/boot/dts/$dts_file.dtb
	fi
done

$TOOL_DTBTOOL -o $dtimg $(pwd)/arch/arm/boot/dts/ -p $TOOL_DTC_FOLDER/

