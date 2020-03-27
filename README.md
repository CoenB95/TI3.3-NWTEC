# PiNetwork

## Clean start
After flashing PiCore to the gateway, run the following commands to set up necessary tools:
```
# Note: check date with 'date' command to confirm ntp working (needed for tce-load for example)
# Follow http://tinycorelinux.net/5.x/armv6/releases/README to enlarge the second partition.
sudo reboot
tce-load -wi nano # usefull. Very very usefull
tce-load -wi git
tce-load -wi bind
tce-load -wi iptables
git clone <this-repository>
cd TI3.3-NWTEC/gateway
./network-setup
```
## Setup

Add the following line to the end of `~/.profile`:
```
[..]
+ # Start the main script after boot.
+ ~/TI3.3-NWTEC/network-setup.sh
```
