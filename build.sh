#!/bin/sh

if [ ! -d ./bin ]; then 
  mkdir ./bin; 
fi

if [ ! -d ./loadedLevel ]; then 
  mkdir ./loadedLevel; 
fi

nim c -d:release ./src/autoPlayer
nim c -d:release ./src/genConf.nim
mv ./src/autoPlayer ./bin
mv ./src/genConf ./bin

cd ./bin
./genConf
cd ..

