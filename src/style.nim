import strutils, strformat, random

proc adjustVisible*(v: string, xy: array[2, int], level: int): string =
  var visible: string = v 
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
            visible[y * (lw + 1) + x] = 'w'
  if level == 1:
    var coords: array[2, int]
    for y in 0 .. rows.len - 1:
      for x in 0 .. lw - 1:
        if rows[y][x] == 'S':
          coords = [x, y]
          break
    for y in 1 .. rows.len - 2:
      for x in 1 .. lw - 2:
        let nx = &"{(xy[0] - coords[0] + x) div 50}"
        let ny = &"{(xy[1] - coords[1] + y) div 25}"
        if not "3579".contains(nx[^1]) and not "3579".contains(ny[^1]):
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
            let c = "abcdefghijklmnop"[incr]
            visible[y * (lw + 1) + x] = c
  return visible

