#!/bin/sh

IP=10.0.0.1
PORT=69
ROOT_DIR=/remote-boot

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
if [ ! -d "$ROOT_DIR" ]
then
  echo -e "\e[33m  TFTP directory missing; creating..\e[0m"
  sleep 1.0
  sudo mkdir ${ROOT_DIR}
else
  echo -e "\e[32m  [OK] TFTP directory exists.\e[0m"
  sleep 1.0
fi

echo -e "\e[33m  Removing old files..\e[0m"
sudo rm -r ${ROOT_DIR}/boot
echo -e "\e[32m  [OK] Cleaning done. TFTP directory should be empty:\e[0m"
ls -l ${ROOT_DIR}
sleep 2.0

echo -e "\e[33m  Downloading PiCore zip..\e[0m"
sudo mkdir ${ROOT_DIR}/piCore
sudo wget -P ${ROOT_DIR}/piCore http://tinycorelinux.net/9.x/armv6/releases/RPi/piCore-9.0.3.zip
echo -e "\e[32m  [OK] Downloading done.\e[0m"
sleep 2.0

echo -e "\e[33m  Unzipping..\e[0m"
sudo unzip ${ROOT_DIR}/piCore/piCore-9.0.3.zip -d ${ROOT_DIR}/piCore
echo -e "\e[32m  [OK] Done. Files:\e[0m"
ls -l ${ROOT_DIR}/piCore
sleep 2.0

echo -e "\e[33m  Loop Device..\e[0m"
LOOP_LOCATION=$(sudo losetup -f)
echo -e "\e[34m  > Loopback at $LOOP_LOCATION\e[0m"
sudo losetup -P -f ${ROOT_DIR}/piCore/piCore-9.0.3.img
echo -e "\e[32m  [OK] Loop Device ready.\e[0m"
sleep 2.0

echo -e "\e[33m  Mount..\e[0m"
sudo mkdir -p ${ROOT_DIR}/temp/boot
sudo mkdir -p ${ROOT_DIR}/temp/root
sudo mount ${LOOP_LOCATION}p1 ${ROOT_DIR}/temp/boot
sudo mount ${LOOP_LOCATION}p2 ${ROOT_DIR}/temp/root
echo -e "\e[32m  [OK] Done. Files in /boot:\e[0m"
ls -l ${ROOT_DIR}/temp/boot
sleep 2.0

echo -e "\e[33m  Copying files..\e[0m"
sudo cp -r ${ROOT_DIR}/temp/boot ${ROOT_DIR} #Note: creates /remote-boot/boot directory on its own.
echo -e "\e[32m  [OK] Copying done.\e[0m"
sleep 2.0

echo -e "\e[33m  Unmount..\e[0m"
sudo umount ${ROOT_DIR}/temp/boot
sudo umount ${ROOT_DIR}/temp/root
echo -e "\e[32m  [OK] Done.\e[0m"
sleep 2.0

echo -e "\e[33m  Delete temporary files..\e[0m"
sudo rm -r ${ROOT_DIR}/piCore
sudo rm -r ${ROOT_DIR}/temp
sudo rm ${ROOT_DIR}/boot/bootcode.bin
echo -e "\e[32m  [OK] Done. Files in TFTP-directory:\e[0m"
ls -l ${ROOT_DIR}
sleep 2.0

echo "\e[33m  Replacing bootcode.bin with newest from Raspberry..\e[0m"
sudo wget -P ${ROOT_DIR}/boot https://github.com/raspberrypi/firmware/raw/master/boot/bootcode.bin
echo -e "\e[32m  [OK] Done.\e[0m"

# Start TFTP Server
echo -e "\e[32m  [BG] TFTP started.\e[0m"
sudo udpsvd -vE $IP $PORT tftpd $ROOT_DIR/boot &
