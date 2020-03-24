#!/bin/sh

# Kill all 'udhcpd' process.
DHCP_PROCESS=$(ps | grep -m 1 "[u]dhcpd" | awk '{print $1}')
echo -e "\e[33m  Kill running 'udhcpd' processes..\e[0m"
while [ ! -z "$DHCP_PROCESS" ]
do
  echo -e "\e[34m  > Killed udhcpd process (PID=$DHCP_PROCESS).\e[0m"
  sudo kill $DHCP_PROCESS
  sleep 0.5
  DHCP_PROCESS=$(ps | grep -m 1 "[u]dhcpd" | awk '{print $1}')
done
echo -e "\e[32m  [OK] Done killing 'udhcpd' processes.\e[0m"
sleep 2.0

# Start DHCP. Create file to dump leases if it doesn't exist yet.
if [ -f /var/lib/misc/dhcp.leases ]
then
  echo -e "\e[33m  Dump-file missing; creating file..\e[0m"
  sleep 1.0
  sudo mkdir /var/lib/misc
  sudo touch /var/lib/misc/dhcp.leases
else
  echo -e "\e[32m  [OK] Dump-file exists.\e[0m"
  sleep 1.0
fi
echo -e "\e[32m  [BG] DHCP started.\e[0m"
sudo udhcpd -f dhcp/dhcp.conf &
