#!/bin/bash
#
# So we can put the "load-module" comamnd for rtp into .config/pulse/default.pa,
# but it runs too soon, before the network is loaded, and errors out during
# load with:
# E: [pulseaudio] module-rtp-send.c: connect() failed: Network is unreachable
# ...and doesn't hang around to try again. So here's an idempotent little
# script that shoves that load-module command back in later. We'll run
# this after the network is up.
#

script_dir="$(dirname "$0")"
cd ${script_dir}
source pi-setup-options.sh

pactl list modules short | grep -q rtp.monitor
if [[ $? == 0 ]]; then
#echo module present; do nothing
else
#echo module absent; poke it in
pactl load-module module-rtp-send source=rtp.monitor destination_ip=${RTP_LISTENER_IP} port=1760
fi
