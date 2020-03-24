#!/bin/sh

IP=10.0.0.1
PORT=69
ROOT_DIR=/remote-boot

# Setup TFTP files
if [ -e /remote-boot ]
then
  echo -e "\e[33m  TFTP directory missing; creating..\e[0m"
  sleep 1.0
  sudo mkdir /var/lib/misc
  sudo touch /var/lib/misc/dhcp.leases
else
  echo -e "\e[32m  [OK] TFTP directory exists.\e[0m"
  sleep 1.0
fi

# Start TFTP Server
echo -e "\e[32m  [BG] TFTP started.\e[0m"
sudo udpsvd -vE $IP $PORT tftpd $ROOT_DIR
