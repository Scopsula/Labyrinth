import strformat, strutils, random

var 
  eloc: seq[array[3, int]]
  eTypes: array[1, string] = ["smiler"]
  deadZone: seq[seq[array[2, int]]]

proc resetEntities*() =
  eloc.setLen(0)

proc deleteEntity*(xy: array[2, int]) =
  if deadZone.len == 0:
    deadZone.setLen(eloc.len)
  for i in 0 .. eTypes.len - 1:
    if eloc.contains([xy[0], xy[1], i]):
      let d: int = find(eloc, [xy[0], xy[1], i])
      eloc.delete(d)
      deadZone.delete(d)

proc absoluteFindEntity*(xy: array[2, int]): string =
  for i in 0 .. eTypes.len - 1:
    if eloc.contains([xy[0], xy[1], i]):
      return &"entities/{eTypes[i]}"

proc findEntity*(v: string, xy: array[2, int], exy: array[2, int]): string =
  let rows = v.splitLines
  var coords: array[2, int]
  for y in 0 .. rows.len - 1:
    for x in 0 .. rows[0].len - 1:
      if rows[y][x] == 'S':
        coords = [x, y]

  let wx: int = xy[0] - coords[0] + exy[0]
  let wy: int = xy[1] - coords[1] + exy[1]

  return absoluteFindEntity([wx, wy])

proc moveEntities*(xy: array[2, int], m: string, mW: int): string =
  var map: string = m

  deadZone.setLen(eloc.len)
  if eloc.len > 0:
    for i in 0 .. eloc.len - 1:
      var eM: string = map.replace("E", " ")

      if deadZone.len > 0:
        if deadZone[i].len > 0:
          if deadZone[i].contains(xy):
            deadZone[i].setLen(0)
          else:
            for r in 0 .. deadZone[i].len - 1:
              eM[deadZone[i][r][1] * mW + deadZone[i][r][0]] = ' '

      var eX: int = eloc[i][0]
      var eY: int = eloc[i][1]

      let chk: int = eY * mW + eX
      if map[chk] != 'X': map[chk] = '*'
      if (eY + 1) * mW + eX + 1 > map.len - 1: discard
      elif (eY - 1) * mW + eX - 1 < 0: discard
      elif eX < xy[0] and eM[chk + 1] != ' ':
        eX += 1
      elif eX > xy[0] and eM[chk - 1] != ' ':
        eX -= 1 
      elif eY < xy[1] and eM[chk + mW] != ' ':
        eY += 1
      elif eY > xy[1] and eM[chk - mW] != ' ':
        eY -= 1
      else:
        if eM[chk + 1] == ' ':
          if eM[chk - 1] == ' ':
            if eM[chk + mW] == ' ':
              if eM[chk - mW] == ' ':
                let mv = sample([-mW, mW, -1, 1])
                if map[chk + mv] != ' ':
                  if map[chk + mv] != 'E':
                    deadZone[i].setLen(0)

        deadZone[i].add([eX, eY]) 
        let mv = sample([-mW, mW, -1, 1])
        if eM[chk + mv] != ' ':
          if mv == -mW: eY -= 1
          if mv == mW: eY += 1
          if mv == -1: eX -= 1
          if mv == 1: eX += 1

      eloc[i][0] = eX
      eloc[i][1] = eY

      map[eY * mW + eX] = 'E'
  return map

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
            map[wY * mW + wx] = 'E'

  return [visible, map]
