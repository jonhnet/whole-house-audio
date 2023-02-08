# Configure snapserver to accept a TCP audio stream

Add a new **stream** stanza to `/etc/snapserver.conf` as follows.
Replace "blueberry" with the name you'd like to appear in the
snapserver web UI.

```
[stream]
source = tcp://0.0.0.0:1790?name=blueberry&mode=server
```

Restart the snapserver.

```
systemctl restart snapserver
```

**End of this step.**
Now it's ready to receive TCP audio.
Proceed to [set up a bluetooth pi receiver](./bluetooth-receiver.md).
