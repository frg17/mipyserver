from machine import Pin, TouchPad
import time
import network
import socket

html = ""
with open("index.html", "rb") as f:
	html = f.read()

touchme = ""
with open("touchme.html", "rb") as f:
	touchme = f.read()


wlan = network.WLAN(network.AP_IF)
print(wlan.ifconfig())
wlan.ifconfig(('192.168.0.1', '255.255.255.0', '192.168.0.1', '8.8.8.8'))
wlan.config(essid='SupersecretAP')
wlan.active(True)

while wlan.active() == False:
	print('.', end="")

print(' online')

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.setblocking(False)
server.bind(socket.getaddrinfo('192.168.0.1', 80)[0][-1])
server.listen(1)

HAVE_LED = True
led = None
if HAVE_LED: led = Pin(2, Pin.OUT)

led_val = 0
pin15 = Pin(15)
tp = TouchPad(pin15)

def send_response(client, addr):
	print('Sending response')
	if led_val == 1:
		print('Connection from {}'.format(addr))
		print('Sending response')
		client.sendall(b'HTTP/1.1 200 OK\n\n')
		client.sendall(html)
		client.close()
		print('Response sent')
	else:
		print("Sending 2")
		client.sendall(b'HTTP/1.1 200 OK\n\n')
		client.sendall(touchme)
		client.close()



while True:

	try:
		if tp.read() < 200:
			led_val = 1
		else:
			led_val = 0
	except ValueError as e:
		led_val = led_val

	
	try:
		client, addr = server.accept()
		send_response(client, addr)
	except OSError as e:
		pass

	if HAVE_LED: led.value(led_val)
	time.sleep_ms(100)
