<img width="1847" height="938" alt="Level 0" src="https://github.com/user-attachments/assets/81c876f2-ccfb-4e71-97da-84e9564c607e" />

Wiki: https://scopsula.github.io/Labyrinth/<br>
Note: The wiki is not neccesary to play/understand the game.<br>

This is a WIP rouguelike backrooms game with static procedurally generated levels.<br>
For more details view the wiki above<br>

Audio files (in data/audio) are non-free, and are copyright of DM DOKURO
- These are not licensed under the GPL
- More details can be found in data/audio/README.md (such as album links)

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

