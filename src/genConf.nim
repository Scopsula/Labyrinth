import os

var defConf: string = """
levelSize 10000
coordinates true
resetStats true
thirstDrain true
entities true
items true
itemsOnMap false
sleep 5
entitySpeed 0.6
hud true
"""

if fileExists("../config"):
  echo "\nConfig file exists, remove to update"
else:
  echo "\nCreating config..."
  writeFile("../config", defConf)

echo "File written"
