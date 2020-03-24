#!/bin/sh

echo "Setting up iptables..."

# Enable Firewall.
echo 1 > /proc/sys/net/ipv4/ip_forward

# Clear any previously applied rules.
iptables -F

# Start translation services.
iptables -A POSTROUTING -t nat -o eth0 -j MASQUERADE

# Define Firewall rules.
iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT

echo "Setting up iptables done."
