#!/bin/sh

IP=10.0.0.1
PORT=69
ROOT_DIR=/remote-boot

# Start TFTP Server
echo -e "\e[32m  [BG] TFTP started.\e[0m"
udpsvd -vE $IP $PORT tftpd $ROOT_DIR
