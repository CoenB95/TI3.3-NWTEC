#!/bin/sh

# Run the ifconfig-setup.
clear
echo "[1] Setup Ethernet.."
sudo ./dhcp/ethernet-setup.sh
sleep 2.0

# Start DHCP for eth1 and eth2.
clear
echo "[2] Start DHCP (udhcp).."
sudo udhcpd dhcp/dhcp.conf &
sudo udhcpd dhcp/dhcp2.conf &
sleep 2.0

# Copy latest DNS-files to root-directory.
clear
echo "[3] Prepare DNS (copy to /root).."
echo "Copying..."
sudo cp -r ./root-bind/ /root/bind/
echo "Done."
sleep 1.0

# Start DNS.
clear
echo "[4] Setup DNS (named).."
sudo named -c /root/bind/named.conf -g &
sleep 4.0

# Setup Firewall.
clear
echo "[5] Setup NAT (iptables).."
sudo ./nat/tables-setup.sh
sleep 2.0

# Fix our own DNS-server reference.
clear
echo "[6] Set default DNS-server to ourself.."
echo "nameserver 10.0.0.1" | sudo tee /etc/resolv.conf
sleep 2.0

clear
echo "[7] Done. Status report:"
echo "- IP: " && ifconfig eth0
echo "- Check DHCP: " && ps | grep dhcp
echo "- Check DNS: " && ps | grep named
