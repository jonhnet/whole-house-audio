#!/usr/bin/env bash

# bail out if anything goes awry
set -e

. pi-setup-options.sh

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd ${SCRIPT_DIR}


# Do some rooty work
sudo ./pi_setup_root.sh

# Configure pulseaudio to forward to RTP.
#*IMPORTANT**: I added a destination_ip here, aiming the RTP hose at my
#audio server.
```
cat << __EOF__ > .config/pulse/default.pa
.include /etc/pulse/default.pa
load-module module-null-sink sink_name=rtp
load-module module-rtp-send source=rtp.monitor destination_ip=${RTP_LISTENER_IP} port=1760
set-default-sink rtp
__EOF__
```
