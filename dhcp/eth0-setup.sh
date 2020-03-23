#!/bin/sh

# Optional: sleep on to-fast startup
# sleep 0.2

# Kill client
#if [ -f /var/run/udhcpc.eth0.pid ]
#then
#  kill `cat /var/run/udhcpc.eth0.pid`
#    echo Killed eth0 process to be restarted.
#  sleep 0.1
#fi

#ifconfig eth0 145.48.205.25 netmask 255.255.255.0 broadcast 145.48.205.255 up
#echo Activated eth0

# Kill client
if [ -f /var/run/udhcpc.eth1.pid ]
then
  kill `cat /var/run/udhcpc.eth1.pid`
  echo "Killed eth1 process."
  sleep 0.1
fi
if [ -f /var/run/udhcpc.eth2.pid ]
then
  kill `cat /var/run/udhcpc.eth2.pid`
  echo "Killed eth2 process."
fi

ifconfig eth1 10.0.0.1 netmask 255.255.255.248 broadcast 10.0.0.15 up
echo "Activated eth1"

ifconfig eth2 10.0.1.1 netmask 255.255.255.248 broadcast 10.0.0.15 up
echo "Activated eth2"

# Bla
sleep 0.1
#sudo udhcpd /home/tc/dhcp/dhcp.conf &
