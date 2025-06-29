# Debugging tools

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

# A networking issue with the BlueTooth sink

I reconfigured how my pi attached to the network, using a tplink
wifi-to-ethernet endpoint, and the extra delay broke the bluetooth sink.

`systemctl --user status pulseaudio`
showed
`sendmsg() failed: Network is unreachable`

`lsof -n -p 575` (for pulseaudio pid) showed that the UDP sockets
were bound to `169.254.157.82`, an "APIPA" address the pi gave to
pulseaudio before it managed to grab a real DHCP address over the
(now-delayed) ethernet.

Proposed solution: Add "Wants: network-online.target" to [Service]
in `EDITOR=vim systemctl edit --full --user pulseaudio`.
Didn't help.

Another search suggested
`systemctl enable systemd-networkd-wait-online.service`
Didn't help.

My next idea is to disallow dhcpcd from assigning the APIPA address
at all.
Add `noipv4ll` to `/etc/dhcpcd.conf`. (No `option` prefix.)

Okay now pulseaudio has a valid address. but still connection refused?
Oh that's the 9875 port.
Well dang, it's ... wait, restarting pulseaudio got it working again.
Okay, actually, it looks like noipv4ll (perhaps combined with the
systemd dependencies above) did the trick to get it working.

# Documentation Sources
* [bluez packages](https://www.instructables.com/Turn-your-Raspberry-Pi-into-a-Portable-Bluetooth-A/)

* [Accepting bluetooth pairings](https://raspberrypi.stackexchange.com/questions/50496/automatically-accept-bluetooth-pairings)

# Broken stuff

* bt-discoverable-jonh.service re-running every 5s forever is a hack and
  a half, since I couldn't get the dependencies right for the discoverability
  to stay put.

