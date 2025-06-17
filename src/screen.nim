import strutils, strformat, os

var scr: string = ""
var lv: string
var level: int

proc newLevel*() =
  lv = readFile("../loadedLevel/level").splitLines[0]
  level = lv.parseInt

proc match(t: char): int =
  case t
  of ' ': return level
  of '*': return level + 800
  of 'S': return 900
  of 'X': return 901
  else: discard

proc writeChar(y, x, tX: int, tY: int, w: int, c: int) =
  let cH = readFile(&"../chars/{c}")
  let sPos = (y * tY) * (w + 1) + (x * tX)
  for iY in 0 .. tY - 1:
    for iX in 0 .. tX - 1:
      let wrC: char = cH[iY * (tX + 1) + iX]
      scr[sPos + iY * (w + 1) + iX] = wrC

proc sc*(v: string, w: int, h: int, tX: int, tY: int, xy: array[2, int], gXYH: array[3, int]) =
  var w1: string
  for i in 1 .. w:
    w1 = w1 & "/"

  scr = ""
  for i in 1 .. h:
    scr = scr & w1
    if i < h: 
      scr = scr & "\n"

  let rows = v.splitLines
  for r in 0 .. rows.len - 1:
    for rX in 0 .. rows[r].len - 1:
      let t: char = rows[r][rx]
      let c: int = match(t)
      writeChar(r, rx, tX, tY, w, c)

  if gXYH[2] == 1:
    let dsXY: string = &"pX: {xy[0]} pY: {xy[1]} "
    let dsGXY: string = &"gX: {gXYH[0]} gY: {gXYH[1]} "
    scr[w + 1 .. w  + dsXY.len] = dsXY
    scr[2 * (w + 1) .. 2 * w + 1 + dsGXY.len] = dsGXY

  discard execShellCmd("clear")
  echo scr
