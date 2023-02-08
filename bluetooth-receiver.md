# Bluetooth Receiver 

**Set up a raspberry pi to accept Bluetooth connection and**
**forward audio via RTP to the audio server machine.**

Here are the steps I took from blank SD card to a pi that acts as a bluetooth
-> rtp forwarder.

I did this with a fresh pi, not reusing one of my hifiberry pis, because
hifiberry is running a custom distribution without debian package management.
Combining the two would probably be best done by installing the
snapcast receiver via debian rather than with the hifiberry distro.

I used a Pi 3B. Note that I disabled wifi and used wired ethernet due to
reports (and experience) that bluetooth and wifi don't get along well on
this device. Perhaps the 4 is better; your mileage may vary.

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

* Pair to the newly-advertised bluetooth service and start playing some music.

**End of this step.**
Audio packets should now be spraying at your audio machine.
Proceed to install the [RTP forwarder service](./rtp-forwarder.md) on the audio machine.

[Debugging notes here](./bluetooth-debugging.md)
