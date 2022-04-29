# usb-powered-relay
for LCUS-4 5V USB Relay Module CH340 USB Control Switch **in LINUX**

![](LCUS-4-5V-USB-Relay-Module.jfif)

Baud Rate: 9600bps

## HowTo

	Usage: ./usbser2relay.sh <path_to_tty_device> <relay_number> <0|1>
		   0: Turn the Relay ON
		   1: Turn the Relay OF

**note**: you should run the script with root permission!

Example:

	# ./usbser2relay.sh /dev/ttyUSB1 0 0
