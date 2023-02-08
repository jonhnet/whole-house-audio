# Install forwarding service on server

**Set up a service on the audio server machine to
receive UDP RTP and decode it into TCP for snapserver.**

You want to run this step after the bluetooth-receiver pi is running and
sending RTP to the server. Along with the RTP audio stream,
the pi will transmit stream metadata as an "SAP" packet to port 9875 every
10s.
This installer will wait for such a packet and use it to configure the
receive pipeline.

On the audio server machine receiving the RTP:
```
sudo setup.sh
```

**End of this step.**
Decoded audio should be streaming to the snapserver at port 1790.
Use the snapserver web UI to select that stream for one of your playback
devices and you should hear the music playing.
