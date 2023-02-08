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

# Documentation Sources
* [bluez packages](https://www.instructables.com/Turn-your-Raspberry-Pi-into-a-Portable-Bluetooth-A/)

* [Accepting bluetooth pairings](https://raspberrypi.stackexchange.com/questions/50496/automatically-accept-bluetooth-pairings)

# Broken stuff

* bt-discoverable-jonh.service re-running every 5s forever is a hack and
  a half, since I couldn't get the dependencies right for the discoverability
  to stay put.

