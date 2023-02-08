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

* Execute the setup script, which ends with a reboot
```
bash whole-house-audio/bluetooth-sink/pi-setup.sh
```

* Pair to the newly-advertised bluetooth service and start playing.

The End.

------------------------------------------------------------------------------
broke here
------------------------------------------------------------------------------

* Configure pulseaudio to not exit on idle, since that closes Bluetooth connection.

sudo 'echo exit-idle-time = -1 >> /etc/pulse/daemon.conf'


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

* Even when I get the thing working, it randomly suspends itself.

* rtp listener on host is flaky as heck, needs restarts, needs ffmpeg process
  to be manually killed.

* bt-discoverable-jonh.service re-running every 5s forever is a hack and
  a half, since I couldn't get the dependencies right for the discoverability
  to stay put.

#### sources
* [bluez packages](https://www.instructables.com/Turn-your-Raspberry-Pi-into-a-Portable-Bluetooth-A/)

* [Accepting bluetooth pairings](https://raspberrypi.stackexchange.com/questions/50496/automatically-accept-bluetooth-pairings)
