<#
 # USB relay module: LCUS-1 (http://images.100y.com.tw/pdf_file/57-LCUS-1.pdf)
 #>

param ([Int] $usb_port=0, [String] $com_port= "COM44", [int] $cmd=0)

#echo "$com_port to usb $usb_port"

if ((0 -eq $usb_port) -or (0 -eq $cmd))
{
	
	$scriptName = $myInvocation.myCommand.name
	echo "$scriptName usb_port com_port cmd"
	echo "1:on_off"
	echo "2:on"
	echo "3:off"
	echo "4:offon"
	echo ""
	echo ""
	
	$portList = get-pnpdevice -class Ports -ea 0
	if ($portList) {
	 foreach($device in $portList) {
		  if ($device.Present) {
			   Write-Host $device.Name "(Manufacturer:"$device.Manufacturer")"
		  }
	 }
	}

}
else
{
	#echo $usb_port
	$ON_CK = 161 + $usb_port
	$OFF_CK = 160 + $usb_port
	#echo $ON_CK
	[Byte[]] $cmdON = 0xA0,$usb_port,0x01,$ON_CK
	[Byte[]] $cmdOFF = 0xA0,$usb_port,0x00,$OFF_CK

	#echo "usb: $usb_port"
	#echo "OON: $cmdON"
	#echo "OFF: $cmdOFF"

	$port= new-Object System.IO.Ports.SerialPort $com_port,9600,None,8,one
	$port.open()
	
	
	if (1 -eq $cmd)
	{
		$port.Write($cmdON, 0, $cmdON.Count)
		Start-Sleep -s 1.5
		$port.Write($cmdOFF, 0, $cmdOFF.Count)
	}

	if (4 -eq $cmd) 
	{
		$port.Write($cmdOFF, 0, $cmdOFF.Count)
		Start-Sleep -s 1.5
		$port.Write($cmdON, 0, $cmdON.Count)
	}
	
	if (2 -eq $cmd)
	{
		$port.Write($cmdON, 0, $cmdON.Count)
	}
	
	if (3 -eq $cmd)
	{
		$port.Write($cmdOFF, 0, $cmdOFF.Count)
	}

	$port.Close()
}
