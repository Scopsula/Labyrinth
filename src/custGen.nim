import random, strutils, sequtils

var items: bool
if readFile("../data/config").splitLines[5].split(' ')[1] == "true":
  items = true

var special: seq[array[2, int]]

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
    var doNot: array[4, seq[seq[int]]]
    special.setLen(0)
    proc inSec() =
      var iPath: seq[array[2, int]]
      var iPos = pos
      for y in 0 .. 9:
        iPos[1] = pos[1] + y
        for x in 0 .. 9:
          iPos[0] = pos[0] + x

          var cIpos = iPos
          var useI: array[2, int]
          for i in 0 .. 1:
            if iPos[i] >= 0:
              useI[i] = i
              if doNot[i].len <= iPos[i]:
                doNot[i].setLen(iPos[i] + 1)

            if iPos[i] < 0:
              cIpos[i] = cIpos[i] * -1
              useI[i] = i + 2
              if doNot[i + 2].len <= -1 * iPos[i]:
                doNot[i + 2].setLen(-1 * iPos[i] + 1)

          let v1 = doNot[useI[0]][cIpos[0]]
          let v2 = doNot[useI[1]][cIpos[1]]
          if v1.len < v2.len:
            if not v1.contains(cIpos[1]):
              iPath.add(ipos)
              doNot[useI[0]][cIPos[0]].add(cIpos[1])
          else:
            if not v2.contains(cIpos[0]):
              iPath.add(ipos)
              doNot[useI[1]][cIPos[1]].add(cIpos[0])           

      path.add(iPath)

      for i in 1 .. iPath.len:
        var s = sample(iPath)
        var sPath: seq[array[2, int]]
        while true:
          var cs: array[2, int]
          var stop: bool = false

          proc doStop(cc: array[2, int]) =
            if cc != [0, 0]:
              if sPath.contains([s[0] + cc[0], s[1]]):
                discard
              elif sPath.contains([s[0], s[1] + cc[1]]):
                discard
              elif not iPath.contains(cs):
                stop = true
            elif not iPath.contains(cs):
              stop = true
          
          cs = [s[0] - 1, s[1] + 1]
          doStop([-1, 1])
          cs = [s[0] + 1, s[1] + 1]
          doStop([1, 1])
          cs = [s[0] - 1, s[1] - 1]
          doStop([-1, -1])
          cs = [s[0] + 1, s[1] - 1]
          doStop([1, -1])
          cs = s

          for i in 0 .. 3:
            let d = [[0, 1], [0,-1], [1,1], [1,-1]][i]
            cs[d[0]] += d[1]
            if not sPath.contains(cs):
              doStop([0, 0])

          if stop == true:
            break

          if iPath.contains(s):
            iPath.del(find(iPath, s))
            special.add(s)
            sPath.add(s)

          let d: array[2, int] = sample([[0, 1], [0,-1], [1,1], [1,-1]])
          s[d[0]] += d[1]          

    proc doW(selW: int, d: array[2, int], fent: bool) =
      var con: int = 0
      var oD: int = d[0] - 1
      if oD == -1: oD = 1
      var tPos = pos
      proc mClear() =
        var dPos = tPos
        dPos[d[0]] -= 1
        for i in 0 .. 2:
          dPos[d[0]] += i
          path.add(dPos)

      tPos[oD] -= 1 + (selW div 2)
      while tPos[oD] < pos[oD] + selW div 2:
        tPos[oD] += 1
        if fent == false or rand((selW div 2) * 2) == 0:
          if fent == true:
            mClear()
          path.add(tPos)
          con -= 1
        con += 1
        if fent == true:
          if con == 2 * (selW div 2) + 1:
            mClear()

    for i in 1 .. n:
      let selW: int = rand(1 .. 100) div 30
      let d: array[2, int] = sample([[0, 1], [0,-1], [1,1], [1,-1]])
      let dd: int = rand(t[1] .. (t[0] - d[0] * t[1]))
      var cj: seq[int]
      for j in 1 .. dd:
        if j == 1: doW(selW, d, false)
        pos[d[0]] += d[1]
        var doFent: bool = false
        if not cj.contains(j - 1):
          if j < dd:
            if rand(3) == 3:
              doFent = true
              cj.add(j)
        doW(selW, d, doFent)
      if rand(1 .. t[0] * t[1]) == 1:
        inSec()
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
  of "3":
    if special.len > 0:
      for i in 0 .. p.len - 1:
        var mP: int
        mP += p[i][0] - s[0]
        mP += (p[i][1] - s[1]) * (s[4] + 1)
        if items == false:
          map[mP] = '*'

      for i in 0 .. special.len - 1:
        var doTheSpecial: int
        doTheSpecial += special[i][0] - s[0]
        doTheSpecial += (special[i][1] - s[1]) * (s[4] + 1)
        map[doTheSpecial] = 'Z'

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

