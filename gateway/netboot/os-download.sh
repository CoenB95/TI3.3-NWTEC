#!/bin/sh

DELAY="sleep 1.0"

OS_NAME=raspbian #picore
OS_SITE=https://downloads.raspberrypi.org #http://tinycorelinux.net/9.x/armv6/releases/RPi
OS_ZIP=raspbian_lite_latest #piCore-9.0.3.zip
OS_IMG=2020-02-13-raspbian-buster-lite.img #piCore-9.0.3.img
OS_DIR=/mnt/mmcblk0p2/netboot/${OS_NAME}

DEVICE_KEY=bbbe0e80
CLIENT_NAME=tslr

echo -e "\e[33m  Downloading ${OS_NAME}..\e[0m"
sudo mkdir -p ${OS_DIR}/download
sudo wget -P ${OS_DIR}/download ${OS_SITE}/${OS_ZIP}
echo -e "\e[32m  [OK] Downloading done.\e[0m"
$DELAY

echo -e "\e[33m  Unzipping..\e[0m"
sudo unzip ${OS_DIR}/download/${OS_ZIP} -d ${OS_DIR}/download
echo -e "\e[32m  [OK] Done. Files:\e[0m"
ls -l ${OS_DIR}/download
$DELAY

echo -e "\e[33m  Loop Device..\e[0m"
LOOP_LOCATION=$(sudo losetup -f)
echo -e "\e[34m  > Loopback at $LOOP_LOCATION\e[0m"
sudo losetup -P -f ${OS_DIR}/download/${OS_IMG}
echo -e "\e[32m  [OK] Loop Device ready.\e[0m"
$DELAY

echo -e "\e[33m  Mount..\e[0m"
sudo mkdir ${OS_DIR}/download/boot
sudo mkdir ${OS_DIR}/download/root
sudo mount ${LOOP_LOCATION}p1 ${OS_DIR}/download/boot
sudo mount ${LOOP_LOCATION}p2 ${OS_DIR}/download/root
echo -e "\e[32m  [OK] Done. Files in the mounted boot directory:\e[0m"
ls -l ${OS_DIR}/download/mount-boot
$DELAY

echo -e "\e[33m  Copying files..\e[0m"
sudo mkdir ${OS_DIR}/boot
sudo mkdir ${OS_DIR}/root
sudo rsync -xa ${OS_DIR}/download/boot/ ${OS_DIR}/boot
sudo rsync -xa ${OS_DIR}/download/root/ ${OS_DIR}/root
echo -e "\e[32m  [OK] Copying done.\e[0m"
$DELAY

echo -e "\e[33m  Unmount..\e[0m"
sudo umount ${OS_DIR}/download/boot
sudo umount ${OS_DIR}/download/root
sudo rm -r ${OS_DIR}/download
echo -e "\e[32m  [OK] Done.\e[0m"
$DELAY

# For every device, make a copy of /boot (TFTP).
echo -e "\e[33m  Copying files for device '${DEVICE_KEY}'..\e[0m"
sudo mkdir ${OS_DIR}/boot/${DEVICE_KEY}
sudo rsync -xa --exclude ${OS_DIR}/boot/${DEVICE_KEY} ${OS_DIR}/boot/ ${OS_DIR}/boot/${DEVICE_KEY}
echo -e "\e[32m  [OK] Copying done.\e[0m"
$DELAY

# For every client, make a copy of /root (NFS).
# IGNORE FOR NOW: WAY TOO LARGE!
# echo -e "\e[33m  Copying files for client '${CLIENT_NAME}'..\e[0m"
# sudo mkdir ${OS_DIR}/root/${CLIENT_NAME}
# sudo rsync -xa --exclude ${OS_DIR}/root/${CLIENT_NAME} ${OS_DIR}/root/ ${OS_DIR}/root/${CLIENT_NAME}
# echo -e "\e[32m  [OK] Copying done.\e[0m"
$DELAY

# For every device, link root to boot.
# Setup the pxelinux.cfg (for RPi that is cmdline.txt)
echo -e "\e[33m  Edit boot options for netbooting..\e[0m"
echo -e "\e[34m  > Device '${DEVICE_KEY}' shall load files of client '${CLIENT_NAME}'\e[0m"
sudo sed -i "s|root=[^ ]*|root=/dev/nfs nfsmount=${IP}:${OS_DIR}/root/${CLIENT_NAME},vers=4.1,proto=tcp|g" ${OS_DIR}/boot/cmdline.txt
echo -e "\e[32m  [OK] Done.\e[0m"
