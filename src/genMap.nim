import random, strutils, strformat, times

const
  tX: int = 10
  tY: int = 5

echo "Map Iterations:"
let n: int = readLine(stdin).parseInt

var
  pos: array[2, int] = [0,0]
  path: seq[array[2, int]]

randomize()
path.add(pos)
echo "\nGenerating path coordinates"
var time = cpuTime()
for i in 1 .. n:
  let d: array[2, int] = sample([[0, 1], [0,-1], [1,1], [1,-1]])
  for i in 1 .. rand(tX - d[0] * tY):
    pos[d[0]] += d[1]
    path.add(pos)
echo &"{n} Iterations - {cpuTime() - time}s\n"

var
  sX: int = 0
  gX: int = 0
  sY: int = 0
  gY: int = 0

echo "Calculating min/max coordinates"
let pLen = path.len
time = cpuTime()
for i in 0 .. pLen - 1:
  if path[i][0] < sX: sX = path[i][0]
  if path[i][0] > gX: gX = path[i][0]
  if path[i][1] < sY: sY = path[i][1]
  if path[i][1] > gY: gY = path[i][1]
echo &"{pLen} Path Len - {cpuTime() - time}s\n" 

let w: int = gX - sX + 1
let h: int = gY - sY + 1
let g: int = n div h + 1

echo "Creating blank map"
time = cpuTime()
var w1: string
for i in 1 .. w:
  w1 = w1 & " "

var w2: string
for i in 1 .. g:
  w2 = w2 & w1 & "\n"

var map: string
for i in 1 .. h div g:
  map = map & w2

var m1: string
if h - (h div g) * g > 0:
  for i in 1 .. h - (h div g) * g:
    m1 = m1 & w1 & "\n"

map = map & m1
echo &"{w} Width - {h} Height - {cpuTime() - time}s\n" 

echo "Writing paths to map"
time = cpuTime()
for i in 0 .. pLen - 1:
  var mP: int
  mP += path[i][0] - sX
  mP += (path[i][1] - sY) * (w + 1)
  map[mP] = '*'
echo &"{pLen} Path Len - {cpuTime() - time}s\n" 

writeFile("../loadedLevel/map", map)
echo "Map written to ../loadedLevel/map"

