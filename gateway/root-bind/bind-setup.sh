#!/bin/sh

# Kill all 'named' processes.
NAMED_PROCESS=$(ps | grep -m 1 "[n]amed" | awk '{print $1}')
echo -e "\e[33m  Kill running 'named' processes..\e[0m"
while [ ! -z "$NAMED_PROCESS" ]
do
  echo -e "\e[34m  > Killed named process (PID=$NAMED_PROCESS).\e[0m"
  sudo kill $NAMED_PROCESS
  sleep 1.0
  NAMED_PROCESS=$(ps | grep -m 1 "[n]amed" | awk '{print $1}')
done
echo -e "\e[32m  [OK] Done killing 'named' processes.\e[0m"
sleep 2.0

# Copy latest DNS-files to root-directory.
echo -e "\e[33m  Copying files to /root/bind ..\e[0m"
sudo cp -r ./root-bind/ /root/bind/
echo -e "\e[32m  [OK] Copying files done.\e[0m"
sleep 2.0

# Start DNS.
echo -e "\e[32m  [BG] DNS started.\e[0m"
sudo named -c /root/bind/named.conf -g &
sleep 2.0 # Extra delay for dns-service to log its info.
