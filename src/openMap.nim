import os, strutils

proc openMap*(wh: array[2, int], loc: array[2, int], m: string, mW: int, h0: int) =
  var paths: string = readFile("../loadedLevel/map")
  let mYC = paths.splitLines.len
  paths = paths.replace("\n", "")
  for i in 0 .. m.len - 1:
    if m[i] == '9': 
      paths[i] = 'C'
    if m[i] == 'S':
      paths[i] = 'S'
    if h0 == 1:
      if m[i] == 'X':
        paths[i] = 'X'

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

  let 
    l1: string = " Some areas may be unmarked |"
    l2: string = " S: --Player--------------- |"
    l3: string = " C: --Tiles Visited-------- |"
    l4: string = " :: --[m] to close map----- |"
    lD: string = "----------------------------|"

  if h0 == 1:
    let l5: string = " X: --Exit----------------- |"
    visible[5 * (x + 1) + 1  .. 5 * (x + 1) + l5.len] = l5
    visible[6 * (x + 1) + 1  .. 6 * (x + 1) + lD.len] = lD
  else: 
    visible[5 * (x + 1) + 1  .. 5 * (x + 1) + lD.len] = lD

  visible[x + 2 .. x + 1 + l1.len] = l1
  visible[2 * (x + 1) + 1  .. 2 * (x + 1) + l2.len] = l2
  visible[3 * (x + 1) + 1  .. 3 * (x + 1) + l3.len] = l3
  visible[4 * (x + 1) + 1  .. 4 * (x + 1) + l4.len] = l4

  discard execShellCmd("clear")
  echo visible

