import os, strutils

proc openMap*(wh: array[2, int], loc: array[2, int], m: string, mW: int, h0: int, bg: string, sMap: string) =
  var paths: string = sMap
  let mYC = paths.splitLines.len
  if readFile("../config").splitLines[6].split(' ')[1] == "true":
    paths = paths.replace("\n", "")
  else:
    paths = paths.multiReplace(("\n", ""), ("A", "*"), ("B", "*"), ("F", "*"))

  let
    yD = (wh[1] - 1) div 2
    xD = (wh[0] - 1) div 2
    pos = loc[1] * mW + loc[0]

  var 
    lXB: int
    uXB: int
    lYB: int
    uYB: int

  if loc[0] >= xD: lXB = pos - xD 
  else: lXB = pos - loc[0]
  if loc[0] + xD < mW: uXB = pos + xD
  else: uXB = pos - loc[0] + mW - 1
  if loc[1] >= yD: lYB = -yD
  else: lYB = -(yD + (loc[1] - yD))
  if loc[1] + yD <= mYC - 2: uYB = yD 
  else: uYB = yD - (loc[1] + yD - mYC + 2)

  var visible: string
  for i in lYB .. uYB:
    let lY: int = i * mW
    for c in lXB .. uXB:
      if m[c + lY] == '9': 
        paths[c + lY] = 'C'
      if m[c + lY] == 'S':
        paths[c + lY] = 'S'
      if h0 == 1:
        if m[c + lY] == 'X':
          paths[c + lY] = 'X'
    let l: string = paths[lXB + lY .. uXB + lY]
    if i < uYB: visible = visible & l & "\n"
    else: visible = visible & l

  let x: int = visible.splitLines[0].len
  let y: int = visible.splitLines.len

  for b in 0 .. x - 1:
    visible[b] = '-'
    visible[(y - 1) * (x + 1) + b] = '-'
  for b in 0 .. y - 1:
    visible[b * (x + 1)] = '|'
    visible[b * (x + 1) + x - 1] = '|'

  var scr: string = bg
  let sW: int = bg.splitLines[0].len
  proc wrLine(line: string, num: int) =
    scr[num * (sW + 1) .. num * (sW + 1) + line.len - 1] = line
  
  for i in 0 .. y - 1:
    wrLine(visible.splitLines[i], i)

  if h0 == 1:
    wrLine("| X: Exit                      |", 5)
    wrLine("|------------------------------|", 6)
  else: 
    wrLine("|------------------------------|", 5)

  wrLine("| Unique areas may be unmarked |", 1)
  wrLine("| S: Player                    |", 2)
  wrLine("| C: Tiles Visited             |", 3)
  wrLine("| :: [m] to close map          |", 4)

  discard execShellCmd("clear")
  echo scr

