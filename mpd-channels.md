# Add extra mpd channels

If you have many people sharing one instance of mpd,
it's nice to have multiple channels.

First, even if we're taking turns making the house noisy,
it's nice to be able to pick up my playlist wherever it left off.
And of course, if you can stand the cacophony, you can play different music in
different rooms simultaneously,

To add a new channel:

## Add a new input stream to snapserver.conf

```
[stream]
source = pipe:///var/run/snapserver/snapfifo-j?name=Jon
```

And restart snapserver.
```
systemctl restart snapserver
```

## Add a new instance of mpd

* Construct a new config file

```
mkdir -p /etc/mpd-channels
cp /etc/mpd.conf /etc/mpd-channels/mpd-j.conf
```

* Give the new config a unique port number and assign its fifo.
```
port            "6601"
path            "/var/run/snapserver/snapfifo-j"
```

* Construct a new service file
```
cp /lib/systemd/system/mpd.service /etc/mpd-channels/mpd-j.service
```

* Modify the service file to point at the new config file
```
ExecStart=/usr/local/bin/mpd --systemd /etc/mpd-channels/mpd-j.conf
```

* Enable the service
```
systemctl enable /etc/mpd-channels/mpd-j.service
systemctl start mpd-j
```

## Add a new instance of mympd

* Construct a new mympd configuration directory.
I disabled SSL because the unsigned certificatne makes browsers angry.
It's running behind my firewall, so I'll keep browsing like it's 1993.
```
mkdir /var/lib/mympd-j
cd /var/lib/mympd-j
echo 7781 > config/http_port
echo false > config/ssl
chown -R mympd.mympd .
```

* Construct a new service file
```
cp /lib/systemd/system/mympd.service /etc/mpd-channels/mympd-j.service
```

* Modify it to provide a private working directory and point to the correct mpd
port. Add or change these fields in the `[Service]` section:

```
Environment=MPD_PORT=6601
ExecStart=/usr/bin/mympd --workdir /var/lib/mympd-j --cachedir /var/cache/mympd-j
StateDirectory=mympd-j
CacheDirectory=mympd-j
```

* Enable the service
```
systemctl enable /etc/mpd-channels/mympd-j.service
systemctl start mympd-j
```

* Set up the mpd target.
This step is easiest after mympd is running, after mympd has constructed
its runtime state directories.
```
echo -n localhost > state/mpd_host
echo -n 6601 > state/mpd_port
systemctl restart mympd-j
```

## Update everybody.
Be aware that when you add music, you'll need to update all of the
mpd instances separately.
```
mpc update
mpc --port 6601 update
```
