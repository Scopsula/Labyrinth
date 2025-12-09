import strutils, strformat, random, os
import custGen

proc refresh*(): bool =
  let level: string = readFile("../data/level")
  case level
  of "1": return true
  of "2": return true
  of "5": return true
  else: discard

let loot: string = readFile("../data/config").splitLines[5].split(' ')[1]

proc getSize(lv: int, t: array[2, int]): array[2, int] =
  case lv
  of 1:
    return [t[0] * t[1] + 1, t[1] * t[1]]
  of 5:
    return [(t[0] * t[1] div 5) + 1, t[0] + 1]
  else:
    discard

var rValues: seq[int]
proc audioZone*(xy: array[2, int], t: array[2, int], lv: int): string =
  if rValues.len > 0:
    let size: array[2, int] = getSize(lv, t)
    let nx: int = xy[0] div size[0]
    let ny: int = xy[1] div size[1]
    if rValues[nx + (ny * rValues[0]) + 1] == 1:
      return &"{lv}Halls"
    return &"{lv}"
  else:
    return &"{lv}"

var oD: seq[array[2, char]]
proc setRValues*(lv: int, s: array[4, int]) =
  rValues.setLen(0)
  oD.setLen(0)
  case lv
  of 1, 5:
    let size: array[2, int] = getSize(lv, [s[2], s[3]])
    let rX: int = s[1] div size[0]
    let rY: int = s[0] div size[1]
    let rSV: int = cEGen(lv, true).toInt
    rValues.add(rX)
    for i in 0 .. (rX + 1) * (rY + 1):
      if rand(rSV) == 0:
        rValues.add(1)
      else:
        rValues.add(0)
  else:
    discard

proc noCorner(nx: int, ny: int) =
  if (nx - 1) + ((ny - 1) * rValues[0]) + 1 > 0: # Up Left (min value)
    if (nx - 1) + (ny * rValues[0]) + 1 < rValues.len: # Left (max value)
      if rValues[(nx - 1) + ((ny - 1) * rValues[0]) + 1] == 1: # Up Left
        if rValues[(nx - 1) + (ny * rValues[0]) + 1] == 0: # Left
          if rValues[nx + ((ny - 1) * rValues[0]) + 1] == 0: # Up
            rValues[(nx - 1) + ((ny - 1) * rValues[0]) + 1] = 0 # Up Left

  if nx + ((ny - 1) * rValues[0]) + 1 > 0: # Up (min value)
    if (nx + 1) + (ny * rValues[0]) + 1 < rValues.len: # Right (max value) 
      if rValues[(nx + 1) + ((ny - 1) * rValues[0]) + 1] == 1: # Up Right
        if rValues[(nx + 1) + (ny * rValues[0]) + 1] == 0: # Right
          if rValues[nx + ((ny - 1) * rValues[0]) + 1] == 0: # Up
            rValues[(nx + 1) + ((ny - 1) * rValues[0]) + 1] = 0 # Up Right

  if (nx - 1) + (ny * rValues[0]) + 1 > 0: # Left (min value)
    if nx + ((ny + 1) * rValues[0]) + 1 < rValues.len: # Down (max value)
      if rValues[(nx - 1) + ((ny + 1) * rValues[0]) + 1] == 1: # Down Left
        if rValues[(nx - 1) + (ny * rValues[0]) + 1] == 0: # Left
          if rValues[nx + ((ny + 1) * rValues[0]) + 1] == 0: # Down
            rValues[(nx - 1) + ((ny + 1) * rValues[0]) + 1] = 0 # Down Left

  if (nx + 1) + (ny * rValues[0]) + 1 > 0: # Right (min value)
    if (nx + 1) + ((ny + 1) * rValues[0]) + 1 < rValues.len: # Down Right (max value)
      if rValues[(nx + 1) + ((ny + 1) * rValues[0]) + 1] == 1: # Down Right
        if rValues[(nx + 1) + (ny * rValues[0]) + 1] == 0: # Right
          if rValues[nx + ((ny + 1) * rValues[0]) + 1] == 0: # Down
            rValues[(nx + 1) + ((ny + 1) * rValues[0]) + 1] = 0 # Down Right

var zton: string = ")!@#$%^&*("
proc adjustVisible*(v: string, xy: array[2, int], level: int, mS: array[2, string], t: array[2, int]): array[2, string] =
  var visible: string = v 
  var map = mS[1]
  var rows = v.splitLines
  let lw = rows[0].len
  var coords: array[2, int]

  proc setCoords(): array[2, int] =
    for y in 0 .. rows.len - 1:
      for x in 0 .. lw - 1:
        if rows[y][x] == 'S':
          return [x, y]

  proc writeMap(n: seq[char], coords: array[2, int]) =
    let mW = mS[0].parseInt
    for y in 1 .. rows.len - 2:
      for x in 1 .. lw - 2:
        let uC: char = visible[y * (lw + 1) + x]
        if n.contains(uC):
          let wx: int = xy[0] - coords[0] + x
          let wy: int = xy[1] - coords[1] + y
          map[wy * mW + wx] = uC

  proc ceilings(y: int, x: int, c: char, tW: bool) =
    var incr: int = 0
    let c1: char = rows[y][x]
    let c2: char = visible[y * (lw + 1) + x]
    var clear: bool = false
    if c1 == c or c2 == c:
      clear = true
    if c1 == ' ' and c2 == ' ':
      clear = true
    if clear == true:
      var r = v.replace(c, ' ').splitLines
      if r[y + 1][x] == ' ':
        if y == r.len - 2:
          incr += 1
        elif r[y + 2][x] != ' ':
          incr += 1
        if r[y][x - 1] != ' ' or r[y + 1][x - 1] != ' ':
          incr += 2
        if r[y][x + 1] != ' ' or r[y + 1][x + 1] != ' ':
          incr += 4
        if rows[y - 1][x] != ' ':
          incr += 8
        let c = "abcdefghijklmnop"[incr]
        visible[y * (lw + 1) + x] = c
      elif r[y - 1][x] != ' ' and tW == true:
        if r[y][x - 1] != ' ': 
          visible[y * (lw + 1) + x] = '0'
          if r[y][x + 1] != ' ':
            visible[y * (lw + 1) + x] = '3'
        elif r[y][x + 1] != ' ': 
          visible[y * (lw + 1) + x] = '1'
        else: 
          visible[y * (lw + 1) + x] = '2'
      elif r[y + 1][x] != ' ' and tW == true:
        if r[y][x - 1] != ' ': 
          visible[y * (lw + 1) + x] = '4'
          if r[y][x + 1] != ' ':
            visible[y * (lw + 1) + x] = '6'
        elif r[y][x + 1] != ' ': 
          visible[y * (lw + 1) + x] = '5'

  proc corridors(y: int, x: int, r3e: bool) =
    if rows[y][x] == ' ':
      var incr: int = 0
      if rows[y + 1][x] != ' ':
        incr += 1
      if rows[y][x - 1] != ' ':
        incr += 2
      if rows[y][x + 1] != ' ':
        incr += 4
      if rows[y - 1][x] != ' ':
        incr += 8
      if incr == 0:
        if rows[y + 1][x - 1] != ' ':
          incr = 16 
        elif rows[y + 1][x + 1] != ' ':
          incr = 17
        elif rows[y - 1][x - 1] != ' ':
          incr = 18
        elif rows[y - 1][x + 1] != ' ':
          incr = 19
      let c = "abcdefghijklmnopqrst"[incr]
      if r3e == true:
        case c
        of 'g', 'h', 'j', 'l', 'n', 'o', 'p':
          visible[y * (lw + 1) + x] = '*'
        else:
          visible[y * (lw + 1) + x] = c
      else:
        visible[y * (lw + 1) + x] = c

  proc halls(y: int, x: int, s: array[2, int], c: array[3, char], nC: array[2, bool]): bool =
    if rows[y][x] == ' ' or rows[y][x] == c[2] or c[0] != ' ':
      var nx: int = (xy[0] - coords[0] + x) div s[0]
      var ny: int = (xy[1] - coords[1] + y) div s[1]
      if rValues[nx + (ny * rValues[0]) + 1] == 1:
        if nC[0] == true:
          noCorner(nx, ny)
        let cx: int = xy[0] - coords[0] + x - (nx * s[0])
        let cy: int = xy[1] - coords[1] + y - (ny * s[1])
        if cx mod 2 == 0 or cy mod 2 == 0:
          if rows[y][x] == ' ' or rows[y][x] == c[2]:
            if c[1] != ' ' and loot == "true" and rand(1 .. 500) == 1:
              visible[y * (lw + 1) + x] = c[1]
            else:
              visible[y * (lw + 1) + x] = '*'
        else:
          if nC[1] == true:
            if rows[y][x] == ' ':
              visible[y * (lw + 1) + x] = c[0]
          else:
            visible[y * (lw + 1) + x] = c[0]
        return true
    return false

  proc delHalls(s: array[2, int], doLink: bool) =
    var dV: seq[int]
    var kV: seq[int]
    var link: seq[int]
    let l = rValues.len - 1
    proc linkHalls(n: int) =
      for i in 1 .. l:
        if n + i > l:
          break
        if rValues[n + i] == 1:
          if not kV.contains(n + i):
            kV.add(n + i)
            link.add(n + i)
        else:
          break
      for i in 1 .. l:
        if n - i < 0:
          break
        if rValues[n - i] == 1:
          if not kV.contains(n - i):
            kV.add(n - i)
            link.add(n - i)
        else:
          break
      for i in 1 .. l:
        if n + (i * rValues[0]) > l:
          break
        if rValues[n + (i * rValues[0])] == 1:
          if not kV.contains(n + (i * rValues[0])):
            kV.add(n + (i * rValues[0]))
            link.add(n + (i * rValues[0]))
        else:
          break
      for i in 1 .. l:
        if n - (i * rValues[0]) < 0:
          break
        if rValues[n - (i * rValues[0])] == 1:
          if not kv.contains(n - (i * rValues[0])):
            kV.add(n - (i * rValues[0]))
            link.add(n - (i * rValues[0]))
        else:
          break

    for y in 1 .. rows.len - 2:
      for x in 1 .. lw - 2:
        let nx: int = (xy[0] - coords[0] + x) div s[0]
        let ny: int = (xy[1] - coords[1] + y) div s[1]
        let n: int = nx + (ny * rValues[0]) + 1
        if rValues[n] == 1:
          if not dV.contains(n):
            dV.add(n)
          if rows[y][x] != ' ':
            if not kV.contains(n):
              kV.add(n)
              if doLink == true:
                link.setLen(0)
                link.add(n)
                while true:
                  let ll: int = link.len
                  for i in 0 .. link.len - 1:
                    linkHalls(link[i])
                  if ll == link.len:
                    break

    for i in 0 .. kV.len - 1:
      if dV.contains(kV[i]):
        let d: int = find(dV, kV[i])
        dV.del(d)
    for i in 0 .. dV.len - 1:
      rValues[dV[i]] = 0

  proc overlayWall(y: int, x: int, d: char) =
    if rows[y][x] == d:
      var oW: bool = false
      if visible[y * (lw + 1) + x - 1] == '*':
        oW = true
      elif visible[y * (lw + 1) + x + 1] == '*':
        oW = true
      elif visible[(y - 1) * (lw + 1) + x] == '*':
        oW = true
      if oW == true:
        visible[y * (lw + 1) + x] = ' '
        ceilings(y, x, d, true)

  proc overlay(y: int, x: int, d: char, oD: seq[array[2, char]], target: string) =
    if rows[y][x] == d or visible[y * (lw + 1) + x] == d:
      let c: char = visible[y * (lw + 1) + x]
      var nC: char
      for i in 0 .. oD.len - 1:
        if c == oD[i][0]:
          nC = oD[i][1]
          break
      if not fileExists(&"../data/chars/temp/{nC}"):
        var tile: string
        let match: seq[string] = readFile(&"../data/chars/{level}/match").splitLines
        for i in 0 .. match.len - 1:
          if match[i][0] == c:
            let selTile = match[i].split(' ')[1]
            tile = readFile(&"../data/chars/{level}/{selTile}")
            break
        let tg = readFile(&"../data/chars/{target}")
        for i in 0 .. tg.len - 1:
          if tg[i] != ' ':
            if tg[i] == 'X':
              tile[i] = ' '
            else:
              tile[i] = tg[i]
        writeFile(&"../data/chars/temp/{nC}", tile)
      visible[y * (lw + 1) + x] = nC

  case level
  of 0:
    for y in 1 .. rows.len - 2:
      for x in 1 .. lw - 2:
        ceilings(y, x, ' ', true)

  of 1:
    coords = setCoords()
    let size = getSize(level, [t[0], t[1]])
    delHalls(size, true)
    for y in 1 .. rows.len - 2:
      for x in 1 .. lw - 2:
        if halls(y, x, size, [' ', 'R', ' '], [true, false]) == false:
          corridors(y, x, false)
    writeMap(@['*', 'R'], coords)

  of 2:
    for y in 1 .. rows.len - 2:
      for x in 1 .. lw - 2:
        corridors(y, x, true)
    writeMap(@['*'], setCoords())

  of 4:
    for y in 1 .. rows.len - 2:
      for x in 1 .. lw - 2:
        ceilings(y, x, 'W', true)
        if oD.len == 0:
          oD.add(['W', '`'])
          for i in 0 .. 9:
            let c = &"{i}"
            oD.add([c[0], zton[i]])
        overlay(y, x, 'W', oD, "window")

  of 5:
    coords = setCoords()
    let size = getSize(level, [t[0], t[1]])
    delHalls(size, false)
    for y in 1 .. rows.len - 2:
      for x in 1 .. lw - 2:
        if halls(y, x, size, ['P', ' ', 'D'], [true, false]) == false:
          ceilings(y, x, 'D', true)
          overlayWall(y, x, 'D')
    writeMap(@['*', 'P', ' '], coords)

  else: discard
  return [visible, map]

