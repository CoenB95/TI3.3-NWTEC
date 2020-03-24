#!/bin/sh

# The main script.
# Should be called from ~/.profile.

# Kill any previously launched scripts.
for i in $(seq 1 10)
do
  clear
  echo -e "\e[94m[0/7] Cleanup..\e[0m"
  echo -e "\e[33mCheck IP..\e[0m"
  ONLINE=$(ifconfig eth0 | grep -c 'inet')
  if [ $ONLINE == 1 ]
  then
    echo "Online!"
    break
  else
    echo "Waiting for eth0.. ($i/10)"
    sleep 1.0
  fi
done

ifconfig eth0 | grep -B1 -w inet | awk '{print $1, $2}'

# Kill all 'udhcpd' process.
DHCP_PROCESS=$(ps | grep -m 1 "[u]dhcpd" | awk '{print $1}')
echo -e "\e[33mKill running 'udhcp' processes..\e[0m"
while [ ! -z "$DHCP_PROCESS" ]
do
  echo -e "\e[33m- Kill udhcp PID=$DHCP_PROCESS\e[0m"
  sudo kill $DHCP_PROCESS
  sleep 0.2
  DHCP_PROCESS=$(ps | grep -m 1 "[u]dhcpd" | awk '{print $1}')
done

# Kill all 'named' processes.
NAMED_PROCESS=$(ps | grep -m 1 "[n]amed" | awk '{print $1}')
echo -e "\e[33mKill running 'named' processes..\e[0m"
while [ ! -z "$NAMED_PROCESS" ]
do
  echo -e "\e[33mKill named PID=$NAMED_PROCESS\e[0m"
  sudo kill $NAMED_PROCESS
  sleep 1.0
  NAMED_PROCESS=$(ps | grep -m 1 "[n]amed" | awk '{print $1}')
done
echo -e "\e[32mDone cleaning up.\e[0m"
sleep 2.0

# Run the ifconfig-setup.
clear
echo -e "\e[94m[1/7] Setup Ethernet..\e[0m"
sudo ./dhcp/ethernet-setup.sh
echo -e "\e[32mDone.\e[0m"
sleep 2.0

# Start DHCP. Create file to dump leases if it doesn't exist yet.
clear
echo -e "\e[94m[2/7] Start DHCP (udhcp)..\e[0m"
if [ -f /var/lib/misc/dhcp.leases ]
then
  echo -e "\e[33m- Dump-file missing; creating file..\e[0m"
  sleep 1.0
  sudo mkdir /var/lib/misc
  sudo touch /var/lib/misc/dhcp.leases
else
  echo -e "\e[32m- Dump-file exists\e[0m"
  sleep 1.0
fi
sudo udhcpd -f dhcp/dhcp.conf &
sleep 2.0

# Copy latest DNS-files to root-directory.
clear
echo -e "\e[94m[3/7] Prepare DNS (copy to /root)..\e[0m"
echo -e "\e[33mCopying files...\e[0m"
sudo cp -r ./root-bind/ /root/bind/
echo -e "\e[32mCopying files done.\e[0m"
sleep 2.0

# Start DNS.
clear
echo -e "\e[94m[4/7] Start DNS (named)..\e[0m"
sudo named -c /root/bind/named.conf -g &
sleep 4.0

# Setup Firewall.
clear
echo -e "\e[94m[5/7] Setup NAT (iptables)..\e[0m"
sudo ./nat/tables-setup.sh
echo -e "\e[32mDone.\e[0m"
sleep 2.0

# Fix our own DNS-server reference.
clear
echo -e "\e[94m[6/7] Set default DNS-server to ourself..\e[0m"
echo "nameserver 10.0.0.1" | sudo tee /etc/resolv.conf
echo -e "\e[32mDone.\e[0m"
sleep 2.0

clear
echo -e "\e[32m[7/7] Done. Status report:\e[0m"
echo -e "\e[33m- IP: \e[0m" && ifconfig eth0 | grep -B1 -w inet | awk '{print $1, $2}'
echo -e "\e[33m- Check DHCP: \e[0m" && ps | grep dhcp
echo -e "\e[33m- Check DNS: \e[0m" && ps | grep named
echo -e "\e[33m- Check Firewall: \e[0m" && sudo iptables -L -v
