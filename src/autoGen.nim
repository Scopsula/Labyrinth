import random

const 
  tX: int = 10
  tY: int = 5

randomize()

proc autoGenLv*(n: int): seq[array[2, int]] =
  var pos: array[2, int] = [0,0]
  var path: seq[array[2, int]]

  path.add(pos)
  for i in 1 .. n:
    let d: array[2, int] = sample([[0, 1], [0,-1], [1,1], [1,-1]])
    for i in 1 .. rand(1 .. tX - d[0] * tY):
      pos[d[0]] += d[1]
      path.add(pos)

  var
    sX: int = 0
    gX: int = 0
    sY: int = 0
    gY: int = 0

  for i in 0 .. path.len - 1:
    if path[i][0] < sX: sX = path[i][0]
    if path[i][0] > gX: gX = path[i][0]
    if path[i][1] < sY: sY = path[i][1]
    if path[i][1] > gY: gY = path[i][1]
 
  let w: int = gX - sX + 1
  let h: int = gY - sY + 1
  let g: int = n div h + 1

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

  for i in 0 .. path.len - 1:
    var mP: int
    mP += path[i][0] - sX
    mP += (path[i][1] - sY) * (w + 1)
    map[mP] = '*'

  writeFile("../loadedLevel/map", map)
  path.insert([sX,sY])
  return path
