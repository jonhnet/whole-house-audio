#!/usr/bin/env bash

source pi-setup-options.sh

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd ${SCRIPT_DIR}

# bail out if anything goes awry
set -e


hostnamectl set-hostname ${HOSTNAME}

# Set up user pi as the official user, but with no valid password
# (login via ssh only)
# applies on next boot
# https://www.raspberrypi.com/news/raspberry-pi-bullseye-update-april-2022/
cat "pi:*" > /boot/userconf.txt

mkdir /root/.ssh/
cp /home/pi/.ssh/authorized_keys /root/.ssh/

apt update

# Upgrade machine
# XXX slow; restore once testing complete
#apt -y upgrade

cp /boot/config.txt /boot/config.txt-bak

awk '{print} /^\[all\]/ && !x { print "dtoverlay=disable-wifi"; x=1}' /boot/config.txt-bak > /boot/config.txt

# Install the packages we actually need
apt-get install -y --no-install-recommends bluez pulseaudio-module-bluetooth bluez-tools

# Install some packages I want when debugging
sudo apt install -y tcpdump vim lsof

# Create a service to automatically accept Bluetooth connections without needing to accept the PIN on the pi side
mkdir /etc/bt-accepter-jonh
cp bt-accepter-jonh.service bt-pins.txt /etc/bt-accepter-jonh

systemctl daemon-reload
systemctl enable /etc/bt-accepter-jonh/bt-accepter-jonh.service
systemctl start bt-accepter-jonh

