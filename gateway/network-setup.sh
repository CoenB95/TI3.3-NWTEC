#!/bin/sh

# The main script.
# Should be called from ~/.profile.

# Kill any previously launched scripts.
for i in $(seq 1 10)
do
  clear
  echo -e "\e[94m[0/8] Preparing..\e[0m"
  echo -e "\e[33m  Checking IP..\e[0m"
  ONLINE=$(ifconfig eth0 | grep -c "inet")
  if [ $ONLINE > 0 ]
  then
    echo -e "\e[32m  [OK] Online!"
    break
  else
    echo -e "\e[33m  Waiting for eth0.. ($i/10)"
    sleep 1.0
  fi
done

ifconfig eth0 | grep -B1 -w inet | awk '{print $1, $2}'
sleep 2.0

# Setup Ethernet.
clear
echo -e "\e[94m[1/8] Setup Ethernet..\e[0m"
./dhcp/ethernet-setup.sh
sleep 2.0

# Start DHCP. Create file to dump leases if it doesn't exist yet.
clear
echo -e "\e[94m[2/8] Start DHCP (udhcp)..\e[0m"
./dhcp/dhcp-setup.sh
sleep 2.0

clear
echo -e "\e[94m[3/8] Start DNS (named)..\e[0m"
./root-bind/bind-setup.sh
sleep 2.0

# Setup Firewall.
clear
echo -e "\e[94m[4/8] Setup NAT (iptables)..\e[0m"
./nat/tables-setup.sh
sleep 2.0

# Fix our own DNS-server reference.
clear
echo -e "\e[94m[5/8] Set default DNS-server to ourself..\e[0m"
echo "nameserver 10.0.0.1" | sudo tee /etc/resolv.conf
echo -e "\e[32m  [OK] Done.\e[0m"
sleep 2.0

clear
echo -e "\e[94m[6/8] Start TFTP..\e[0m"
./netboot/tftp-setup.sh
sleep 2.0

clear
echo -e "\e[94m[7/8] Start NFS..\e[0m"
./netboot/nfs-setup.sh
sleep 2.0

clear
echo -e "\e[32m[8/8] Done. Status report:\e[0m"
echo -e "\e[33m- IP: \e[0m" && ifconfig eth0 | grep -B1 -w inet | awk '{print $1, $2}'
echo -e "\e[33m- Check DHCP: \e[0m" && ps | grep "[u]dhcp"
echo -e "\e[33m- Check DNS: \e[0m" && ps | grep "[n]amed"
echo -e "\e[33m- Check TFTP: \e[0m" && ps | grep "[u]dpsvd"
echo -e "\e[33m- Check Firewall: \e[0m" && sudo iptables -L -v
