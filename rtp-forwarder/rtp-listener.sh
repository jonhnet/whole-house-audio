#!/bin/bash
ffmpeg -loglevel debug \
  -listen_timeout 99000000 \
  -protocol_whitelist file,crypto,udp,rtp \
  -i /etc/rtp-listener-jonh/source.sdp \
  -f u16le -acodec pcm_s16le -ac 2 -ar 48000 -\
  | nc -q 1 -N -O 40 tenino 1790
