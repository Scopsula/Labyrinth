import random, strutils

var items: bool
if readFile("../data/config").splitLines[5].split(' ')[1] == "true":
  items = true

proc cGen*(n: int, t: array[2, int]): seq[array[2, int]] =
  var lv = readFile("../data/level").splitLines[0]
  var pos: array[2, int] = [0,0]
  var path: seq[array[2, int]]

  path.add(pos)
  case lv
  of "1":
    for i in 1 .. n div 2:
      let d: array[2, int] = sample([[0, 1], [0,-1], [1,1], [1,-1]])
      for i in 1 .. rand(t[1] div 2 .. (t[0] - d[0] * t[1]) * 2):
        pos[d[0]] += d[1]
        path.add(pos)
    return path
  of "2":
    for i in 1 .. n div ((t[0] + t[1]) div 2):
      let d: array[2, int] = sample([[0, 1], [0,-1], [1,1], [1,-1]])
      for i in 1 .. rand(1 .. (t[0] - d[0] * t[1]) * t[1]):
        pos[d[0]] += d[1]
        path.add(pos)
    return path
  of "3":
    proc doW(selW: int, d: array[2, int]) =
      var oD: int = d[0] - 1
      if oD == -1: oD = 1
      var tPos = pos
      tPos[oD] -= 1 + (selW div 2)
      while tPos[oD] < pos[oD] + selW div 2:
        tPos[oD] += 1
        path.add(tPos)
    for i in 1 .. n:
      let selW: int = rand(1 .. 100) div 30
      let d: array[2, int] = sample([[0, 1], [0,-1], [1,1], [1,-1]])
      for i in 1 .. rand(t[1] .. (t[0] - d[0] * t[1])):
        if i == 1: doW(selW, d)
        pos[d[0]] += d[1]
        doW(selW, d)
    return path
  of "4":
    for i in 1 .. n * rand(1 .. t[0]):
      let d: array[2, int] = sample([[0, 1], [0,-1], [1,1], [1,-1]])
      for i in 1 .. (t[0] - d[0] * t[1]) div t[1]:
        pos[d[0]] += d[1]
        path.add(pos)
    return path
  of "5":
    var c4: int = 0
    var rX: int = sample([t[0], t[1]])
    var rY: int = sample([t[0], t[1]])
    for i in 1 .. n:
      if rand(t[0] * t[1]) == 0:
        rX = sample([t[0], t[1]])
        rY = sample([t[0], t[1]])
      c4 += 1
      case c4
      of 1:
        for i in 1 .. rX:
          pos[0] += 1
          path.add(pos)
      of 2:
        for i in 1 .. rY:
          pos[1] += 1
          path.add(pos)
      of 3:
        for i in 1 .. rX:
          pos[0] -= 1
          path.add(pos)
      of 4:
        for i in 1 .. rY:
          pos[1] -= 1
          path.add(pos)
      else:
        var rCV: int = 0
        if rand(t[0] * t[1]) == 0:
          rCV = sample([rX, rY])
        for i in 0 .. rand(rCV):
          case rand(3)
          of 0:
            for i in 1 .. rX:
              pos[0] += 1
              path.add(pos)
          of 1:
            for i in 1 .. rY:
              pos[1] += 1
              path.add(pos)
          of 2:
            for i in 1 .. rX:
              pos[0] -= 1
              path.add(pos)
          of 3:
            for i in 1 .. rY:
              pos[1] -= 1
              path.add(pos)
          else: discard
        c4 = 0
    return path
  of "8":
    for i in 1 .. n * rand(t[1] .. t[0]):
      pos[rand(1)] += rand(-1 .. 1)
      path.add(pos)
    return path
  else:
    return @[]

proc iGen*(p: seq[array[2, int]], m: string, s: array[5, int]): string =
  var lv = readFile("../data/level").splitLines[0]
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
  case lv
  of "4":
    for i in 0 .. p.len - 1:
      var mP: int
      mP += p[i][0] - s[0]
      mP += (p[i][1] - s[1]) * (s[4] + 1)
      if items == false:
        map[mP] = '*'
      if mP - (s[4] + 1) >= 0:
        if map[mP - (s[4] + 1)] == ' ': 
          if rand(1 .. s[2]) == 1:
            map[mP - (s[4] + 1)] = 'W'
  of "5":
    for i in 0 .. p.len - 1:
      var mP: int
      mP += p[i][0] - s[0]
      mP += (p[i][1] - s[1]) * (s[4] + 1)
      if items == false:
        map[mP] = '*'
      if mP + 1 < map.len:
        if mP - 1 - (s[4] + 1) >= 0:
          if map[mP - (s[4] + 1)] == ' ':
            if map[mP - 1 - (s[4] + 1)] != 'D' and map[mP + 1 - (s[4] + 1)] != 'D':
              if map[mP - 1 - (s[4] + 1)] != '*' and map[mP + 1 - (s[4] + 1)] != '*':
                if rand(1 .. s[2]) == 1:
                  map[mP - (s[4] + 1)] = 'D'
  return map

