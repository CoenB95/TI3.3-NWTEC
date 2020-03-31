#!/bin/sh

DELAY=sleep 2.0

IP=10.0.0.1
PORT=69

OS_NAME=raspbian
OS_DIR=/mnt/mmcblk0p2/netboot/${OS_NAME}
TFTP_DIR=${OS_DIR}/boot

# Kill all 'udpsvd' process.
DHCP_PROCESS=$(ps | grep -m 1 "[u]dpsvd" | awk '{print $1}')
echo -e "\e[33m  Kill running 'udhcpd' processes..\e[0m"
while [ ! -z "$DHCP_PROCESS" ]
do
  echo -e "\e[34m  > Killed udpsvd process (PID=$DHCP_PROCESS).\e[0m"
  sudo kill $DHCP_PROCESS
  sleep 0.5
  DHCP_PROCESS=$(ps | grep -m 1 "[u]dpsvd" | awk '{print $1}')
done
echo -e "\e[32m  [OK] Done killing 'udpsvd' processes.\e[0m"
$DELAY

# Start TFTP Server
echo -e "\e[32m  [BG] TFTP started.\e[0m"
sudo udpsvd -vE ${IP} ${PORT} tftpd ${TFTP_DIR} &
