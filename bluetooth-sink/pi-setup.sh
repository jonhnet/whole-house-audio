#!/usr/bin/env bash

# bail out if anything goes awry
set -e

script_dir="$(dirname "$0")"
cd ${script_dir}

source pi-setup-options.sh

# Do some rooty work
sudo bash ./pi-setup-root.sh

# Configure pulseaudio to forward to RTP.
#*IMPORTANT**: I added a destination_ip here, aiming the RTP hose at my
#audio server.
mkdir -p /home/pi/.config/pulse/
cat << __EOF__ > /home/pi/.config/pulse/default.pa
.include /etc/pulse/default.pa
load-module module-null-sink sink_name=rtp
# this line won't do anythin because it tries to run before network is up:
load-module module-rtp-send source=rtp.monitor destination_ip=${RTP_LISTENER_IP} port=1760
set-default-sink rtp
__EOF__

# Enable the little service that patches up the pulseaudio rtp module
# once the network is running.
# I left it in the git dir because it has a dependency on the pi-setup-options
# file. Meh.
chmod 755 `pwd`/pulse-delayed-rtp.sh
systemctl --user enable `pwd`/pulse-delayed-rtp.service

sudo reboot
