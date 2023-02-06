# Recipe for Synchronized Whole-House Audio

## The dish

This recipe makes

    * a whole-house audio system with any number of rooms

    * multiple playlist "channels" so different users can have
    their own settings (who even likes shuffle!?),
    play different music in different rooms, or just
    keep their own playlists paused while others are using the system.

    * a bluetooth input path for playing live content off of phones or
    tablets.

## Backstory

Like any good internet recipe story, this one begins with my life story.
Skip ahead to the next header.

Some years ago our Squeezebox player died. We kept the janky perl daemon and
replaced the player with a raspberry pi, using its built-in DAC connected to
the same 1980s-era audio amp, driving two sets of speakers. A house renovation
demolished the speaker wiring between rooms, and it was finally time to move
into the modern era.

Two neat innovations have come along in the two decades since we bought the
squeezebox. The first is software: the Snapcast time-synchronized audio player
lets you scatter tiny wifi receivers around your house and have them all play
music synchronized together. The second is hardware: the HiFiBerry Amp puts a
60W audio amp into a pi-hat form factor powered by a surplus laptop charger.

This whole story hinges on raspberry pis, which have been unobtanium for a
couple years, but hopefully the situation returns to normal soon.

This system is exactly the sort of thing that appeals to me: open source
everything. But of course that means you get to (have to) choose bits and
pieces at each layer. Here are the choices I've put together so far.

## System Design


## Bluetooth source

[Set up a pi to forward bluetooth audio to your server](bluetooth.md)
