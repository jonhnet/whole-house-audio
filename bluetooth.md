# Prepare the server

TODO

# Prepare a pi

Here are the steps I took from blank SD card to a pi that acts as a bluetooth
-> rtp forwarder.

* Use rpi-imager on a host computer to write Bullseye Raspbian to a fresh SD card.
  I use the gear (advanced settings) icon to prep the card with an ssh pubkey
  to enable a headless login.

* On my network, I tell DHCP to assign a static address to the pi by its ethernet MAC.
  You might use avahi instead, if that's what you're into.

* Plug the card into the pi and let it boot.

* ```ssh pi@<address>``` Instructions in the rest of this section happen inside
  this ssh session.

* Disable wifi for this session so apt will run quickly.
```
sudo ip link set wlan0 down
```

* Install git
```
sudo apt update && sudo apt install -y git
```

* Fetch my installer thingydoo
```
git clone https://github.com/jonhnet/whole-house-audio/
```

* Configure options in `whole-house-audio/bluetooth-sink/pi-setup-options.sh`

* Execute the setup script
```
sh whole-house-audio/bluetooth-sink/pi-setup.sh
```

* Install pulseaudio & bluetooth packages.
```
sudo apt-get install -y --no-install-recommends bluez pulseaudio-module-bluetooth bluez-tools
```

* Create a service to automatically accept Bluetooth connections without needing to accept
the PIN on the pi side.

```
sudo mkdir /etc/bt-accepter-jonh
cat <<__EOF__ | sudo tee /etc/bt-accepter-jonh/bt-pins.txt >/dev/null
00:00:00:00:00:00 *
*                 *
__EOF__

cat <<__EOF__ | sudo tee /etc/bt-accepter-jonh/bt-accepter-jonh.service > /dev/null

[Unit]
Description=Bluetooth accepter agent (jonh)
After=bluetooth.service persistent-pulseaudio.service
StartLimitIntervalSec=0

[Service]
RuntimeDirectory=bt-accepter-jonh
User=root
ExecStart=bt-agent -c DisplayOnly -p /etc/bt-accepter-jonh/bt-pins.txt
Restart=on-failure
RestartSec=5
KillSignal=9

[Install]
WantedBy=default.target
__EOF__

sudo systemctl daemon-reload
sudo systemctl enable /etc/bt-accepter-jonh/bt-accepter-jonh.service
sudo systemctl start bt-accepter-jonh
```

* Create a service to keep the Bluetooth service in a discoverable state.
```
cat <<__EOF__ | sudo tee /etc/bt-accepter-jonh/bt-discoverable.sh > /dev/null
#!/bin/bash
hciconfig hci0 up || exit 1
hciconfig hci0 piscan || exit 1
hciconfig hci0 sspmode 1 || exit 1
chmod go-r /etc/bt-accepter-jonh/bt-pins.txt
__EOF__
sudo chmod 755 /etc/bt-accepter-jonh/bt-discoverable.sh

cat <<__EOF__ | sudo tee /etc/bt-accepter-jonh/bt-discoverable-jonh.service > /dev/null
[Unit]
Description=Bluetooth discoverable agent (jonh)
After=bluetooth.service persistent-pulseaudio.service
StartLimitIntervalSec=0
StartLimitBurst=5

[Service]
RuntimeDirectory=bt-discoverable-jonh
User=root
ExecStart=/etc/bt-accepter-jonh/bt-discoverable.sh
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
__EOF__

sudo systemctl daemon-reload
sudo systemctl enable /etc/bt-accepter-jonh/bt-discoverable-jonh.service
sudo systemctl start bt-discoverable-jonh
```

* Configure pulseaudio to forward to RTP.
**IMPORTANT**: I added a destination_ip here, aiming the RTP hose at my
audio server.
```
cat << __EOF__ > .config/pulse/default.pa
.include /etc/pulse/default.pa
load-module module-null-sink sink_name=rtp
load-module module-rtp-send source=rtp.monitor destination_ip=10.110.0.3 port=1760
set-default-sink rtp
__EOF__
```
------------------------------------------------------------------------------
broke here
------------------------------------------------------------------------------
LEFT OFF trying to get user-slice pulse working again:
- set auto console login. Plug in monitor and see if it worked.
- nope it's stuck on some stupid config dialog
- systemctl disable userconfig -- stopped tty0 from being overtaken
  but still no autologin
-the userconfig dialog set
  * XKBVARIANT in /etc/default/keyboard,
  * pi password in /etc/shadow
  * and some only-ins, particularly getty.target.wants
* looks like setting up /boot/userconf{.txt} will prevent userconfig
  from hanging us up.

* Configure pulseaudio to not suspend sinks on idle.
(I don't know why it thinks the sink is idle when running the way I'm running it; this started once I moved from a user slice to a system unit.

dayyum this is frustrating. I suspect we're battling the system as pi
unit. This didn't happen before.
So how do we keep the logged in thing working?

* Configure pulseaudio to not exit on idle, since that closes Bluetooth connection.

sudo 'echo exit-idle-time = -1 >> /etc/pulse/daemon.conf'


* Disable pi's user instance of pulseaudio, which isn't there when we're not logged in.
```
systemctl --user disable pulseaudio.service
systemctl --user disable pulseaudio.socket
rm /etc/systemd/user/default.target.wants/pulseaudio.service
```
I don't know why the disable commands don't get that last reference.

* Replace it with a system Unit (that still runs as pi)
```
sudo mkdir /etc/persistent-pulseaudio
cat << __EOF__ | sudo tee /etc/persistent-pulseaudio/persistent-pulseaudio.socket > /dev/null
[Unit]
Description=Sound System

[Socket]
Priority=6
Backlog=5
ListenStream=%t/pulse/native
SocketUser=pi
SocketGroup=pi

[Install]
WantedBy=sockets.target
__EOF__

cat << __EOF__ | sudo tee /etc/persistent-pulseaudio/persistent-pulseaudio.service > /dev/null
[Unit]
Description=Sound Service
Requires=persistent-pulseaudio.socket

[Service]
User=pi
Group=pi
ExecStart=/usr/bin/pulseaudio --daemonize=no --log-target=journal
LockPersonality=yes
MemoryDenyWriteExecute=yes
NoNewPrivileges=yes
Restart=on-failure
RestrictNamespaces=yes
SystemCallArchitectures=native
SystemCallFilter=@system-service
# Note that notify will only work if --daemonize=no
Type=notify
UMask=0077

[Install]
Also=persistent-pulseaudio.socket
WantedBy=default.target
__EOF__
sudo systemctl enable /etc/persistent-pulseaudio/persistent-pulseaudio.socket
systemctl start /etc/persistent-pulseaudio/persistent-pulseaudio.service
```

* Reboot and let everything start up.
```
sudo reboot -f
```

* Pair to the newly-advertised bluetooth service and start playing.

The End.

#### debugging tools

Debugging tools I met along the way:

* At setup
```
sudo apt install -y tcpdump vim lsof
sudo mkdir /root/.ssh/
sudo cp /home/pi/.ssh/authorized_keys /root/.ssh/
```

* Is bluetooth discoverable?
```
hciconfig hci0
hciconfig hci0 sspmode
```

* Is pulseaudio sinking audio, and to the right place?
```
pactl list short sinks
```

#### broken stuff

* persistent-pulseaudio-jonh doesn't actually come up in working order after boot. Only clue is log message, but in this mode we don't see the c filename.
```
journalctl -u persistent-pulseaudio.service
...
Feb 06 06:02:42 blueberry pulseaudio[394]: connect() failed: Network is unreachable
...
```

* Even when I get the thing working, it randomly suspends itself.

* rtp listener on host is flaky as heck, needs restarts, needs ffmpeg process
  to be manually killed.

* bt-discoverable-jonh.service re-running every 5s forever is a hack and
  a half, since I couldn't get the dependencies right for the discoverability
  to stay put.

#### sources
* [bluez packages](https://www.instructables.com/Turn-your-Raspberry-Pi-into-a-Portable-Bluetooth-A/)

* [Accepting bluetooth pairings](https://raspberrypi.stackexchange.com/questions/50496/automatically-accept-bluetooth-pairings)
