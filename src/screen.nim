import strutils, strformat, os
import style

var scr: string = ""
var lv: string
var level: int

proc newLevel*() =
  if not fileExists("../loadedLevel/level"):
    writeFile("../loadedLevel/level", "0")
  lv = readFile("../loadedLevel/level").splitLines[0]
  level = lv.parseInt

proc match(t: char): string =
  case t
  of ' ': return "wall"
  of '*': return "path"
  of '9': return "path"
  of 'S': return "player"
  of 'X': return "goal"
  elif fileExists(&"../chars/{level}/match"):
    let mF = readFile(&"../chars/{level}/match").splitLines
    for i in 0 .. mF.len - 1:
      if mF[i][0] == t:
        return mF[i].split(' ')[1]

proc writeChar(y, x, tX: int, tY: int, w: int, c: string) =
  var cBH: string
  var cH : string
  if c == "player" or c == "goal":
    cBH = readFile(&"../chars/{level}/path")
    cH = readFile(&"../chars/{c}")
  else:
    cH = readFile(&"../chars/{level}/{c}")
  let sPos = (y * tY) * (w + 1) + (x * tX) 
  for iY in 0 .. tY - 1:
    for iX in 0 .. tX - 1:
      if cBH != "" and cH[iY * (tX + 1) + iX] == ' ':
        let wrC: char = cBH[iY * (tX + 1) + iX]
        scr[sPos + iY * (w + 1) + iX] = wrC
      else:
        let wrC: char = cH[iY * (tX + 1) + iX]
        scr[sPos + iY * (w + 1) + iX] = wrC

proc sc*(v: string, wht: array[4, int], xy: array[2, int], gXYH: array[3, int], chkD: array[4, int], map: string): string =
  var w1: string
  for i in 1 .. wht[0]:
    w1 = w1 & "/"

  scr = ""
  for i in 1 .. wht[1]:
    scr = scr & w1
    if i < wht[1]: 
      scr = scr & "\n"

  let vis: array[2, string] = adjustVisible(v, xy, level, [&"{chkD[2]}", map], [wht[2], wht[3]])
  var rows = vis[0].splitLines

  for i in 1 .. 2:
    if xy[1] >= chkD[1] - i + 1:
      rows.delete(0)
    if xy[1] + chkD[1] < chkD[3] - 2 + i:
      rows.delete(rows.len - 1)
    if xy[0] >= chkD[0] - i + 1:
      for i in 0 .. rows.len - 1:
        rows[i][0 .. ^1] = rows[i][1 .. ^1]
    if xY[0] + chkD[0] < chkD[2] + i - 1:
      for i in 0 .. rows.len - 1:
        rows[i][0 .. ^1] = rows[i][0 .. ^2]

  for r in 0 .. rows.len - 1:
    for rX in 0 .. rows[r].len - 1:
      let t: char = rows[r][rx]
      let c: string = match(t)
      writeChar(r, rx, wht[2], wht[3], wht[0], c)

  proc wrLine(line: string, num: int) =
    scr[num * (wht[0] + 1) .. num * (wht[0] + 1) + line.len - 1] = line

  if gXYH[2] == 1: 
    wrLine(&"pX: {xy[0]} pY: {xy[1]} ", 0)
    wrLine(&"gX: {gXYH[0]} gY: {gXYH[1]} ", 1)
    wrLine("[m] to open map ", 2)

  else:
    wrLine("[m] to open map ", 0)

  discard execShellCmd("clear")
  echo scr
  return vis[1]
