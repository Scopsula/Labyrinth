import strutils, strformat, os

proc refresh*(): bool =
  if fileExists("../loadedLevel/level"):
    let level: string = readFile("../loadedLevel/level")
    case level
    of "1": return true
    else: discard

proc adjustVisible*(v: string, xy: array[2, int], level: int, mS: array[2, string], t: array[2, int]): array[2, string] =
  var visible: string = v 
  var map = mS[1]
  var rows = v.splitLines
  let lw = rows[0].len

  if level == 0:
    for y in 1 .. rows.len - 2:
      for x in 1 .. lw - 2:
        var incr: int = 0
        if rows[y][x] == ' ':
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

  if level == 1:
    var coords: array[2, int]
    for y in 0 .. rows.len - 1:
      for x in 0 .. lw - 1:
        if rows[y][x] == 'S':
          coords = [x, y]
          break

    for y in 1 .. rows.len - 2:
      for x in 1 .. lw - 2:
        if rows[y][x] == ' ':
          let nx: string = &"{(xy[0] - coords[0] + x) div (t[0] * t[1])}"
          let ny: string = &"{(xy[1] - coords[1] + y) div (t[1] * t[1])}"
          if "13579".contains(nx[^1]) and "13579".contains(ny[^1]):
            let cx: string = &"{xy[0] - coords[0] + x}"
            let cy: string = &"{xy[1] - coords[1] + y}"
            if not "13579".contains(cx[^1]) or not "02468".contains(cy[^1]):
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

    let mW = mS[0].parseInt
    for y in 1 .. rows.len - 2:
      for x in 1 .. lw - 2:
        if visible[y * (lw + 1) + x] == '*':
          let wx: int = xy[0] - coords[0] + x
          let wy: int = xy[1] - coords[1] + y
          map[wy * mW + wx] = '*'

  return [visible, map]

