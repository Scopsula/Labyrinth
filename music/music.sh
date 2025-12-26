if [ -f "./DM DOKURO - Glass Structures (vol. 1).zip" ]; then 
  if [ ! -d ./.tmp ]; then 
    mkdir ./.tmp
  fi
  cd ./.tmp
  unzip "../DM DOKURO - Glass Structures (vol. 1).zip"
  rm ./cover.png
  if [ -f "./DM DOKURO - Glass Structures (vol. 1) - 08 Glass Structure (White).mp3" ]; then
    mv "./DM DOKURO - Glass Structures (vol. 1) - 08 Glass Structure (White).mp3" "../../data/audio/0/Glass Structure (White).mp3" 
    cp ../mp3/0 ../../data/audio/0/match
  fi
  if [ -f "./DM DOKURO - Glass Structures (vol. 1) - 08 Glass Structure (White).wav" ]; then
    mv "./DM DOKURO - Glass Structures (vol. 1) - 08 Glass Structure (White).wav" "../../data/audio/0/Glass Structure (White).wav" 
    cp ../wav/0 ../../data/audio/0/match
  fi
  cd ..
fi

if [ -f "./DM DOKURO - Glass Structures (vol. 2).zip" ]; then 
  if [ ! -d ./.tmp ]; then 
    mkdir ./.tmp
  fi
  cd ./.tmp
  unzip "../DM DOKURO - Glass Structures (vol. 2).zip"
  if [ -f "./DM DOKURO - Glass Structures (vol. 2) - 02 Glass Structure (Reflective).mp3" ]; then
    mv "./DM DOKURO - Glass Structures (vol. 2) - 02 Glass Structure (Reflective).mp3" "../../data/audio/1/Glass Structure (Reflective).mp3" 
    cp ../mp3/1 ../../data/audio/1/match
  fi
  if [ -f "./DM DOKURO - Glass Structures (vol. 2) - 02 Glass Structure (Reflective).wav" ]; then
    mv "./DM DOKURO - Glass Structures (vol. 2) - 02 Glass Structure (Reflective).wav" "../../data/audio/1/Glass Structure (Reflective).wav" 
    cp ../wav/1 ../../data/audio/1/match
  fi
  if [ -f "./DM DOKURO - Glass Structures (vol. 2) - 05 Glass Structure (Deep Teal).mp3" ]; then
    mv "./DM DOKURO - Glass Structures (vol. 2) - 05 Glass Structure (Deep Teal).mp3" "../../data/audio/1/Glass Structure (Deep Teal).mp3" 
  fi
  if [ -f "./DM DOKURO - Glass Structures (vol. 2) - 05 Glass Structure (Deep Teal).wav" ]; then
    mv "./DM DOKURO - Glass Structures (vol. 2) - 05 Glass Structure (Deep Teal).wav" "../../data/audio/1/Glass Structure (Deep Teal).wav" 
  fi
  if [ -f "./DM DOKURO - Glass Structures (vol. 2) - 03 Glass Structure (Smoky).mp3" ]; then
    mv "./DM DOKURO - Glass Structures (vol. 2) - 03 Glass Structure (Smoky).mp3" "../../data/audio/2/Glass Structure (Smoky).mp3" 
    cp ../mp3/2 ../../data/audio/2/match
  fi
  if [ -f "./DM DOKURO - Glass Structures (vol. 2) - 03 Glass Structure (Smoky).wav" ]; then
    mv "./DM DOKURO - Glass Structures (vol. 2) - 03 Glass Structure (Smoky).wav" "../../data/audio/2/Glass Structure (Smoky).wav" 
    cp ../wav/2 ../../data/audio/2/match
  fi
  if [ -f "./DM DOKURO - Glass Structures (vol. 2) - 11 Glass Structure (Molten).mp3" ]; then
    mv "./DM DOKURO - Glass Structures (vol. 2) - 11 Glass Structure (Molten).mp3" "../../data/audio/3/Glass Structure (Molten).mp3" 
    cp ../mp3/3 ../../data/audio/3/match
  fi
  if [ -f "./DM DOKURO - Glass Structures (vol. 2) - 11 Glass Structure (Molten).wav" ]; then
    mv "./DM DOKURO - Glass Structures (vol. 2) - 11 Glass Structure (Molten).wav" "../../data/audio/3/Glass Structure (Molten).wav" 
    cp ../wav/3 ../../data/audio/3/match
  fi
  if [ -f "./DM DOKURO - Glass Structures (vol. 2) - 12 Glass Structure (Clear II).mp3" ]; then
    mv "./DM DOKURO - Glass Structures (vol. 2) - 12 Glass Structure (Clear II).mp3" "../../data/audio/4/Glass Structure (Clear II).mp3" 
    cp ../mp3/4 ../../data/audio/4/match
  fi
  if [ -f "./DM DOKURO - Glass Structures (vol. 2) - 12 Glass Structure (Clear II).wav" ]; then
    mv "./DM DOKURO - Glass Structures (vol. 2) - 12 Glass Structure (Clear II).wav" "../../data/audio/4/Glass Structure (Clear II).wav" 
    cp ../wav/4 ../../data/audio/4/match
  fi
  if [ -f "./DM DOKURO - Glass Structures (vol. 2) - 06 Glass Structure (Slate Blue).mp3" ]; then
    mv "./DM DOKURO - Glass Structures (vol. 2) - 06 Glass Structure (Slate Blue).mp3" "../../data/audio/5/Glass Structure (Slate Blue).mp3" 
    cp ../mp3/5 ../../data/audio/5/match
  fi
  if [ -f "./DM DOKURO - Glass Structures (vol. 2) - 06 Glass Structure (Slate Blue).wav" ]; then
    mv "./DM DOKURO - Glass Structures (vol. 2) - 06 Glass Structure (Slate Blue).wav" "../../data/audio/5/Glass Structure (Slate Blue).wav" 
    cp ../wav/5 ../../data/audio/5/match
  fi
  cd ..
fi

rm -rf ./.tmp

