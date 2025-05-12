import os, strformat

if readFile("../chars/800") != readFile("../chars/899"):
  for i in 0 .. 98:
    if fileExists(&"../chars/{800 + i}") and 800 + i < 807:
      copyFile(&"../chars/{800 + i}", &"../disabled/{800 + i}")
      writeFile(&"../chars/{800 + i}", readFile("../chars/899"))
    else: break
else:
  for i in 0 .. 98:
    if fileExists(&"../disabled/{800 + i}") and 800 + i < 807:
      moveFile(&"../disabled/{800 + i}", &"../chars/{800 + i}")
    else: break

