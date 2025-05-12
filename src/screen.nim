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
      if c == match('S'):
        if wrC != ' ':
          scr[sPos + iY * (w + 1) + iX] = wrC
      else:
        scr[sPos + iY * (w + 1) + iX] = wrC

proc sc*(v: string, w: int, h: int, tX: int, tY: int) =
  scr = ""
  for i in 1 .. h:
    for i in 1 .. w:
      scr = scr & "/"
    if i < h: scr = scr & "\n"

  let rows = v.splitLines
  for r in 0 .. rows.len - 1:
    for rX in 0 .. rows[r].len - 1:
      let t: char = rows[r][rx]
      let c: int = match(t)
      if t == 'S':
        let b: int = match('*')
        writeChar(r, rx, tX, tY, w, b)
      writeChar(r, rx, tX, tY, w, c)

  discard execShellCmd("clear")
  echo scr
