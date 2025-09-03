import strutils

proc adjustVisible*(v: string, xy: array[2, int], level: int): string =
  var visible: string = v
  if level == 0:
    var rows = v.splitLines
    let lw = rows[0].len
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
  return visible

