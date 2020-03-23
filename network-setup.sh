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
#if [ -f /var/run/udhcpc.eth1.pid ]
#then
#  kill `cat /var/run/udhcpc.eth1.pid`
#  echo Killed eth1 process to be restarted.
#  sleep 0.1
#fi

#ifconfig eth1 17.0.0.1 netmask 255.255.255.248 broadcast 17.0.0.15 up
#echo Activated eth1

# Bla
#sleep 0.1
#sudo udhcpd /home/tc/dhcp/dhcp.conf &

echo "[1] Setup Ethernet.."
sudo ./dhcp/eth0-setup.sh

echo "[2] Setup DHCP (udhcp).."
sudo udhcpd dhcp/dhcp.conf &
sudo udhcpd dhcp/dhcp2.conf &

echo "[3] Setup DNS (named;bind9).."
sudo named -c /root/bind/named.conf -g &

echo "[4] Setup NAT (iptables).."
sudo ./nat/tables-setup.sh

echo "[5] Set default DNS-server to ours.."
echo "nameserver 10.0.0.1" | sudo tee /etc/resolv.conf

echo "[6] Done."

sleep 5.0
echo "[7] Status report:"
echo "- IP: " && ifconfig eth0
echo "- Check DHCP: " && ps | grep dhcp
echo "- Check DNS: " && ps | grep named
