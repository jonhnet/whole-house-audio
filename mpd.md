# Set up the music player daemon on your server

(*These docs are a little scrappier than the tidy, well-tested
bluetooth instructions. Sorry.*)

* Build mpd

The version of mpd that comes with ubuntu is ancient; you want
to build from source to get modern features like album art.
These instructions will install in `/usr/local` and create a systemd
service.

[Instructions here](https://mpd.readthedocs.io/en/stable/user.html#compiling-from-source)

* Configure mpd.

Change these fields in `/etc/mpd.conf`. Set `music_directory` appropriately
for your system.
```
music_directory     "/home/mp3s"

bind_to_address			"any"

audio_output {
    type            "fifo"
    name            "snapserver"
    path            "/var/run/snapserver/snapfifo"
    format          "48000:16:2"
    mixer_type      "software"
}
```

* Restart mpd with the new config.
```
systemctl restart mpd
```

* Tell mpd to scan and index your music library.
**Note that you'll need to do this whenever you add new music to your
mp3 storage directory.**
```
mpc update
```

## Sources
[mpd snapserver config](https://github.com/badaix/snapcast/blob/master/doc/player_setup.md)
