import os, random, strutils, strformat
import terminal

var 
  w: int = terminalWidth()
  h: int = terminalHeight()
  tX: int = 10
  tY: int = 5

w = w div tX * tX
h = h div tY * tY

var 
  cMap: string
  xC: int = 0
  yC: int = 0

proc cDMap() =
  cMap = ""
  let nY: int = h div tY + yC
  let nX: int = w div tX + xC 
  for y in 1 .. nY:
    for x in 1 .. nX:
      cMap = cMap & " "
    if y < nY:
      cMap = cMap & "\n"

proc reWrite(oMap: seq[string], d: int, i: int) =
    var c2Map: seq[string] = cMap.splitLines()
    for y in 0 .. oMap.len - 1:
      for x in 0 .. oMap[y].len - 1:
        if oMap[y][x] == '*':
          c2Map[y + i][x + d] = '*'
    cMap = ""
    for y in 0 .. c2Map.len - 1:
      for x in 0 .. c2Map[y].len - 1:
        cMap = &"{cMap}{c2Map[y][x]}"
      if y < c2Map.len - 1:
        cMap = cMap & "\n"

echo "Level Number:"
let lNum: string = readLine(stdin)
writeFile("../loadedLevel/level", lNum)

echo "Map Iterations:"
let n: int = readLine(stdin).parseInt

var llimit: bool = false
echo "Limit lines to terminalWidth?: [y/n]"
let ll: string = readLine(stdin)
if ll.toUpper == "Y": llimit = true

var pos: int = 0
var pY: int = 0

cDMap()
randomize()
for i in 1 .. n:
  var dir: string = sample(["x+", "x-", "y+", "y-"])
  case dir
  of "x+":
    for x in 1 .. rand(1 .. tX):
      pos += 1
      if pos - pY * (w div tX + xC + 1) >= w div tX + xC:
        if w div tX + xC >= w and llimit == true: 
          pos -= 1
          break
        let oMap = cMap.splitLines()
        xC += 1
        pos += pY
        cDMap()
        reWrite(oMap, 0, 0)
      cMap[pos - 1] = '*'

  of "x-":
    for x in 1 .. rand(1 .. tX):
      pos -= 1
      if pos - pY * (w div tX + xC + 1) < 0:
        if w div tX + xC >= w and llimit == true: 
          pos += 1
          break
        let oMap = cMap.splitLines()
        xC += 1
        pos += pY + 1 
        cDMap()
        reWrite(oMap, 1, 0)
      cMap[pos + 1] = '*'

  of "y+":
    for y in 1 .. rand(1 .. tY):
      pos += w div tX + xC + 1
      pY += 1
      if pos >= cMap.len:
        let oMap: string = cMap
        yC += 1
        cDMap()
        for i in 0 .. oMap.len - 1:
          if oMap[i] == '*': cMap[i] = '*'
      cMap[pos - w div tX - xC - 1] = '*'

  of "y-":
    for y in 1 .. rand(1 .. tY):
      pos -= w div tX + xC + 1
      pY -= 1
      if pos < 0:
        let oMap: seq[string] = cMap.splitLines()
        yC += 1
        pY += 1
        pos += w div tX + xC + 1
        cDMap()
        reWrite(oMap, 0, 1)
      cMap[pos + w div tX + xC + 1] = '*'

  discard execShellCmd("clear")
  echo cMap
  echo i, "/", n

writeFile("../loadedLevel/map", cMap)

