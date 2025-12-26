import random, strutils, os

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
    for i in 1 .. n div 2 + 1:
      let d: array[2, int] = sample([[0, 1], [0,-1], [1,1], [1,-1]])
      for i in 1 .. rand(t[1] div 2 .. (t[0] - d[0] * t[1]) * 2):
        pos[d[0]] += d[1]
        path.add(pos)
    return path

  of "2":
    for i in 1 .. n div ((t[0] + t[1]) div 2) + 1:
      let d: array[2, int] = sample([[0, 1], [0,-1], [1,1], [1,-1]])
      for i in 1 .. rand(1 .. (t[0] - d[0] * t[1]) * t[1]):
        pos[d[0]] += d[1]
        path.add(pos)
    return path

  of "3":
    var nV: bool
    var nC: int = 1
    if fileExists("../data/levels/3"):
      let data = readFile("../data/levels/3").splitLines
      for i in 0 .. data.len - 1:
        let dLine = data[i].split('.')
        if dLine[0] == "nV":
          if dLine[1] == "true":
            nV = true
          nC = dLine[2].parseInt

    var doNot: array[4, seq[seq[int]]]
    special.setLen(0)
    proc inSec() =
      var iPath: seq[array[2, int]]
      var iPos = pos
      for y in 0 .. 9:
        iPos[1] = pos[1] + y
        for x in 0 .. 18:
          iPos[0] = pos[0] + x

          var cIpos = iPos
          var useI: array[2, int]
          for i in 0 .. 1:
            if iPos[i] >= 0:
              useI[i] = i
              if doNot[i].len <= iPos[i]:
                doNot[i].setLen(iPos[i] + 2)

            if iPos[i] < 0:
              cIpos[i] = cIpos[i] * -1
              useI[i] = i + 2
              if doNot[i + 2].len <= -1 * iPos[i]:
                doNot[i + 2].setLen(-1 * iPos[i] + 2)

          if y == 0: 
            if cIpos[1] - 1 == -1:
              useI[1] += 2
              cIpos[1] = 2
            if doNot[useI[1]].len <= cIpos[1] - 1:
              doNot[useI[1]].setLen(cIpos[1] + 2) 
            doNot[useI[1]][cIPos[1] - 1].add(cIpos[0])
            doNot[useI[0]][cIPos[0]].add(cIpos[1] - 1)
            if cIpos[1] - 1 < 0:
              useI[1] -= 2
              cIpos[1] = 0

          if y == 9:
            if doNot[useI[1]].len <= cIpos[1] + 1:
              doNot[useI[1]].setLen(cIpos[1] + 2)
            doNot[useI[1]][cIPos[1] + 1].add(cIpos[0])
            doNot[useI[0]][cIPos[0]].add(cIpos[1] + 1)

          if x == 0: 
            if cIpos[0] - 1 == -1:
              useI[0] += 2
              cIpos[0] = 2
            if doNot[useI[0]].len <= cIpos[0] - 1:
              doNot[useI[0]].setLen(cIpos[0] + 2) 
            doNot[useI[1]][cIPos[1]].add(cIpos[0] - 1)
            doNot[useI[0]][cIPos[0] - 1].add(cIpos[1])
            if cIpos[0] - 1 < 0:
              useI[0] -= 2
              cIpos[0] = 0

          if x == 9:
            if doNot[useI[0]].len <= cIpos[0] + 1:
              doNot[useI[0]].setLen(cIpos[0] + 2)
            doNot[useI[1]][cIPos[1]].add(cIpos[0] + 1)
            doNot[useI[0]][cIPos[0] + 1].add(cIpos[1])

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
      var bPath: seq[array[2, int]]
      var bPos = pos
      for y in -2 .. 11:
        bPos[1] = pos[1] + y
        for x in -2 .. 20:
          bPos[0] = pos[0] + x
          if y != -1 and y != 10:
            if x != -1 and x != 19:
              bPath.add(bPos)
          if y == -2 or y == 11:
            bPath.add(bPos)
          if x == -2 or x == 20:
            bPath.add(bPos)

      path.add(bPath)

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
      var dd: int
      if nV == true:
        dd = sample([t[0], t[1]])
      else:
        dd = rand(t[1] .. (t[0] - d[0] * t[1]))
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
      if nC > 0 and i > 1:
        if rand(1 .. t[0] * t[1] * nC) == 1:
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

