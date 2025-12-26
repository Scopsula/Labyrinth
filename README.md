<img width="1847" height="938" alt="Level 0" src="https://github.com/user-attachments/assets/81c876f2-ccfb-4e71-97da-84e9564c607e" />

Wiki: https://scopsula.github.io/Labyrinth/<br>
Note: The wiki is not neccesary to play/understand the game.<br>
Note: The wiki is very outdated currently.<br>

This is a WIP rouguelike backrooms game with static* procedurally generated levels.<br>
For more details view the wiki above<br>

CURRENTLY LINUX ONLY: 
- This game will compile on windows but doesn't display correctly.
- I don't have a way to test MacOS however it may work.

Music must be self downloaded (optional):
- Labyrinth is modular so you can use your own music instead of the following
- Download 1: https://dmdokuro.bandcamp.com/album/glass-structures-vol-1
- Download 2: https://dmdokuro.bandcamp.com/album/glass-structures-vol-2
- Credit to DM DOKURO
- You must either download the wav or mp3 version
- Place the zips in the Labyrinth/music directory
- music.sh will extract and move the files into the correct place
- Make sure to run music.sh inside of the music directory
- Make sure unzip is installed / available
- remove.sh can be used to remove the audio file + match
- More details can be found in [data/audio/README.md](https://github.com/Scopsula/Labyrinth/blob/main/data/audio/README.MD)

Building on Linux:
- Depends on illwill https://github.com/johnnovak/illwill
- Depends on parasound https://github.com/paranim/parasound
- If nimble is present build.sh will attempt to install these if not already
- build.sh will compile the game and generate the config

Running:
- Change to the bin directory and execute autoPlayer
- On NixOS run using steam-run for audio

Game Configuration:
- In data/config, to generate run genConf in bin
