#!/bin/bash

FIRMWARE="esp32-idf3-20191220-v1.12.bin"

function look_for () {
	command -v $1 &> /dev/null
}

function print_usage () {
	echo "Usage:"
	echo "flash-mp.bat flash <PORT>		Flash micropython to ESP32"
	echo "flash-mp.bat copy <PORT> <FILE>	Copy file to ESP32"
	echo "flash-mp.bat run <PORT> <FILE>	Run file on ESP32"
	echo "flash-mp.bat ls <PORT> 		List files currently on ESP32"
	echo "flash-mp.bat rm <PORT> <FILE>	Remove file from ESP32"
}

function check_param () {
	if [ -z "$1" ]; then print_usage; exit 1; fi
}

function check_pyboard () {
	if [ ! -f "./pyboard.py" ]; then
		wget "https://raw.githubusercontent.com/micropython/micropython/master/tools/pyboard.py"
	fi
}

if look_for pip3; then PIP=pip3
elif look_for pip; then PIP=pip
fi

if [ -z "$PIP" ]; then
	echo "pip not found"
	exit 1
fi


if [ "$1" = "flash" ]; then
	check_param $2

	if look_for esptool.py; then
		echo "esptool.py found"
	else
		echo "Installing esptool"
		echo -------------------
		$PIP install esptool
		echo -------------------
		echo "esptool installed"
	fi

	if [ ! -f $FIRMWARE ]; then
		echo "-------------- Downloading firmware ------------"
		wget "https://micropython.org/resources/firmware/${FIRMWARE}" -O $FIRMWARE 
		echo "------------------------------------------------"
	else
		echo "$FIRMWARE found"
	fi
	
	python3 -m esptool --chip esp32 --port $2 erase_flash
	python3 -m esptool --chip esp32 --port $2 --baud 115200 write_flash -z 0x1000 $FIRMWARE

elif [ "$1" = "copy" ]; then
	check_param $2
	check_param $3
	check_pyboard
	./pyboard.py --device $2 -f cp $3 :

elif [ "$1" = "run" ]; then
	check_param $2
	check_param $3
	check_pyboard

	./pyboard.py --device $2 $3

elif [ "$1" = "ls" ]; then
	check_param $2
	check_pyboard

	./pyboard.py --device $2 -f ls

elif [ "$1" = "rm" ]; then
	check_param $2
	check_param $3
	check_pyboard

	./pyboard.py --device $2 -f rm $3 

else
	print_usage
fi
