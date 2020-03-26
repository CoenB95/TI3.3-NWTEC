#!/bin/sh

# Enable Firewall.
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
echo -e "\e[32m  [OK] Enabled firewall.\e[0m"

# Clear any previously applied rules.
sudo iptables -F
echo -e "\e[32m  [OK] Cleared previous rules.\e[0m"
echo -e "\e[33m  Setting up new rules..\e[0m"

# Start translation services.
sudo iptables -A POSTROUTING -t nat -o eth0 -j MASQUERADE

# Define Firewall rules.
sudo iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT

# Allows all loopback (lo0) traffic and drop all traffic to 127/8 that
# doesn't use lo0
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT ! -i lo -d 127.0.0.0/8 -j REJECT

# Accepts all established inbound connections
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Allows all outbound traffic
sudo iptables -A OUTPUT -j ACCEPT

# Allows HTTP and HTTPS connections from anywhere
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Allows SSH connections
sudo iptables -A INPUT -p tcp -m state --state NEW --dport 22 -j ACCEPT

# Allow ping
sudo iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT

# Reject all other inbound - default deny unless explicitly allowed policy:
sudo iptables -A INPUT -j DROP
sudo iptables -A FORWARD -j DROP

echo -e "\e[32m  [OK] Done.\e[0m"
