#!/bin/sh

# Optional: sleep on to-fast startup
# sleep 0.2

# Kill eth1 process started by system.
echo -e "\e[33m  Kill running eth1 processes..\e[0m"
if [ -f /var/run/udhcpc.eth1.pid ]
then
  sudo kill `cat /var/run/udhcpc.eth1.pid`
  echo -e "\e[34  > Killed eth1 process."
  sleep 0.1
fi

# Setup our own eth1 as we want it.
sudo ifconfig eth1 10.0.0.1 netmask 255.255.255.248 broadcast 10.0.0.15 up
echo -e "\e[32m  [OK] Activated eth1."
echo -e "\e[32m  [OK] Done.\e[0m"
