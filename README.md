<img width="1847" height="938" alt="Level 0" src="https://github.com/user-attachments/assets/81c876f2-ccfb-4e71-97da-84e9564c607e" />

Wiki: https://scopsula.github.io/Labyrinth/<br>
Note: The wiki is not neccesary to play/understand the game.<br>
Note: The wiki is very outdated currently.<br>

This is a WIP rouguelike backrooms game with static* procedurally generated levels.<br>
For more details view the wiki above<br>

CURRENTLY LINUX ONLY: 
- This game will compile on windows but doesn't display correctly.
- I don't have a way to test MacOS however it may work.

Music must be self downloaded (optional):<br>
Labyrinth allows for any mp3 / wav as long as match is correctly set<br>
Instructions:
- Download 1: https://dmdokuro.bandcamp.com/album/glass-structures-vol-1
- Download 2: https://dmdokuro.bandcamp.com/album/glass-structures-vol-2
- Credit to DM DOKURO, please consider paying money for these albums
- Download either mp3 or wav version
- Place both zips in the music directory
- If you haven't already run build.sh in the base directory
- Run genMusic in the music directory
- genMusic depends on unzip and optionally depends on soxi (sox)
- Music should now play unless audio has been disabled in config
genMusic automatically generates match and duration (if soxi is present, otherwise preDuration is used)<br>
More details can be found in [data/audio/README.md](https://github.com/Scopsula/Labyrinth/blob/main/data/audio/README.MD)<br>

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
