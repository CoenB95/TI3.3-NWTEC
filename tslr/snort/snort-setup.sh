#!/bin/sh

# The snort script.
# Should be called from ~/.profile.

SNORT_DIR=~/TI3.3-NWTEC/tslr/snort

# Remove old rules.
echo -e "\e[33mRemoving old files..\e[0m"
rm -r ${SNORT_DIR}/community-rules
echo -e "\e[32m[OK] Done.\e[0m"
sleep 2.0

# Download fresh rules.
echo -e "\e[33mDownload latest IDS rules..\e[0m"
wget -P ${SNORT_DIR} "https://www.snort.org/downloads/community/community-rules.tar.gz"
echo -e "\e[32m[OK] Done.\e[0m"
sleep 2.0

# Unpack rules.
echo -e "\e[33mUnzip IDS rules..\e[0m"
tar -xvzf ${SNORT_DIR}/community-rules.tar.gz -C ${SNORT_DIR} # Creates ${SNORT_DIR}/community-rules dir.
echo -e "\e[32m[OK] Done.\e[0m"
sleep 2.0

# Cleanup.
echo -e "\e[33mCleanup..\e[0m"
rm ${SNORT_DIR}/community-rules.tar.gz
echo -e "\e[32m[OK] Done. Files in /snort:\e[0m"
ls -l ${SNORT_DIR}
sleep 2.0

# If snort is occrectly installed and the rules have been downloaded this should make it work as an IDS
echo -e "\e[33mBooting up Snort\e[0m"
snort -d -h 192.168.1.0/24 -l ./log -c ${SNORT_DIR}/community-rules/snort.conf
echo "Snort has been booted up"
