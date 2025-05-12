#!/bin/sh

nim c -d:release src/player
nim c -d:release src/genMap
nim c -d:release src/autoPlayer
nim c -d:release src/toggleCarpet
mv src/player bin/
mv src/genMap bin/
mv src/autoPlayer bin/
mv src/toggleCarpet bin/

