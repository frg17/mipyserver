# Tiny Micropython AP web server

This should run an ESP32 device as an access point that
contains a tiny static web server on its IP 192.168.0.1

1. To get started, flash the ESP32 with the flash scripts:

```
flash-mp.bat flash <PORT> 		# Windows
./flash-mp.sh flash <PORT>		# Linux
```

2. Copy _main.py_ on to the ESP32

```
flash-mp.bat copy <PORT> main.py	# Windows
./flash-mp.bat copy <PORT> main.py	# Linux
```

3. Copy a file called _index.html_ to the ESP32

```
flash-mp.bat copy <PORT> index.html	# Windows
./flash-mp.bat copy <PORT> index.html	# Linux
```

Web page should be available at 192.168.0.1 when connected to
the ESP32 ap.
