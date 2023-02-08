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

* Configure snapserver.  A basic `/etc/snapserver.conf` says:
```
[server]
[http]
doc_root = /home/jonh/snapcast/server/etc/snapweb
[tcp]
[stream]
source = pipe:///var/run/snapserver/snapfifo?name=Main
[logging]
```

* Add the web UI components. For reasons I don't understand, the ubuntu
snapserver package didn't include the web UI components. Note my `doc_root`
config line above; it points into a clone of `https://github.com/badaix/snapcast.git`.

* Restart the service to pick up the config changes. (Installing snapserver via
apt should already have enabled the service.)
```
sudo systemd restart snapserver
```
