#!/bin/sh

# Start serial terminal
/usr/sbin/startserialtty &

# Set CPU frequency governor to ondemand (default is performance)
echo ondemand > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

# Load modules
/sbin/modprobe i2c-dev

# Start openssh daemon
/usr/local/etc/init.d/openssh start

# ------ Put other system startup commands below this line
ifconfig eth0 192.168.0.240 netmask 255.25.255.0 broadcast 192.168.0.255 up
route add default gw 192.168.0.1
echo nameserver 8.8.8.8 > /etc/resolv.conf


sudo cp /home/tc/submarine/dependencies/usr-lib/* /usr/lib
sudo mkdir /usr/local/include
sudo cp -r /home/tc/submarine/dependencies/usr-local-include/* /usr/local/include
sudo cp /home/tc/submarine/dependencies/usr-local-lib/* /usr/local/lib
sudo ln -s /usr/local/lib/libraspicam.so.0.1.2 /usr/local/lib/libraspicam.so.0.1
sudo ldconfig
cd /home/tc/submarine
sudo ./submarine > /dev/null 2>&1 &
