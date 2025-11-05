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
collision | W|
"""

if fileExists("../data/config"):
  echo "\nConfig file exists, remove to update"
  echo "WARNING: GAME MAY NOT FUNCTION IF CONFIG FORMAT HAS CHANGED"
  echo "Consider backing up config and re-generating, see default config:\n"
  echo defConf
else:
  echo "\nCreating config..."
  writeFile("../data/config", defConf)
  echo "File written"
