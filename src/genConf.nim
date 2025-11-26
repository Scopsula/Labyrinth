import os

var defConf: string = """
levelSize 10000
coordinates true
resetStats true
thirstDrain true
entities true
items true
itemsOnMap false
sleep 0
hud true
collision| WP
audio false (Note: Audio must be self-provided)
doRValues true
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
