#!/bin/sh

# Enable Firewall.
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
echo -e "\e[32m  [OK] Enabled firewall.\e[0m"

# Clear any previously applied rules.
sudo iptables -F
echo -e "\e[32m  [OK] Cleared previous rules.\e[0m"
echo -e "\e[33m  Setting up new rules..\e[0m"

# Note to self: rules are matched top to bottom; first match gets applied.
# So: keep general rejection at the bottom of the list!

# Start translation services.
sudo iptables -A POSTROUTING -t nat -o eth0 -j MASQUERADE

# Define FORWARD rules.
sudo iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT	# Allow responses to forwarded requests.
sudo iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT					# Allow questions forwarded to the internet.
sudo iptables -A FORWARD -j REJECT							# Default (no match above): reject.


# Define INPUT rules.
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT		# Allow all established inbound connections.

sudo iptables -A INPUT -i lo -j ACCEPT							# Allows all loopback (lo0) traffic
sudo iptables -A INPUT ! -i lo -d 127.0.0.0/8 -j REJECT					# and drop all traffic to 127/8 that doesn't use lo0

sudo iptables -A INPUT -p tcp  --dport 80  -j ACCEPT					# Allow HTTP connections from anywhere,
sudo iptables -A INPUT -p tcp  --dport 443 -j ACCEPT					# Allow HTTPS connections from anywhere.
sudo iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT				# Allow ping

sudo iptables -A INPUT -p udp --sport 53 -d 10.0.0.0/28 -j ACCEPT			# Allow DNS requests from anywhere.
sudo iptables -A INPUT -p tcp --sport 53 -d 10.0.0.0/28 -j ACCEPT			# Allow DNS requests from anywhere.
sudo iptables -A INPUT -p udp --dport 53 -d 10.0.0.0/28 -j ACCEPT			# Allow DNS requests from anywhere.
sudo iptables -A INPUT -p tcp --dport 53 -d 10.0.0.0/28 -j ACCEPT			# Allow DNS requests from anywhere.

sudo iptables -A INPUT -p tcp -m state --state NEW --dport 22 -j ACCEPT			# Allows SSH connections from anywhere.

sudo iptables -A INPUT -j LOG
sudo iptables -A INPUT -j REJECT							# Default: reject all inbound traffic.


# Define OUTPUT rules
sudo iptables -A OUTPUT -j ACCEPT							# Default: allow all outbound traffic.


# Save and apply.
sudo iptables-save
echo -e "\e[32m  [OK] Done.\e[0m"
