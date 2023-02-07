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
```
cat << __EOF__ > /home/pi/.config/pulse/default.pa
.include /etc/pulse/default.pa
load-module module-null-sink sink_name=rtp
load-module module-rtp-send source=rtp.monitor destination_ip=${RTP_LISTENER_IP} port=1760
set-default-sink rtp
__EOF__
```
