import strutils, strformat, random

proc refresh*(): bool =
  let level: string = readFile("../data/level")
  case level
  of "1": return true
  else: discard

let loot: string = readFile("../data/config").splitLines[5].split(' ')[1]

proc adjustVisible*(v: string, xy: array[2, int], level: int, mS: array[2, string], t: array[2, int]): array[2, string] =
  var visible: string = v 
  var map = mS[1]
  var rows = v.splitLines
  let lw = rows[0].len

  case level
  of 0, 4, 5:
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
    var coords: array[2, int]
    for y in 0 .. rows.len - 1:
      for x in 0 .. lw - 1:
        if rows[y][x] == 'S':
          coords = [x, y]
          break

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
    let mW = mS[0].parseInt
    for y in 1 .. rows.len - 2:
      for x in 1 .. lw - 2:
        let uC: char = visible[y * (lw + 1) + x]
        if uC == '*' or uC == 'R':
          let wx: int = xy[0] - coords[0] + x
          let wy: int = xy[1] - coords[1] + y
          map[wy * mW + wx] = uC
  
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
          visible[y * (lw + 1) + x] = c

  else: discard

  return [visible, map]

