работает на piCore11
нужно увеличить место на разделе с tc
нужны пакеты cmake make compiletc isl-dev
setup network:
	/opt/bootlocal.sh

	ifconfig eth0 192.168.0.240 netmask 255.255.255.0 broadcast 192.168.0.255 up
	route add default gw 192.168.0.1
	echo nameserver 8.8.8.8 >> /etc/resolv.conf


ssh auth:
	login: tc
	passwd: piCore
	
scp -o IdentitiesOnly=true -r submarine tc@192.168.0.240:/home/tc
ssh -o IdentitiesOnly=true tc@85.95.167.32:24

Do filetool.sh -bv to backup the system before you reboot.

install package:
	tce-load -wil cmake
load previously installed package:
	tce-load -i cmake
	
usefull package
	rpi-vc (include raspistill)
		sudo vcgencmd get_mem gpu
		sudo vcgencmd get_camera
		sudo mmal_vc_diag camerainfo
	make
	compiletc (gcc g++ .....)
	isl-dev
	
/dev/vc-mem # MMAL video decoding
/dev/vchiq # OpenMax video encoding
/dev/vcsm # VideoCore Shared Memory

здесь релиз и пакеты для piCore
http://ftp.nluug.nl/os/Linux/distr/tinycorelinux/13.x/armv7l/
про сильные стороны piCore на русском
https://habr.com/ru/post/223811/
Концепция дистрибутива
http://www.tinycorelinux.net/concepts.html
Картинка о том как устроена файловая система
http://www.tinycorelinux.net/arch_core.html
