#!/bin/sh

if [ ! -d ./bin ]; then 
  mkdir ./bin; 
fi

nim c -d:release ./src/autoPlayer
nim c -d:release ./src/genConf.nim
mv ./src/autoPlayer ./bin
mv ./src/genConf ./bin

cd ./bin
./genConf
cd ..

