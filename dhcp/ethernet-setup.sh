#!/bin/sh

# Optional: sleep on to-fast startup
# sleep 0.2

# Kill client eth1.
if [ -f /var/run/udhcpc.eth1.pid ]
then
  kill `cat /var/run/udhcpc.eth1.pid`
  echo "Killed eth1 process."
  sleep 0.1
fi

# Setup eth1.
ifconfig eth1 10.0.0.1 netmask 255.255.255.248 broadcast 10.0.0.15 up
echo "Activated eth1"

# Kill client eth2.
if [ -f /var/run/udhcpc.eth2.pid ]
then
  kill `cat /var/run/udhcpc.eth2.pid`
  echo "Killed eth2 process."
fi

# Setup eth2.
ifconfig eth2 10.0.1.1 netmask 255.255.255.248 broadcast 10.0.0.15 up
echo "Activated eth2"
