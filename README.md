<img width="1847" height="938" alt="Level 0" src="https://github.com/user-attachments/assets/81c876f2-ccfb-4e71-97da-84e9564c607e" />

This is a small Backrooms / Labyrinth game with theming options using illwill.

Tiles are 10x5 and additional matching can be created in chars/{level}/match.
Logic for level specific themeing (e.g ceillings) can be editted in src/style.nim.
New levels can be created without any code:
- Create a directory with the proceeding level number
- Add files path and wall with your 10x5 tiles
- Optinally add match file to match an internal character with a tile
- Entities will eventually be able to be added without any code modifications

The default tile set is loosely based on the backrooms.
Made on Linux, may work on other systems

Building on Linux:
- Depends on illwill (non-blocking input for entities to move live)
- build.sh will create the required directories and compile everything needed

Configuration:
- Config file can be generated with genConf (set to run in build.sh)
- Values for level size can be adjusted as well as enabling coordinates, entities, survivial, etc
- Coordinates shows the XY for you and the goal, as well as marking it on the map.

Keyboard Repeat may help for quicker movement:
- Tested with a repeat delay of 300ms & repeat rate of 50ms

Suggested Values for Level Iterations/Size:
- 300 to 500 for small monitors (laptops) and short completion times
- 1000 to 5000 for longer completion times
- 3000 to 10000+ is fine on desktops (1920x1080)
- Anything up to 1000000 will generate quick enough
- Coordinates make higher values (e.g 10000000) more viable

autoPlayer:
- Automatically generates and switches to the next sequencial level
- Starts at and cycles back to 0
- Has a goal marked by a spiral
- Has a map, can be opened with m
- Has an inventory system
- Has thirst (survivial mechanic)
- Has entities, they currently get deleted on contact (planned to have turned based combat)
- For testing purpose:
- - [r] can be used to regenerate levels
- - [n] can be used to cycle levels

player:
- LEGACY MAY NOT WORK AND IS OUTDATED
- Slower placement times (if not present on map)
- Loads the current map in ../loadedLevel/map
- Uses the level number set in ../loadedLevel/level
- Has a goal same as autoPlayer but it disappeares on contact instead
- Same map as autoPlayer

genMap:
- LEGACY OUTDATED GENERATION
- Generates and writes a map to ../loadedLevel/map
- Doesn't use the config value for level size
