#!/usr/bin/env bash

installDeps () { 
  pkgList=$(nimble list --installed)
  if [[ ! $pkgList =~ "illwill" ]]; then
    echo "Installing: illwill"
    nimble install illwill
  else
    echo "Illwill is already installed"
  fi
  if [[ ! $pkgList =~ "parasound" ]]; then
    echo "Installing: parasound"
    nimble install parasound
  else
    echo "Parasound is already installed"
  fi
}

which nimble
if [ $? -eq 0 ]; then
  installDeps
else
  echo "Nimble not found"
fi

if [ ! -d ./bin ]; then 
  mkdir ./bin; 
fi

nim c -d:release -l:-ldl -l:-lm -l:-lpthread ./src/autoPlayer
mv ./src/autoPlayer ./bin

nim c -d:release ./src/genConf.nim
mv ./src/genConf ./bin

nim c -d:release ./src/genMusic.nim
mv ./src/genMusic ./music

cd ./bin
./genConf
cd ..

