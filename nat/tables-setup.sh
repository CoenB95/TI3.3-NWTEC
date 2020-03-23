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

echo "Setting up iptables..."
echo 1 > /proc/sys/net/ipv4/ip_forward
# iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
# iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
# iptables -A FORWARD -i eth0 -o eth2 -m state --state RELATED,ESTABLISHED -j ACCEPT
# iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
# iptables -A FORWARD -i eth2 -o eth0 -j ACCEPT
iptables -F
iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT
iptables -A FORWARD -i eth0 -o eth2 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth1 -o eth2 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth2 -o eth1 -j ACCEPT
echo "Setting up iptables done."
