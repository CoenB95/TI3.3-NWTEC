#!/bin/sh

# The snort script.
# Should be called from ~/.profile.

# If snort is occrectly installed and the rules have been downloaded this should make it work as an IDS
echo "Booting up Snort"
./snort -d -h 192.168.1.0/24 -l ./log -c snort.conf
echo "Snort has been booted up"