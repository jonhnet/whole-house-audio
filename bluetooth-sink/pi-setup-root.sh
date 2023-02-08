#!/usr/bin/env bash

# bail out if anything goes awry
set -e

script_dir="$(dirname "$0")"
cd ${script_dir}

source pi-setup-options.sh

# userconfig may decide to hang out in dkpg-reconfigure
systemctl stop userconfig

hostnamectl set-hostname ${HOSTNAME}

# Set up user pi as the official user, but with no valid password
# (login via ssh only)
# applies on next boot
# https://www.raspberrypi.com/news/raspberry-pi-bullseye-update-april-2022/
echo 'pi:*' > /boot/userconf.txt

mkdir -p /root/.ssh/
cp /home/pi/.ssh/authorized_keys /root/.ssh/

apt update

# Upgrade machine
# XXX slow; restore once testing complete
apt -y upgrade

cp /boot/config.txt /boot/config.txt-bak

awk '{print} /^\[all\]/ && !x { print "dtoverlay=disable-wifi"; x=1}' /boot/config.txt-bak > /boot/config.txt

# Install the packages we actually need
apt-get install -y --no-install-recommends bluez pulseaudio-module-bluetooth bluez-tools

# Install some packages I want when debugging
sudo apt install -y tcpdump vim lsof

# Create a service to automatically accept Bluetooth connections without needing to accept the PIN on the pi side
mkdir -p /etc/bt-accepter-jonh
cp bt-accepter-jonh.service bt-pins.txt /etc/bt-accepter-jonh

systemctl daemon-reload
systemctl enable /etc/bt-accepter-jonh/bt-accepter-jonh.service
systemctl start bt-accepter-jonh

# Set pi to log in at a text console automatically.
# pulseaudio runs as pi, only when pi is logged in.
# (I tried, OH HOW I TRIED, to get pulseaudio to run as root
# or as user pi in a systemd Unit, with no luck. So I'm just
# running it the way it wants to be run.)
# Cribbed this from raspi-config: Boot Options / B2

systemctl --quiet set-default multi-user.target

USER=pi
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin $USER --noclear %I \$TERM
EOF

