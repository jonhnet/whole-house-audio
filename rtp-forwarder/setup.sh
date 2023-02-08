#!/usr/bin/env bash
set -e
set -x

SERVICE_DIR=/etc/rtp-listener-jonh
mkdir -p $SERVICE_DIR
# Learn the SDP config by listening to SAP messages from pi player.
./capture-sdp.sh > $SERVICE_DIR/source.sdp
# Set up the service
cp rtp-listener.sh $SERVICE_DIR
cp rtp-listener-jonh.service $SERVICE_DIR
systemctl enable $SERVICE_DIR/rtp-listener-jonh.service
systemctl start rtp-listener-jonh.service
