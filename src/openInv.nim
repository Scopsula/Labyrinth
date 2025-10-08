import os, strutils, strformat, terminal

proc checkCount*(c: char): int =
  if not fileExists(&"../data/items/{c}"):
    writeFile(&"../data/items/{c}", "0")
  return readFile(&"../data/items/{c}").parseInt

proc cInv*(bg: string, t: array[2, int]): string =
  let f: int = checkCount('F')
  var scr: string = bg
  let sW: int = bg.splitLines[0].len

  proc wrLine(line: string, num: int) =
    scr[num * (sW + 1) + t[0] .. num * (sW + 1) + line.len - 1 + t[0]] = line

  wrLine("|-----------------|", t[1])
  wrLine("| -Usuable Items- |", t[1] + 1)
  wrLine(&"| -{f} [F]lashlight |", t[1] + 2)
  wrLine("|-----------------|", t[1] + 3)

  discard execShellCmd("clear")
  echo scr  

  let input = getch()
  case input
  of 'f':
    if f > 0:
      writeFile("../data/items/F", &"{f - 1}")
      return "flashlight"
  else: discard

proc oInv*(bg: string) =
  let 
    a: int = checkCount('A')
    h: int = checkCount('B')
    f: int = checkCount('F')

  let dInv: string = &"""
| -Essential Items- |
| {a}/6 Almond Water  |
| {h}/6 Canned Food   |
| {f}/3 Flashlights   |
|-------------------|
| --Special Items-- |"""

  var scr: string = bg
  let sW: int = bg.splitLines[0].len
  let dLInv = dInv.splitLines

  proc wrLine(line: string, num: int) =
    scr[num * (sW + 1) .. num * (sW + 1) + line.len - 1] = line

  for i in 0 .. dLInv.len - 1:
    wrLine(dLInv[i], i)

  wrLine("|-------------------|", dLInv.len)
  wrLine("| [a] drink almond  |", dLInv.len + 1)
  wrLine("| [b] eat food      |", dLInv.len + 2)
  wrLine("| [i] to close inv  |", dLInv.len + 3)
  wrLine("|-------------------|", dLInv.len + 4)
  
  var pBg: string = bg
  if bg[^1] == 'x':
    wrLine("| Thirst is minimal |", dLInv.len + 5)
    wrLine("|-------------------|", dLInv.len + 6)
    pBg[^1] = '/'

  if bg[^1] == 'y':
    wrLine("| Health is maximal |", dLInv.len + 5)
    wrLine("|-------------------|", dLInv.len + 6)
    pBg[^1] = '/'

  discard execShellCmd("clear")
  echo scr

  var input = getch()
  while true:
    if input == 'a' and a > 0:
      var stats = readFile("../data/stats")
      var thirst = stats.splitLines[9].split(' ')[1].parseInt
      if thirst < 50:
        writeFile("../data/items/A", &"{a - 1}")
        let t1 = &"thirst {thirst}"
        if thirst > 45: thirst = 45
        let t2 = &"thirst {thirst + 5}"
        stats = stats.replace(t1, t2)
        writeFile("../data/stats", stats)
        break

      else:
        input = 'n'
        pBg[^1] = 'x'

    elif input == 'b' and h > 0:
      var stats = readFile("../data/stats")
      var health = stats.splitLines[2].split(' ')[1].parseInt
      if health < 50:
        writeFile("../data/items/B", &"{h - 1}")
        let t1 = &"health {health}"
        if health > 45: health = 45
        let t2 = &"health {health + 5}"
        stats = stats.replace(t1, t2)
        writeFile("../data/stats", stats)
        break

      else:
        input = 'n'
        pBg[^1] = 'y'

    else: break

  if input != 'i' and input != '3':
    oInv(pBg)

