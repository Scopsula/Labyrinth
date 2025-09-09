#!/bin/sh

if [ ! -d ./bin ]; then 
  mkdir ./bin; 
fi

if [ ! -d ./loadedLevel ]; then 
  mkdir ./loadedLevel; 
fi

nim c -d:release ./src/player
nim c -d:release ./src/genMap
nim c -d:release ./src/autoPlayer
nim c -d:release ./src/genConf.nim
mv ./src/player ./bin
mv ./src/genMap ./bin
mv ./src/autoPlayer ./bin
mv ./src/genConf ./bin

cd ./bin
./genConf
cd ..

