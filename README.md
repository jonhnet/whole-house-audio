# Recipe for Synchronized Whole-House Audio

## The dish

This recipe makes

    * a whole-house audio system with any number of rooms

    * multiple playlist "channels" so different users can have
    their own settings (who even likes shuffle!?),
    play different music in different rooms, or just
    keep their own playlists paused while others are using the system.

    * a bluetooth input path for playing live content off of phones or
    tablets.

## Backstory

Like any good internet recipe story, this one begins with my life story.
Skip ahead to the next header.

Some years ago our Squeezebox player died. We kept the janky perl daemon and
replaced the player with a raspberry pi, using its built-in DAC connected to
the same 1980s-era audio amp, driving two sets of speakers. A house renovation
demolished the speaker wiring between rooms, and it was finally time to move
into the modern era.

Two neat innovations have come along in the two decades since we bought the
squeezebox. The first is software: the Snapcast time-synchronized audio player
lets you scatter tiny wifi receivers around your house and have them all play
music synchronized together. The second is hardware: the HiFiBerry Amp puts a
60W audio amp into a pi-hat form factor powered by a surplus laptop charger.

This whole story hinges on raspberry pis, which have been unobtanium for a
couple years, but hopefully the situation returns to normal soon.

This system is exactly the sort of thing that appeals to me: open source
everything. But of course that means you get to (have to) choose bits and
pieces at each layer. Here are the choices I've put together so far.

## System Design


## Bluetooth source

### Prepare a pi

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

* Bring the installation entirely up-to-date:
```
sudo apt update && sudo apt -y upgrade
```

* Disable wifi permanently. At least on my pi3, Bluetooth and WiFi don't get along well enough,
so I'm going to keep this thing just plugged into a convenient ethernet port.
```
sudo cp /boot/config.txt /boot/config.txt-bak
awk '{print} /^\[all\]/ && !x { print "dtoverlay=disable-wifi"; x=1}' /boot/config.txt-bak |sudo tee /boot/config.txt > /dev/null
```

* Give the pi a hostname. I chose *blueberry*. This is how it will advertise itself via Bluetooth.
```
sudo hostnamectl set-hostname blueberry
```

* Install pulseaudio & bluetooth packages.
sudo apt-get install -y --no-install-recommends bluez pulseaudio-module-bluetooth bluez-tools

* Create a service to automatically accept Bluetooth connections without needing to accept
the PIN on the pi side.

```
sudo mkdir /etc/bt-accepter-jonh
cat <<__EOF__ | sudo tee /etc/bt-accepter-jonh/bt-pins.txt >/dev/null
00:00:00:00:00:00 *
*                 *
__EOF__


cat <<__EOF__ | sudo tee /etc/bt-accepter-jonh/bt-accepter.sh > /dev/null
#!/bin/bash
# be sure bt is publicly discoverable
sudo hciconfig hci0 up
sudo hciconfig hci0 piscan 
sudo hciconfig hci0 sspmode 1

# make bt pairable without authorization on this end.
bt-agent -c DisplayOnly -p /etc/bt-accepter-jonh/bt-pins.txt
__EOF__
sudo chmod 755 /etc/bt-accepter-jonh/bt-accepter.sh

cat <<__EOF__ | sudo tee /etc/bt-accepter-jonh/bt-accepter-jonh.service > /dev/null
[Unit]
Description=Bluetooth accepter agent (jonh)
After=bluetooth.service

[Service]
RuntimeDirectory=bt-accepter-jonh
User=root
ExecStart=/etc/bt-accepter-jonh/bt-accepter.sh
Restart=on-failure

[Install]
WantedBy=default.target
__EOF__

sudo systemctl enable /etc/bt-accepter-jonh/bt-accepter-jonh.service
sudo systemctl daemon-reload
sudo systemctl start bt-accepter-jonh
```

* Disable pi's user instance of pulseaudio, which isn't there when we're not logged in.
```
systemctl --user disable pulseaudio.service
systemctl --user disable pulseaudio.socket
```

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
```

* Reboot and let everything start up.
```
sudo reboot -f
```

* Pair to the newly-advertised bluetooth service and start playing.

#### sources

Debugging tools I met along the way:

* Is bluetooth discoverable?
```
hciconfig hci0
hciconfig hci0 sspmode
```

#### sources
[bluez packages](https://www.instructables.com/Turn-your-Raspberry-Pi-into-a-Portable-Bluetooth-A/)
[Accepting bluetooth pairings](https://raspberrypi.stackexchange.com/questions/50496/automatically-accept-bluetooth-pairings)
