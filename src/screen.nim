import strutils, strformat, os
import style, entities

var scr: string = ""
var level: int

proc newLevel*(nlv: int) =
  level = nlv

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
  elif fileExists(&"../data/chars/{level}/match"):
    let mF = readFile(&"../data/chars/{level}/match").splitLines
    for i in 0 .. mF.len - 1:
      if mF[i] != "": 
        if mF[i][0] == t:
          let lMatch: string = mF[i].split(' ')[1]
          return &"{level}/{lMatch}"
  if fileExists(&"../data/chars/temp/{t}"):
    return &"temp/{t}"

proc writeChar(y, x, tX: int, tY: int, w: int, c: string) =
  var cBH: string
  var cH : string
  if not c.contains(&"{level}") and not c.contains("temp"):
    cBH = readFile(&"../data/chars/{level}/path")
    cH = readFile(&"../data/chars/{c}")
  else:
    cH = readFile(&"../data/chars/{c}")
  let sPos = (y * tY) * (w + 1) + (x * tX) 
  for iY in 0 .. tY - 1:
    for iX in 0 .. tX - 1:
      if cBH != "" and cH[iY * (tX + 1) + iX] == ' ':
        let wrC: char = cBH[iY * (tX + 1) + iX]
        scr[sPos + iY * (w + 1) + iX] = wrC
      else:
        let wrC: char = cH[iY * (tX + 1) + iX]
        scr[sPos + iY * (w + 1) + iX] = wrC

var 
  xy: array[2, int]
  wht: seq[int]
  gXYH: seq[int]
  chkD: seq[int]

proc exportVar*(iVar: seq[int], name: string) =
  case name
  of "xy": 
    xy[0] = iVar[0]
    xy[1] = iVar[1]
  of "wht": wht = iVar
  of "gXYH": gXYH = iVar
  of "chkD": chkD = iVar

proc bar(st: string, ln: int): string =
  var rSt: string = st
  for i in 1 .. ln:
    rSt = rSt & "O-"
  for i in ln + 1 .. 5:
    rSt = rSt & "|-"
  rSt[^1] = ' '
  return rSt

proc sc*(v: string, map: string, msg: string, music: array[2, string]): array[2, string] =
  var w1: string
  for i in 1 .. wht[0]:
    w1 = w1 & "/"

  scr = ""
  for i in 1 .. wht[1]:
    scr = scr & w1
    if i < wht[1]: 
      scr = scr & "\n"

  var vis: array[2, string] = adjustVisible(v, xy, level, [&"{chkD[2]}", map], [wht[2], wht[3]])
  if gXYH[3] == 1: vis = entities(vis[0], [&"{chkD[2]}", vis[1]], xy)
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

  if music[0] != &"{level}/{level}" and music[0].len > 0:
    let rLen: int = wht[2] * rows[0].len - 1
    proc wMLine(line: string, num: int) =
      let lineC: int = num * (wht[0] + 1)
      scr[lineC + rLen - line.len + 1 .. lineC + rLen] = line

    var line: string = &" | Now playing: {music[0].split('/')[1]} "
    var author: string = & " | By: {music[1]} "

    if author.len < line.len:
      for i in author.len .. line.len - 1:
        author = author & " "

    elif line.len < author.len:
      for i in line.len .. author.len - 1:
        line = line & " "

    var bLine: string
    for i in 0 .. line.len - 1:
      if i == 0:
        bLine = bLine & " "
      elif i == 1:
        bLine = bLine & "|"
      else:
        bLine = bLine & "-"

    wMLine(bLine, 0)
    wMLine(line, 1)
    wMLine(author, 2)
    wMLine(bLine, 3)

  if gXYH[4] == 1:
    let stats = readFile("../data/stats").splitLines
    let dHealth = stats[2].split(' ')[1].parseInt div 10
    let dThirst = stats[9].split(' ')[1].parseInt div 10

    var hBar: string = "H: "
    hBar = bar(hBar, dHealth)
    wrLine(hBar, 0)

    var tBar: string = "T: "
    tBar = bar(tBar, dThirst)
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

  elif gXYH[2] == 1: 
    wrLine(&"pX: {xy[0]} pY: {xy[1]} ", 0)
    wrLine(&"gX: {gXYH[0]} gY: {gXYH[1]} ", 1)

  discard execShellCmd("clear")
  echo scr
  return [vis[1], bg]
