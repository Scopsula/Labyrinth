import random

const 
  tX: int = 10
  tY: int = 5

randomize()

proc autoGenLv*(n: int) =
  var pos: array[2, int] = [0,0]
  var path: seq[array[2, int]]

  path.insert(pos)
  for i in 1 .. n:
    let dir: string = sample(["x+", "x-", "y+", "y-"])
    case dir
    of "x+":
      for x in 1 .. rand(1 .. tX):
        pos[0] += 1
        path.insert(pos)

    of "x-":
      for x in 1 .. rand(1 .. tX):
        pos[0] -= 1
        path.insert(pos)

    of "y+":
      for y in 1 .. rand(1 .. tY):
        pos[1] += 1
        path.insert(pos)

    of "y-":
      for y in 1 .. rand(1 .. tY):
        pos[1] -= 1
        path.insert(pos)

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

  var w1: string
  for i in 1 .. w:
    w1 = w1 & " "

  var map: string
  for i in 1 .. h:
    map = map & w1
    if i < h:
      map = map & "\n"

  for i in 0 .. path.len - 1:
    var mP: int
    mP += path[i][0] - sX
    mP += (path[i][1] - sY) * (w + 1)
    map[mP] = '*'

  writeFile("../loadedLevel/map", map)
