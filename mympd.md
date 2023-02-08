# Set up the music player web UI

MPD is controlled by a standard API; you can drive it from the command
line or from your choice of clients, including native Android clients.
I found it easiest to use a single web UI from all my devices and browsers.
[myMPD](https://github.com/jcorporation/myMPD) is pretty nice.
Like mpd, you'll want to grab a recent copy from github.

* Compile mympd
```
git clone https://github.com/jcorporation/myMPD.git
cd myMPD
./build.sh release
sudo ./build.sh install
```

* Enable the service.
```
sudo systemctl enable mympd
sudo systemctl start mympd
echo 7780 | sudo tee /var/lib/mympd/config/http_port
```

* Browse to mympd on port 7780.
Select some music and play it!
