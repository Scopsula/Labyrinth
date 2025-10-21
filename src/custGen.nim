import random, strutils

var items: bool
if readFile("../data/config").splitLines[5].split(' ')[1] == "true":
  items = true

proc cGen*(lv: int, n: int, t: array[2, int]): seq[array[2, int]] =
  var pos: array[2, int] = [0,0]
  var path: seq[array[2, int]]

  path.add(pos)
  case lv
  # Custom generation for level 1 may be removed
  of 1:
    for i in 1 .. n div 2:
      let d: array[2, int] = sample([[0, 1], [0,-1], [1,1], [1,-1]])
      for i in 1 .. rand(t[1] div 2 .. (t[0] - d[0] * t[1]) * 2):
        pos[d[0]] += d[1]
        path.add(pos)
    return path
  # Work in progress
  of 2:
    for i in 1 .. n div ((t[0] + t[1]) div 2):
      let d: array[2, int] = sample([[0, 1], [0,-1], [1,1], [1,-1]])
      for i in 1 .. rand(1 .. (t[0] - d[0] * t[1]) * t[1]):
        pos[d[0]] += d[1]
        path.add(pos)
    return path
  else:
    return @[]

proc iGen*(lv: int, p: seq[array[2, int]], m: string, s: array[5, int]): string =
  var map: string = m
  if items == true:
    for i in 0 .. p.len - 1:
      var mP: int
      mP += p[i][0] - s[0]
      mP += (p[i][1] - s[1]) * (s[4] + 1)
      let iRan: int = rand(1 .. (100 * s[3] * s[2]))
      if iRan == 1:
        map[mP] = 'F'
      elif iRan <= 3:
        map[mP] = 'B'
      elif iRan <= 10:
        map[mP] = 'A'
      else:
        map[mP] = '*'
    return map
  return map
