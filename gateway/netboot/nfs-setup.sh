#!/bin/sh

IP=10.0.0.1

OS_NAME=raspbian
OS_DIR=/mnt/mmcblk0p2/netboot/${OS_NAME}
NFS_DIR=${OS_DIR}/root

CLIENT_NAME= #client1

# Kill all 'udpsvd' process.
# DHCP_PROCESS=$(ps | grep -m 1 "[u]dpsvd" | awk '{print $1}')
# echo -e "\e[33m  Kill running 'udhcpd' processes..\e[0m"
# while [ ! -z "$DHCP_PROCESS" ]
# do
#   echo -e "\e[34m  > Killed udpsvd process (PID=$DHCP_PROCESS).\e[0m"
#   sudo kill $DHCP_PROCESS
#   sleep 0.5
#   DHCP_PROCESS=$(ps | grep -m 1 "[u]dpsvd" | awk '{print $1}')
# done
# echo -e "\e[32m  [OK] Done killing 'udpsvd' processes.\e[0m"
# sleep 2.0

# NFS Export (?)
echo -e "\e[33m  (${CLIENT_NAME}) Export NFS details..\e[0m"
TEST=$(cat /usr/local/etc/exports | grep ${NFS_DIR}/${CLIENT_NAME})
if [ -z "${TEST}" ]
then
  echo "${NFS_DIR}/${CLIENT_NAME} *(rw,sync,no_subtree_check,no_root_squash)" | sudo tee /usr/local/etc/exports
  sudo exportfs -a
  echo -e "\e[32m  [OK] Done.\e[0m"
else
  echo -e "\e[32m  [OK] Already done.\e[0m"
fi
sleep 2.0

echo -e "\e[32m  [BG] NFS Started.\e[0m"
sudo /usr/local/etc/init.d/nfs-server restart
