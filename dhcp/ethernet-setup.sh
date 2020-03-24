#!/bin/sh

# Optional: sleep on to-fast startup
# sleep 0.2

# Kill eth1 process started by system.
if [ -f /var/run/udhcpc.eth1.pid ]
then
  kill `cat /var/run/udhcpc.eth1.pid`
  echo "Killed eth1 process."
  sleep 0.1
fi

# Setup our own eth1 as we want it.
ifconfig eth1 10.0.0.1 netmask 255.255.255.248 broadcast 10.0.0.15 up
echo "Activated eth1"
