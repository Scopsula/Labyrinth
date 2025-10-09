import os, strformat, strutils, terminal
import entities, openInv

var 
  animation: bool = false
  sCr: string
  eAt: seq[string]
  eMa: seq[string]
  eHp: int
  eSt: int
  eMs: int
  eSe: int
  eSp: int
  atk: seq[string]
  mag: seq[string]
  hpo: int
  str: int
  mSt: int
  spe: int
  spo: int

proc setStats(eType: string): bool =
  let stats = readFile(&"../data/stats")
  hpo = stats.splitLines[2].split(' ')[1].parseInt
  str = stats.splitLines[3].split(' ')[1].parseInt
  mSt = stats.splitLines[4].split(' ')[1].parseInt
  spe = stats.splitLines[5].split(' ')[1].parseInt
  spo = stats.splitLines[6].split(' ')[1].parseInt

  let normal = stats.splitLines[0].split(' ')
  for i in 1  .. normal.len - 2:
    if normal[i] == "null":
      break
    atk.add(normal[i])

  let magic = stats.splitLines[1].split(' ')
  for i in 1  .. normal.len - 2:
    if magic[i] == "null":
      break
    mag.add(magic[i])

  if fileExists(&"../data/{eType}/stats"):
    let stats = readFile(&"../data/{eType}/stats")
    eHp = stats.splitLines[2].split(' ')[1].parseInt
    eSt = stats.splitLines[3].split(' ')[1].parseInt
    eMs = stats.splitLines[4].split(' ')[1].parseInt
    eSe = stats.splitLines[5].split(' ')[1].parseInt
    eSp = stats.splitLines[6].split(' ')[1].parseInt

    let normal = stats.splitLines[0].split(' ')
    for i in 1  .. normal.len - 2:
      if normal[i] == "null":
        break
      eAt.add(normal[i])

    let magic = stats.splitLines[1].split(' ')
    for i in 1  .. normal.len - 2:
      if magic[i] == "null":
        break
      eMa.add(magic[i])

    return true

proc writeChar(c: string, xy: array[2, int], sS: array[3, int]) =
  let ch: string = readFile(&"../data/chars/{c}")
  for cy in 0 .. sS[1] - 1:
    for cx in 0 .. sS[0] - 1:
      let wCh: char = ch[cy * (sS[0] + 1) + cx]
      sCr[(sS[1] * xy[1] + cy) * (sS[2] + 1) + (sS[0] * xy[0] + cx)] = wCh

proc screen(sS: array[6, int], eType: string) =
  let s3S: array[3, int] = [sS[3], sS[4], sS[2]]
  for y in 0 .. sS[1] - 1:
    for x in 0 .. sS[0] - 1:
      if x == 0 or x == sS[0] - 1:
        writeChar("battle/lr", [x, y], s3S)
        if y == 0 or y == sS[1] - 1: 
          writeChar("battle/cor", [x, y], s3S)
      elif y == 0 or y == sS[1] - 1: 
        writeChar("battle/tb", [x, y], s3S)

  let scX: float = sS[0].toFloat
  let scY: float = sS[1].toFloat
  if animation == true:
    sleep(100)
    for y in 1 .. sS[1] - 2:
      for x in 1 .. sS[0] - 2:
        writeChar(&"{sS[5]}/wall", [x, y], s3S)
        discard execShellCmd("clear")
        echo sCr

    for y in 1 .. sS[1] - 2:
      for x in 1 .. sS[0] - 2:
        if x == (scX / 4).toInt and y == sS[1] - (scY * 3/7).toInt - 1:
          writeChar("player", [x, y], s3S)
        elif x == sS[0] - (scX / 4).toInt - 1 and y == (scY * 3/7).toInt - 1:
          writeChar(eType, [x, y], s3S)
        elif y == sS[1] - (scY * 2/7).toInt:
          let n = (((sS[0] - 2) mod 5)) div 2 + 1
          if x == (sS[0] - 2) div 5 * 1 + n: 
            writeChar("battle/1", [x, y], s3S)
          elif x == (sS[0] - 2) div 5 * 2 + n:
            writeChar("battle/2", [x, y], s3S)
          elif x == (sS[0] - 2) div 5 * 3 + n:
            writeChar("battle/3", [x, y], s3S)
          elif x == (sS[0] - 2) div 5 * 4 + n:
            writeChar("battle/4", [x, y], s3S)
          else: 
            writeChar("battle/top", [x, y], s3S)
        else:
          writeChar("battle/blank", [x, y], s3S)
        discard execShellCmd("clear")
        echo sCr
    animation = false
  
  proc wrLine(line: string, num: int, xD: int, ovr: int) =
    var cD: int = ovr * (sS[2] + 1)
    if line.len < sS[3]:
      cD += (sS[3] - line.len) div 2
    let lB: int = (num * sS[4]) * (sS[2] + 1) + (xD * sS[3]) + cD
    let uB: int = lB + line.len - 1
    scr[lB .. uB] = line
  
  wrLine(&"HP: {hpo}", sS[1] - (scY * 3/7).toInt - 1, (scX / 4).toInt, -2)
  wrLine(&"SP: {spo}", sS[1] - (scY * 3/7).toInt - 1, (scX / 4).toInt, -1)
  wrLine(&"HP: {eHp}", (scY * 3/7).toInt - 1,sS[0] - (scX / 4).toInt - 1, -2)

  # Show enemy SP for testing
  wrLine(&"SP: {eSp}", (scY * 3/7).toInt - 1,sS[0] - (scX / 4).toInt - 1, -1)

  discard execShellCmd("clear")
  echo sCr

proc combat(eType: string, sS: array[6, int]) =
  screen(sS, eType)
  let input = getch()
  case input
  of '3', 'i': 
    let up: string = cInv(sCr, [sS[3], sS[4]])
  else: discard
  if input != 'q': 
    combat(eType, sS)

proc initBattle*(xy: array[2, int], sS: array[6, int], bg: string) =
  let eType: string = absoluteFindEntity(xy)
  if setStats(eType) == true:
    sCr = bg
    animation = true
    combat(eType, sS)

