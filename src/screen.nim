import strutils, strformat, os
import style, entities

var scr: string = ""
var lv: string
var level: int

proc newLevel*() =
  if not fileExists("../loadedLevel/level"):
    writeFile("../loadedLevel/level", "0")
  lv = readFile("../loadedLevel/level").splitLines[0]
  level = lv.parseInt

proc match(t: char, v: string, xy: array[2, int], exy: array[2, int]): string =
  case t
  of ' ': return &"{level}/wall"
  of '*': return &"{level}/path"
  of '9': return &"{level}/path"
  of 'A': return "almond"
  of 'B': return "can"
  of 'F': return "flashlight"
  of 'R': return "crate"
  of 'S': return "player"
  of 'X': return "goal"
  of 'E': return findEntity(v, xy, exy)
  elif fileExists(&"../chars/{level}/match"):
    let mF = readFile(&"../chars/{level}/match").splitLines
    for i in 0 .. mF.len - 1:
      if mF[i][0] == t:
        let lMatch: string = mF[i].split(' ')[1]
        return &"{level}/{lMatch}"

proc writeChar(y, x, tX: int, tY: int, w: int, c: string) =
  var cBH: string
  var cH : string
  if not c.contains(&"{level}"):
    cBH = readFile(&"../chars/{level}/path")
    cH = readFile(&"../chars/{c}")
  else:
    cH = readFile(&"../chars/{c}")
  let sPos = (y * tY) * (w + 1) + (x * tX) 
  for iY in 0 .. tY - 1:
    for iX in 0 .. tX - 1:
      if cBH != "" and cH[iY * (tX + 1) + iX] == ' ':
        let wrC: char = cBH[iY * (tX + 1) + iX]
        scr[sPos + iY * (w + 1) + iX] = wrC
      else:
        let wrC: char = cH[iY * (tX + 1) + iX]
        scr[sPos + iY * (w + 1) + iX] = wrC

proc sc*(v: string, wht: array[4, int], xy: array[2, int], gXYH: array[3, int], chkD: array[4, int], map: string, msg: string): array[2, string] =
  var w1: string
  for i in 1 .. wht[0]:
    w1 = w1 & "/"

  scr = ""
  for i in 1 .. wht[1]:
    scr = scr & w1
    if i < wht[1]: 
      scr = scr & "\n"

  var vis: array[2, string] = adjustVisible(v, xy, level, [&"{chkD[2]}", map], [wht[2], wht[3]])
  vis = entities(vis[0], [&"{chkD[2]}", vis[1]], xy)
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

  var nV: string
  for i in 0 .. rows.len - 1:
    nV = nV & rows[i]
    if i != rows.len - 1:
      nV = nV & "\n"

  for r in 0 .. rows.len - 1:
    for rX in 0 .. rows[r].len - 1:
      let t: char = rows[r][rX]
      let c: string = match(t, nV, xy, [rX, r])
      writeChar(r, rx, wht[2], wht[3], wht[0], c)

  let bg: string = scr

  proc wrLine(line: string, num: int) =
    scr[num * (wht[0] + 1) .. num * (wht[0] + 1) + line.len - 1] = line

  let stats = readFile("../data").splitLines
  let dHealth = stats[0].split(' ')[1].parseInt div 10
  let dThirst = stats[1].split(' ')[1].parseInt div 10

  var hBar: string = "H: "
  for i in 1 .. dHealth:
    hBar = hBar & "O-"
  for i in dHealth + 1 .. 5:
    hBar = hBar & "|-"
  hBar[^1] = ' '

  var tBar: string = "T: "
  for i in 1 .. dThirst:
    tBar = tBar & "O-"
  for i in dThirst + 1 .. 5:
    tBar = tBar & "|-"
  tBar[^1] = ' '

  wrLine(hBar, 0)
  wrLine(tBar, 1)

  var lC: int = 0
  if gXYH[2] == 1: 
    wrLine(&"pX: {xy[0]} pY: {xy[1]} ", 2)
    wrLine(&"gX: {gXYH[0]} gY: {gXYH[1]} ", 3)
    lC = 2

  wrLine("[m] to open map ", 2 + lC)
  wrLine("[i] to open inv ", 3 + lC)
  wrLine("[q] to quit ", 4 + lC)
  wrLine(msg, 5 + lC)

  discard execShellCmd("clear")
  echo scr
  return [vis[1], bg]
