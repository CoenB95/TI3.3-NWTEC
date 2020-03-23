#!/bin/sh

# The main script.
# Should be called from ~/.profile.

# Kill any previously launched scripts.
for i in $(seq 1 10)
do
  clear
  echo "[0/7] Cleanup.."
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
while [ ! -z "$DHCP_PROCESS" = "" ]
do
  echo "Kill udhcp PID=$DHCP_PROCESS"
  sudo kill $DHCP_PROCESS
  sleep 1.0
  DHCP_PROCESS=$(ps | grep -m 1 "[u]dhcpd" | awk '{print $1}')
done
echo "Done."
sleep 2.0

# Kill all 'named' processes.
NAMED_PROCESS=$(ps | grep -m 1 "[n]amed" | awk '{print $1}')
while [ ! -z "$NAMED_PROCESS" = "" ]
do
  echo "Kill named PID=$NAMED_PROCESS"
  sudo kill $NAMED_PROCESS
  sleep 1.0
  NAMED_PROCESS=$(ps | grep -m 1 "[n]amed" | awk '{print $1}')
done
echo "Done."
sleep 2.0

# Run the ifconfig-setup.
clear
echo "[1/7] Setup Ethernet.."
sudo ./dhcp/ethernet-setup.sh
sleep 2.0

# Start DHCP for eth1 and eth2.
clear
echo "[2/7] Start DHCP (udhcp).."
sudo udhcpd -f dhcp/dhcp.conf &
sudo udhcpd -f dhcp/dhcp2.conf &
sleep 2.0

# Copy latest DNS-files to root-directory.
clear
echo "[3/7] Prepare DNS (copy to /root).."
echo "Copying..."
sudo cp -r ./root-bind/ /root/bind/
echo "Done."
sleep 1.0

# Start DNS.
clear
echo "[4/7] Setup DNS (named).."
sudo named -c /root/bind/named.conf -g &
sleep 4.0

# Setup Firewall.
clear
echo "[5/7] Setup NAT (iptables).."
sudo ./nat/tables-setup.sh
sleep 2.0

# Fix our own DNS-server reference.
clear
echo "[6/7] Set default DNS-server to ourself.."
echo "nameserver 10.0.0.1" | sudo tee /etc/resolv.conf
sleep 2.0

clear
echo "[7/7] Done. Status report:"
echo "- IP: " && ifconfig eth0
echo "- Check DHCP: " && ps | grep dhcp
echo "- Check DNS: " && ps | grep named
