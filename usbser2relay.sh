#! /bin/sh

# USB relay module: LCUS-1 (http://images.100y.com.tw/pdf_file/57-LCUS-1.pdf)
#
# Test Command:
#     $ sudo /bin/sh -c "echo -n -e '\xA0\x01\x01\xA2' > /dev/ttyUSB1" # COM-NO
#     $ sudo /bin/sh -c "echo -n -e '\xA0\x01\x00\xA1' > /dev/ttyUSB1" # COM-NC

HEX_CODE_OFF='\xA0\x01\x00\xA2'
HEX_CODE_ON='\xA0\x01\x01\xA1'
ROOT_UID=0



serdev="$1"
op="$3"
port=$2
argv="$#"

usage() {
	cat <<EOF

Usage: $0 <path_to_tty_device> <relay_number> <0|1|01|10>
       0: Turn the Relay OFF
       1: Turn the Relay ON
      01: Relay OFF and then ON
      10: Relay ON and then OFF

EX: $0 /dev/ttyUSB1 4 0

EOF
}

do_init() {
	if [ "$argv" != "3" ] || [ "$op" = "" ]; then
		usage
		exit 1
	fi

	host="$(expr substr $(uname -s) 1 5)"
	if [[ "$host" != "CYGWI" && "$host" != "MINGW" ]] ;then
		if [ "$UID" -ne "$ROOT_UID" ] ;then
			echo "Warning: you should run the script with root permission!"
			exit 1
		fi
	fi

	if [ ! -c "$serdev"  ]; then
		cat << EOF

Error: There is no device node: ${serdev}
       Make sure USB-to-TTL driver is loaded! (ex: usbserial,pl2303)

EOF
		exit 1
	fi
    stty -F  $serdev 9600
}

hex2ser() {
	local action="$1"
	if [ "$action" = "ON" ]; then
		/bin/sh -c "echo -n -e '$HEX_CODE_ON' > $serdev"
	else
		/bin/sh -c "echo -n -e '$HEX_CODE_OFF' > $serdev"
	fi
}

ser2relay() {

#echo $port
let c=161+$port
let c1=160+$port
#echo $c
HEX_CODE_ON=$(printf "\\\xA0\\\x%02x\\\x01\\\x%02x" "$port" "$c")
HEX_CODE_OFF=$(printf "\\\xA0\\\x%02x\\\x00\\\x%02x" "$port" "$c1")


	case "$op" in
	1|[Oo][Nn])
		hex2ser "ON"
		;;
	0|[Oo][Ff][Ff])
		hex2ser "OFF"
		;;
	01)
		hex2ser "OFF"
		sleep 1.5
		hex2ser "ON"
		;;
	10)
		hex2ser "ON"
		sleep 1.5
		hex2ser "OFF"
		;;
	*)
		usage
		exit 1
		;;
	esac
}

do_main() {
	do_init && \
	ser2relay
}

do_main
