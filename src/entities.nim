import strformat, strutils, random

var 
  eloc: seq[array[3, int]]
  eTypes: array[2, string] = ["smiler", "duller"]

proc findEntity*(v: string, xy: array[2, int], exy: array[2, int]): string =
  let rows = v.splitLines
  var coords: array[2, int]
  for y in 0 .. rows.len - 1:
    for x in 0 .. rows[0].len - 1:
      if rows[y][x] == 'S':
        coords = [x, y]

  let wx: int = xy[0] - coords[0] + exy[0]
  let wy: int = xy[1] - coords[1] + exy[1]

  for i in 0 .. eTypes.len - 1:
    if eloc.contains([wx, wy, i]):
      return &"entity/{eTypes[i]}"

proc entities*(v: string, mS: array[2, string], xy: array[2, int]): array[2, string] =
  var visible: string = v
  var rows = v.splitLines
  var coords: array[2, int]
  let lw: int = rows[0].len
  for y in 0 .. rows.len - 1:
    for x in 0 .. lw - 1:
      if rows[y][x] == 'S':
        coords = [x, y]

  var map: string = mS[1]
  let mW: int = mS[0].parseInt
  for y in 0 .. rows.len - 1:
    for x in 0 .. lw - 1:
      if y == 0 or y == rows.len - 1 or x == 0 or x == lw - 1:
        if rows[y][x] == '*':
          if rand(1 .. 1000) == 1:
            let wx: int = xy[0] - coords[0] + x
            let wy: int = xy[1] - coords[1] + y
            eloc.add([wx, wy, rand(0 .. eTypes.len - 1)])
            visible[y * (lw + 1) + x] = 'E'
            map[wy * mW + wx] = 'E'

  return [visible, map]
