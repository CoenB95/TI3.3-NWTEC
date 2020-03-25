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

echo -e "\e[32m  [OK] Done.\e[0m"
