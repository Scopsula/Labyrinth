import os, strformat, strutils

if execShellCmd("which unzip") != 0:
  echo "Error: unzip not found"
  quit(1)

let sox: int = execShellCmd("which soxi")
if sox != 0:
  echo "Warning: soxi not found"
  echo "Pre-calculated values will be used instead"

let audioDir: string = "../data/audio/"
var files: seq[array[3, string]]

proc extract(v: string, es: string) =
  let zip: string = &"DM DOKURO - Glass Structures (vol. {v}).zip"
  if fileExists(zip):
    if execShellCmd(&"unzip -l '{zip}' | grep -q '{es}'") == 0:
      if not dirExists(".tmp"):
        createDir(".tmp")
      discard execShellCmd(&"unzip -o '{zip}' '{es}' -d .tmp")

proc calcDur(file: string) =
  let nS: string = &"{file[0 .. ^5]}.duration"
  if sox == 0:
    discard execShellCmd(&"soxi -D '{file}' > '{nS}'")
  else:
    let preLoc = nS.split('/')[^1]
    copyFile(&"preDuration/{preLoc}", nS)

proc move(v: string, t: string, n: string, target: string, structure: string) =
  if not fileExists(&"{audioDir}{target}"):
    createDir(&"{audioDir}{target}")

  let s: string = &"DM DOKURO - Glass Structures (vol. {v}) - {t} Glass Structure ({n})"

  let nS: string = &"Glass Structure ({n})"
  var fType: string = ".wav"
  for i in 0 .. 1:
    let file = &"{audioDir}{target}{nS}{fType}"
    if not fileExists(file):
      extract(v, &"{s}{fType}")
      if fileExists(&".tmp/{s}{fType}"):
        moveFile(&".tmp/{s}{fType}", file)
        calcDur(file)
        files.add([target, &"{ns}{fType}", structure])
    fType = ".mp3"

if fileExists("setup"):
  let operations = readFile("setup").splitLines
  for i in 0 .. operations.len - 1:
    if operations[i].len > 0:
      var oD: seq[string]
      let oLine = operations[i].split('.')
      for j in 0 .. oLine.len - 1:
        oD.add(oLine[j])
      move(oD[0], oD[1], oD[2], oD[3], oD[4])

if dirExists(".tmp"):
  removeDir(".tmp")

for i in 0 .. files.len - 1:
  var match: string
  let target: string = files[i][0]
  if target[^1] == '/':
    if fileExists(&"{audioDir}{target}match"):
      match = readFile(&"{audioDir}{target}match") & "\n"

    let structures = files[i][2].split('|')
    for j in 0 .. structures.len - 1:
      let name: string = files[i][1]
      var zone: string = target.split('/')[0]
      if structures[j] != "null":
        zone = &"{zone}{structures[j]}"
      let line: string = &"{zone}|{target}{name}|DM DOKURO"
      if not match.contains(line):
        match = &"{match}{line}\n"
    match = match[0 .. ^2]
    writeFile(&"{audioDir}{target}match", match)

