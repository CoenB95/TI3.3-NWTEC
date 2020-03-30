#!/bin/sh

IP=10.0.0.1
NETBOOT_DIR=/remote-boot
TFTP_DIR=/remote-boot/boot
NFS_DIR=/remote-boot/nfs
DEVICE_KEY=bbbe0e80
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
echo -e "\e[32m  [OK] Cleaning done.\e[0m"
sleep 2.0

# Copy /root filesystem
echo -e "\e[33m  (${CLIENT_NAME}) Copying root directory..\e[0m"
sudo mkdir -p ${NFS_DIR}/${CLIENT_NAME}
sudo rsync -xa --exclude ${NETBOOT_DIR} / ${NFS_DIR}/${CLIENT_NAME}
echo -e "\e[32m  [OK] Done.\e[0m"
sleep 2.0

# Is chrooting ssh needed?

# NFS Export (?)
echo -e "\e[33m  (${CLIENT_NAME}) Export NFS details..\e[0m"
TEST=$(cat /usr/local/etc/exports | grep ${NFS_DIR}/${CLIENT_NAME})
if [ -z "${TEST}" ]
then
  echo "${NFS_DIR}/${CLIENT_NAME} *(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /usr/local/etc/exports
  sudo exportfs -a
  echo -e "\e[32m  [OK] Done.\e[0m"
else
  echo -e "\e[32m  [OK] Already done.\e[0m"
fi
sleep 2.0

echo -e "\e[33m  (${CLIENT_NAME}) LOC..\e[0m"
TEST=$(cat ${TFTP_DIR}/${DEVICE_KEY}/cmdline.txt | grep nfsroot)
if [ -z "${TEST}" ]
then
  sudo sed -i "s|root=[^ ]*|root=/dev/nfs nfsroot=${IP}:${NFS_DIR}/${CLIENT_NAME},vers=4.1,proto=tcp|g" ${TFTP_DIR}/${DEVICE_KEY}/cmdline.txt
  sudo sed -i "s|root=[^ ]*|root=/dev/nfs nfsroot=${IP}:${NFS_DIR}/${CLIENT_NAME},vers=4.1,proto=tcp|g" ${TFTP_DIR}/${DEVICE_KEY}/cmdline3.txt
  echo -e "\e[32m  [OK] Done.\e[0m"
else
  echo -e "\e[32m  [OK] Already done.\e[0m"
fi
sleep 2.0

echo -e "\e[32m  [BG] NFS Started.\e[0m"
sudo /usr/local/etc/init.d/nfs-server restart
