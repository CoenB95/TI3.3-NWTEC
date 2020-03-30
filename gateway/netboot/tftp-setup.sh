#!/bin/sh

IP=10.0.0.1
PORT=69
TFTP_DIR=/remote-boot/boot
DEVICE_KEY=bbe

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
sleep 2.0

# Setup TFTP files
echo -e "\e[33m  Removing old files..\e[0m"
sudo rm -r ${TFTP_DIR}
echo -e "\e[32m  [OK] Cleaning done.\e[0m"
sleep 2.0

echo -e "\e[33m  Downloading PiCore zip..\e[0m"
sudo mkdir -p ${TFTP_DIR}/piCore
sudo wget -P ${TFTP_DIR}/piCore http://tinycorelinux.net/9.x/armv6/releases/RPi/piCore-9.0.3.zip
echo -e "\e[32m  [OK] Downloading done.\e[0m"
sleep 2.0

echo -e "\e[33m  Unzipping..\e[0m"
sudo unzip ${TFTP_DIR}/piCore/piCore-9.0.3.zip -d ${TFTP_DIR}/piCore
echo -e "\e[32m  [OK] Done. Files:\e[0m"
ls -l ${TFTP_DIR}/piCore
sleep 2.0

echo -e "\e[33m  Loop Device..\e[0m"
LOOP_LOCATION=$(sudo losetup -f)
echo -e "\e[34m  > Loopback at $LOOP_LOCATION\e[0m"
sudo losetup -P -f ${TFTP_DIR}/piCore/piCore-9.0.3.img
echo -e "\e[32m  [OK] Loop Device ready.\e[0m"
sleep 2.0

echo -e "\e[33m  Mount..\e[0m"
sudo mkdir ${TFTP_DIR}/piCore/boot
sudo mkdir ${TFTP_DIR}/piCore/root
sudo mount ${LOOP_LOCATION}p1 ${TFTP_DIR}/piCore/boot
sudo mount ${LOOP_LOCATION}p2 ${TFTP_DIR}/piCore/root
echo -e "\e[32m  [OK] Done. Files in /boot:\e[0m"
ls -l ${TFTP_DIR}/piCore/boot
sleep 2.0

echo -e "\e[33m  Copying files..\e[0m"
sudo mkdir ${TFTP_DIR}/default
sudo cp -a ${TFTP_DIR}/piCore/boot/. ${TFTP_DIR}/default
echo -e "\e[32m  [OK] Copying done.\e[0m"
sleep 2.0

echo -e "\e[33m  Replacing bootcode.bin with newest from Raspberry..\e[0m"
sudo rm ${TFTP_DIR}/default/bootcode.bin
sudo rm ${TFTP_DIR}/default/start.elf
sudo wget -P ${TFTP_DIR}/default https://github.com/raspberrypi/firmware/raw/master/boot/bootcode.bin
sudo wget -P ${TFTP_DIR}/default https://github.com/raspberrypi/firmware/raw/master/boot/start.elf
echo -e "\e[32m  [OK] Done.\e[0m"

echo -e "\e[33m  Unmount..\e[0m"
sudo umount ${TFTP_DIR}/piCore/boot
sudo umount ${TFTP_DIR}/piCore/root
echo -e "\e[32m  [OK] Done.\e[0m"
sleep 2.0

echo -e "\e[33m  Delete temporary files..\e[0m"
sudo rm -r ${TFTP_DIR}/piCore
echo -e "\e[32m  [OK] Done. Files in TFTP-directory:\e[0m"
ls -l ${TFTP_DIR}
sleep 2.0

# For every device:

echo -e "\e[33m  Copying files for device '${DEVICE_KEY}'..\e[0m"
sudo mkdir ${TFTP_DIR}/${DEVICE_KEY}
sudo cp -a ${TFTP_DIR}/default/. ${TFTP_DIR}/${DEVICE_KEY}
echo -e "\e[32m  [OK] Copying done.\e[0m"
sleep 2.0

# End for.

# Start TFTP Server
echo -e "\e[32m  [BG] TFTP started.\e[0m"
sudo udpsvd -vE ${IP} ${PORT} tftpd ${TFTP_DIR} &
