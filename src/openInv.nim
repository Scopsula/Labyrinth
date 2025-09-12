import os, strutils, strformat, terminal

proc checkCount*(): array[3, int] =
  let inv = readFile("../data").splitLines[2].split(' ')

  var 
    aCount: int = 0
    hCount: int = 0
    fCount: int = 0

  for i in 0 .. inv.len - 1:
    if inv[i].len > 0:
      if inv[i][0] == 'A': aCount += 1
      elif inv[i][0] == 'C': hCount += 1
      elif inv[i][0] == 'F': fCount += 1

  return [aCount, hCount, fCount]

proc oInv*(bg: string) =
  let 
    oC: array[3, int] = checkCount()
    a: int = oC[0]
    h: int = oC[1]
    f: int = oC[2]

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
      var stats = readFile("../data")
      var thirst = stats.splitLines[1].split(' ')[1].parseInt
      if thirst < 50:
        var chk: bool = false
        for i in 0 .. stats.len - 1:
          if chk == false:
            if stats[i .. i + 2] == "inv":
              chk = true
          else:
            if stats[i] == 'A':
              stats[i] = '!'
              break

        stats = stats.replace("!", "")

        let t1 = &"thirst {thirst}"
        if thirst > 45: thirst = 45
        let t2 = &"thirst {thirst + 5}"
        stats = stats.replace(t1, t2)
        writeFile("../data", stats)
        break

      else:
        input = 'n'
        pBg[^1] = 'x'

    elif input == 'b' and h > 0:
      var stats = readFile("../data")
      var health = stats.splitLines[0].split(' ')[1].parseInt
      if health < 50:
        var chk: bool = false
        for i in 0 .. stats.len - 1:
          if chk == false:
            if stats[i .. i + 2] == "inv":
              chk = true
          else:
            if stats[i] == 'C':
              stats[i] = '!'
              break

        stats = stats.replace("!", "")

        let t1 = &"health {health}"
        if health > 45: health = 45
        let t2 = &"health {health + 5}"
        stats = stats.replace(t1, t2)
        writeFile("../data", stats)
        break

      else:
        input = 'n'
        pBg[^1] = 'y'

    else: break

  if input != 'i':
    oInv(pBg)

