import strutils, strformat, random, os

proc refresh*(): bool =
  let level: string = readFile("../data/level")
  case level
  of "1": return true
  of "2": return true
  else: discard

let loot: string = readFile("../data/config").splitLines[5].split(' ')[1]

proc audioZone*(xy: array[2, int], t: array[2, int], lv: int): string =
  case lv
  of 1:
    let nx: string = &"{(xy[0] + 1) div (t[0] * t[1] + 1)}"
    let ny: string = &"{xy[1] div (t[1] * t[1])}"
    if "13579".contains(nx[^1]) and "13579".contains(ny[^1]):
      return "halls"
    else:
      return "1"
  else:
    return &"{lv}"

proc adjustVisible*(v: string, xy: array[2, int], level: int, mS: array[2, string], t: array[2, int]): array[2, string] =
  var visible: string = v 
  var map = mS[1]
  var rows = v.splitLines
  let lw = rows[0].len

  proc setCoords(): array[2, int] =
    for y in 0 .. rows.len - 1:
      for x in 0 .. lw - 1:
        if rows[y][x] == 'S':
          return [x, y]

  proc writeMap(n: char, coords: array[2, int]) =
    let mW = mS[0].parseInt
    for y in 1 .. rows.len - 2:
      for x in 1 .. lw - 2:
        let uC: char = visible[y * (lw + 1) + x]
        if uC == '*' or uC == n:
          let wx: int = xy[0] - coords[0] + x
          let wy: int = xy[1] - coords[1] + y
          map[wy * mW + wx] = uC

  case level
  of 0, 5:
    for y in 1 .. rows.len - 2:
      for x in 1 .. lw - 2:
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
          elif rows[y - 1][x] != ' ':
            if rows[y][x - 1] != ' ': 
              visible[y * (lw + 1) + x] = '0'
              if rows[y][x + 1] != ' ':
                visible[y * (lw + 1) + x] = '3'
            elif rows[y][x + 1] != ' ': 
              visible[y * (lw + 1) + x] = '1'
            else: 
              visible[y * (lw + 1) + x] = '2'
          elif rows[y + 1][x] != ' ':
            if rows[y][x - 1] != ' ': 
              visible[y * (lw + 1) + x] = '4'
              if rows[y][x + 1] != ' ':
                visible[y * (lw + 1) + x] = '6'
            elif rows[y][x + 1] != ' ': 
              visible[y * (lw + 1) + x] = '5'

  of 1:
    var coords: array[2, int] = setCoords() 

    for y in 1 .. rows.len - 2:
      for x in 1 .. lw - 2:
        if rows[y][x] == ' ':
          let nx: string = &"{(xy[0] - coords[0] + x + 1) div (t[0] * t[1] + 1)}"
          let ny: string = &"{(xy[1] - coords[1] + y) div (t[1] * t[1])}"
          if "13579".contains(nx[^1]) and "13579".contains(ny[^1]):
            let cx: string = &"{xy[0] - coords[0] + x}"
            let cy: string = &"{xy[1] - coords[1] + y}"
            if not "13579".contains(cx[^1]) or not "02468".contains(cy[^1]):
              if loot == "true" and rand(1 .. 500) == 1:
                visible[y * (lw + 1) + x] = 'R'
              else:
                visible[y * (lw + 1) + x] = '*'
          else:
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
            visible[y * (lw + 1) + x] = c

    map = map.replace("R", " ")
    writeMap('R', coords)

  of 2:
    for y in 1 .. rows.len - 2:
      for x in 1 .. lw - 2:
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
          case c
          of 'g', 'h', 'j', 'l', 'n', 'o', 'p':
            visible[y * (lw + 1) + x] = '*'
          else:
            visible[y * (lw + 1) + x] = c

    writeMap('*', setCoords())

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

