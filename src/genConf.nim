import os

var defConf: string = """
levelSize 10000
coordinates true
resetStats true
thirstDrain true
entities false
items true
itemsOnMap false
"""

if fileExists("../config"):
  echo "\nOverwriting config..."
else:
  echo "\nCreating config..."

writeFile("../config", defConf)

echo "File written"
