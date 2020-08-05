@echo off

set PYTHON=""
set FIRMWARE="esp32-idf3-20191220-v1.12.bin"

WHERE py > nul 2>&1

if not errorlevel 1 set PYTHON=py & goto:pyfound

WHERE python > nul 2>&1
if not errorlevel 1 set PYTHON=python & goto:pyfound

echo "python has to be installed" & exit /B 1


:pyfound
if "%1"=="flash" (

	if "%2"=="" goto:usage
	
	%PYTHON% -m pip show esptool > nul 2>&1
	if not errorlevel 1 (echo esptool found) else (%PYTHON% -m pip install esptool)

	if not exist %FIRMWARE% ( 
		echo ---------- Downloading Micropytohn firmware ------------
		curl https://micropython.org/resources/firmware/%FIRMWARE% --output %FIRMWARE%
		echo --------------------------------------------------------
	)

	%PYTHON% -m esptool --chip esp32 --port %2 erase_flash
	if %ERRORLEVEL% == 1 echo Error: "%2% is probably not the right port." & exit /B 1
	%PYTHON% -m esptool --chip esp32 --port %2 --baud 115200 write_flash -z 0x1000 %FIRMWARE%
	exit /B 0
)

if "%1"=="copy" (
	if "%2"=="" goto:usage
	if "%3"=="" goto:usage
	
	if NOT EXIST pyboard.py (
		echo ---------- Downloading pyboard.py -----------
		curl https://raw.githubusercontent.com/micropython/micropython/master/tools/pyboard.py -o pyboard.py
		echo ---------------------------------------------
	)
	
	%PYTHON% "pyboard.py" --device %2 -f cp %3 :
	
	exit /B 0
)

if "%1"=="run" (
	if "%2"=="" goto:usage
	if "%3"=="" goto:usage
	
	if NOT EXIST pyboard.py (
		echo ---------- Downloading pyboard.py -----------
		curl https://raw.githubusercontent.com/micropython/micropython/master/tools/pyboard.py -o pyboard.py
		echo ---------------------------------------------
	)
	
	@echo on
	%PYTHON% "pyboard.py" --device %2 %3
	@echo off

	exit /B 0
)

if "%1"=="ls" (
	if "%2"=="" goto:usage
	
	if NOT EXIST pyboard.py (
		echo ---------- Downloading pyboard.py -----------
		curl https://raw.githubusercontent.com/micropython/micropython/master/tools/pyboard.py -o pyboard.py
		echo ---------------------------------------------
	)
	
	@echo on
	%PYTHON% "pyboard.py" --device %2 -f ls
	@echo off

	exit /B 0
)

if "%1"=="rm" (
	if "%2"=="" goto:usage
	if "%3"=="" goto:usage
	
	if NOT EXIST pyboard.py (
		echo ---------- Downloading pyboard.py -----------
		curl https://raw.githubusercontent.com/micropython/micropython/master/tools/pyboard.py -o pyboard.py
		echo ---------------------------------------------
	)
	
	@echo on
	%PYTHON% "pyboard.py" --device %2 -f rm %3
	@echo off

	exit /B 0
)


:usage	
echo Usage:
echo "flash-mp.bat flash <PORT>		Flash micropython to ESP32"
echo "flash-mp.bat copy <PORT> <FILE>	Copy file to ESP32"
echo "flash-mp.bat run <PORT> <FILE>		Run file on ESP32"
echo "flash-mp.bat ls <PORT> 		List files currently on ESP32"
echo "flash-mp.bat rm <PORT> <FILE>		Remove file from ESP32"





