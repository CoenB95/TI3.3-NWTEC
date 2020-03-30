#!/bin/sh

NFS_DIR=/remote-boot/nfs
CLIENT_NAME=client1

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

# /usr/local/etc/exports

echo -e "\e[33m  Removing old files..\e[0m"
sudo rm -r ${NFS_DIR}
echo -e "\e[32m  [OK] Cleaning done. NFS directory should be empty:\e[0m"
ls -l ${NFS_DIR}
sleep 2.0

# Copy /root filesystem
echo -e "\e[33m  (${CLIENT_NAME}) Copying root directory..\e[0m"
sudo mkdir -p ${NFS_DIR}/${CLIENT_NAME}
sudo rsync -xa --progress --exclude ${NFS_DIR} / ${NFS_DIR}/${CLIENT_NAME}
echo -e "\e[32m  [OK] Done.\e[0m"

# Is chrooting ssh needed?

# Enable NFS
echo -e "\e[33m  (${CLIENT_NAME}) Export NFS..\e[0m"
LINE=$(cat /usr/local/etc/exports | grep ${NFS_DIR}/${CLIENT_NAME})
if [ -z "${LINE}" ]
then
  echo "${NFS_DIR}/${CLIENT_NAME} *(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /usr/local/etc/exports
  echo -e "\e[32m  [OK] Done.\e[0m"
else
  echo -e "\e[32m  [OK] Already done.\e[0m"
fi
