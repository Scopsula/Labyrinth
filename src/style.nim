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
let doRValuesStr: string = readFile("../data/config").splitLines[11].split(' ')[1]
var doRValues: bool = false
if doRValuesStr == "true":
  doRValues = true

var rValues: seq[int]
proc audioZone*(xy: array[2, int], t: array[2, int], lv: int): string =
  case lv
  of 1:
    let nx: string = &"{(xy[0] + 1) div (t[0] * t[1] + 1)}"
    let ny: string = &"{xy[1] div (t[1] * t[1])}"
    if doRValues == false:
      if "13579".contains(nx[^1]) and "13579".contains(ny[^1]):
        return "halls"
    else:
      let nx: string = &"{xy[0] div (t[0] * t[1] + 1)}"
      if rValues[nx.parseInt + (ny.parseInt * rValues[0]) + 1] == 1:
        return "halls"
    return "1"
  else:
    return &"{lv}"

proc getSize(lv: int, t: array[2, int]): array[2, int] =
  case lv
  of 1:
    return [t[0] * t[1] + 1, t[1] * t[1]]
  of 5:
    return [(t[0] * t[1] div 5) + 1, t[0] + 1]
  else:
    discard

var styleData: seq[string]
proc setRValues*(lv: int, s: array[4, int]) =
  if fileExists(&"../data/style/{lv}"):
    styleData = readFile(&"../data/style/{lv}").splitLines
  rValues.setLen(0)
  if doRValues == true:
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

  proc writeMap(n: array[2, char], coords: array[2, int]) =
    let mW = mS[0].parseInt
    for y in 1 .. rows.len - 2:
      for x in 1 .. lw - 2:
        let uC: char = visible[y * (lw + 1) + x]
        if uC == n[0] or uC == n[1]:
          let wx: int = xy[0] - coords[0] + x
          let wy: int = xy[1] - coords[1] + y
          map[wy * mW + wx] = uC

  proc ceilings(y: int, x: int, tW: bool) =
    var incr: int = 0
    if rows[y][x] == ' ' and visible[y * (lw + 1) + x] == ' ':
      if rows[y + 1][x] == ' ':
        if y == rows.len - 2:
          incr += 1
        elif rows[y + 2][x] != ' ':
          incr += 1
        if rows[y][x - 1] != ' ' or rows[y + 1][x - 1] != ' ':
          incr += 2
        if rows[y][x + 1] != ' ' or rows[y + 1][x + 1] != ' ':
          incr += 4
        if rows[y - 1][x] != ' ':
          incr += 8
        let c = "abcdefghijklmnop"[incr]
        visible[y * (lw + 1) + x] = c
      elif rows[y - 1][x] != ' ' and tW == true:
        if rows[y][x - 1] != ' ': 
          visible[y * (lw + 1) + x] = '0'
          if rows[y][x + 1] != ' ':
            visible[y * (lw + 1) + x] = '3'
        elif rows[y][x + 1] != ' ': 
          visible[y * (lw + 1) + x] = '1'
        else: 
          visible[y * (lw + 1) + x] = '2'
      elif rows[y + 1][x] != ' ' and tW == true:
        if rows[y][x - 1] != ' ': 
          visible[y * (lw + 1) + x] = '4'
          if rows[y][x + 1] != ' ':
            visible[y * (lw + 1) + x] = '6'
        elif rows[y][x + 1] != ' ': 
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

  proc halls(y: int, x: int, s: array[2, int], c: array[2, char], nC: array[2, bool]): bool =
    if rows[y][x] == ' ' or c[0] != ' ':
      if doRValues == false:
        let nx: string = &"{(xy[0] - coords[0] + x + 1) div s[0]}"
        let ny: string = &"{(xy[1] - coords[1] + y) div s[1]}"
        if "13579".contains(nx[^1]) and "13579".contains(ny[^1]):
          let cx: string = &"{xy[0] - coords[0] + x}"
          let cy: string = &"{xy[1] - coords[1] + y}"
          if not "13579".contains(cx[^1]) or not "02468".contains(cy[^1]):
            if rows[y][x] == ' ':
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
          return false
      else:
        var nx: int = (xy[0] - coords[0] + x) div s[0]
        var ny: int = (xy[1] - coords[1] + y) div s[1]
        if rValues[nx + (ny * rValues[0]) + 1] == 1:
          if nC[0] == true:
            noCorner(nx, ny)
          let cx: int = xy[0] - coords[0] + x - (nx * s[0])
          let cy: int = xy[1] - coords[1] + y - (ny * s[1])
          if cx mod 2 == 0 or cy mod 2 == 0:
            if rows[y][x] == ' ':
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
          return false
    return true

  case level
  of 0:
    for y in 1 .. rows.len - 2:
      for x in 1 .. lw - 2:
        ceilings(y, x, true)

  of 5:
    coords = setCoords()
    for y in 1 .. rows.len - 2:
      for x in 1 .. lw - 2:
        if halls(y, x, getSize(level, [t[0], t[1]]), ['P', ' '], [true, false]) == true:
          ceilings(y, x, true)
    writeMap(['*', 'P'], coords)

  of 1:
    coords = setCoords()
    for y in 1 .. rows.len - 2:
      for x in 1 .. lw - 2:
        if halls(y, x, getSize(level, [t[0], t[1]]), [' ', 'R'], [true, false]) == true:
          corridors(y, x, false)
    writeMap(['*', 'R'], coords)

  of 2:
    for y in 1 .. rows.len - 2:
      for x in 1 .. lw - 2:
        corridors(y, x, true)
    writeMap(['*', '*'], setCoords())

  of 4:
    for y in 1 .. rows.len - 2:
      for x in 1 .. lw - 2:
        var incr: int = 0
        let c1: char = rows[y][x]
        let c2: char = visible[y * (lw + 1) + x]
        var clear: bool = false
        if c1 == 'W' or c2 == 'W':
          clear = true
        if c1 == ' ' and c2 == ' ':
          clear = true
        if clear == true:
          var r = v.replace('W', ' ').splitLines
          if r[y + 1][x] == ' ' :
            if y == r.len - 2:
              incr += 1
            elif r[y + 2][x] != ' ':
              incr += 1
            if r[y][x - 1] != ' ' or r[y + 1][x - 1] != ' ':
              incr += 2
            if r[y][x + 1] != ' ' or r[y + 1][x + 1] != ' ':
              incr += 4
            if r[y - 1][x] != ' ':
              incr += 8
            let c = "abcdefghijklmnop"[incr]
            visible[y * (lw + 1) + x] = c
          elif r[y - 1][x] != ' ':
            if r[y][x - 1] != ' ': 
              visible[y * (lw + 1) + x] = '0'
              if r[y][x + 1] != ' ':
                visible[y * (lw + 1) + x] = '3'
            elif r[y][x + 1] != ' ': 
              visible[y * (lw + 1) + x] = '1'
            else: 
              visible[y * (lw + 1) + x] = '2'
          elif r[y + 1][x] != ' ':
            if r[y][x - 1] != ' ': 
              visible[y * (lw + 1) + x] = '4'
              if r[y][x + 1] != ' ':
                visible[y * (lw + 1) + x] = '6'
            elif r[y][x + 1] != ' ': 
              visible[y * (lw + 1) + x] = '5'
        if c1 == 'W' or c2 == 'W':
          let c: char = visible[y * (lw + 1) + x]
          var nC: char
          case c
          of 'W': nC = '`'
          of '0': nC = ')'
          of '1': nC = '!'
          of '2': nC = '@'
          of '3': nC = '#'
          of '4': nC = '$'
          of '5': nC = '%'
          of '6': nC = '^'
          of '7': nC = '&'
          of '8': nC = '+'
          of '9': nC = '-'
          else: discard
          if not fileExists(&"../data/chars/temp/{nC}"):
            var tile: string
            let match: seq[string] = readFile(&"../data/chars/{level}/match").splitLines
            for i in 0 .. match.len - 1:
              if match[i][0] == c:
                let selTile = match[i].split(' ')[1]
                tile = readFile(&"../data/chars/{level}/{selTile}")
                break
            let window = readFile(&"../data/chars/window")
            for i in 0 .. window.len - 1:
              if window[i] != ' ':
                if window[i] == 'X':
                  tile[i] = ' '
                else:
                  tile[i] = window[i]
            writeFile(&"../data/chars/temp/{nC}", tile)
          visible[y * (lw + 1) + x] = nC
  else: discard
  return [visible, map]

