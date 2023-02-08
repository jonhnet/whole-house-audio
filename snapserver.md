# Set up snapserver

Identify your audio server machine. I have a home server that
already hosts my mp3 files (and does other stuff like backups).

* Install the snapserver software
```
sudo apt install snapserver
```

* Modify the systemd service file.
I did this by making a copy of the debian-installed one, replacing
the symlink in /etc/. In the `[Unit]` section, add:
```
Before=mpd.service
```

In the `[Service]` section, add:
```
RuntimeDirectory=snapserver
```

Since you've changed the systemd service file, you'll need to
```
sudo systemd daemon-reload
```

* Add the web UI components. For reasons I don't understand, the ubuntu
snapserver package didn't include the web UI components.
```
git clone https://github.com/badaix/snapcast.git
```

* Configure snapserver. Here is a basic `/etc/snapserver.conf`. The
`doc_root` line is pointing into the snapcast git clone from the previous
step.
```
[server]
[http]
doc_root = /home/jonh/snapcast/server/etc/snapweb
[tcp]
[stream]
source = pipe:///var/run/snapserver/snapfifo?name=Main
[logging]
```

* Restart the service to pick up the config changes. (Installing snapserver via
apt should already have enabled the service.)
```
sudo systemd restart snapserver
```

* Connect to the snapserver web UI on your server at port 1780.
Click the "play" button in the upper right corner of the web UI.
![Play Button](assets/snapcast-pay-icon.png)

* To confirm it's working, play a song. On the server, stream an mp3 into the snapcast fifo:
```
ffmpeg -y -i filename.mp3 -f u16le -acodec pcm_s16le -ac 2 -ar 48000 /var/run/snapserver/snapfifo
```
You should hear it streaming from the browser. Hooray!

**End of this step.**
Now it's time to [set up a raspberry pi player](./snapclient.md).
