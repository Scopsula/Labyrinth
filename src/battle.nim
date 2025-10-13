import os, strformat, strutils, terminal, random
import entities, openInv, setMove

var 
  animation: bool = false
  count: int = 0
  msg: string
  sCr: string
  eAt: seq[string]
  eMa: seq[string]
  eHp: int
  eSt: int
  eMs: int
  eSe: int
  eSp: int
  eRe: seq[array[2, string]]
  eWe: seq[array[2, string]]
  atk: seq[string]
  mag: seq[string]
  hpo: int
  str: int
  mSt: int
  spe: int
  spo: int
  res: seq[array[2, string]]
  wea: seq[array[2, string]]

proc setStats(eType: string): bool =
  if not fileExists(&"../data/{eType}/stats"):
    return false

  let stats = readFile(&"../data/stats")
  hpo = stats.splitLines[2].split(' ')[1].parseInt
  str = stats.splitLines[3].split(' ')[1].parseInt
  mSt = stats.splitLines[4].split(' ')[1].parseInt
  spe = stats.splitLines[5].split(' ')[1].parseInt
  spo = stats.splitLines[6].split(' ')[1].parseInt

  atk.setLen(0)
  let normal = stats.splitLines[0].split(' ')
  for i in 1  .. normal.len - 1:
    if normal[i] == "null":
      break
    atk.add(normal[i])

  mag.setLen(0)
  let magic = stats.splitLines[1].split(' ')
  for i in 1  .. magic.len - 1:
    if magic[i] == "null":
      break
    mag.add(magic[i])

  res.setLen(0)
  let resist = stats.splitLines[7].split(' ')
  for i in 1  .. resist.len - 1:
    if resist[i] == "null":
      break
    let rV = resist[i].split('|')
    res.add([rV[0], rV[1]])

  wea.setLen(0)
  let weak = stats.splitLines[8].split(' ')
  for i in 1  .. weak.len - 1:
    if weak[i] == "null":
      break
    let wV = weak[i].split('|')
    wea.add([wV[0], wV[1]])

  if fileExists(&"../data/{eType}/stats"):
    let stats = readFile(&"../data/{eType}/stats")
    eHp = stats.splitLines[2].split(' ')[1].parseInt
    eSt = stats.splitLines[3].split(' ')[1].parseInt
    eMs = stats.splitLines[4].split(' ')[1].parseInt
    eSe = stats.splitLines[5].split(' ')[1].parseInt
    eSp = stats.splitLines[6].split(' ')[1].parseInt

    eAt.setLen(0)
    let normal = stats.splitLines[0].split(' ')
    for i in 1  .. normal.len - 1:
      if normal[i] == "null":
        break
      eAt.add(normal[i])

    eMa.setLen(0)
    let magic = stats.splitLines[1].split(' ')
    for i in 1  .. magic.len - 1:
      if magic[i] == "null":
        break
      eMa.add(magic[i])

    eRe.setLen(0)
    let resist = stats.splitLines[7].split(' ')
    for i in 1  .. resist.len - 1:
      if resist[i] == "null":
        break
      let rV = resist[i].split('|')
      eRe.add([rV[0], rV[1]])

    eWe.setLen(0)
    let weak = stats.splitLines[8].split(' ')
    for i in 1  .. weak.len - 1:
      if weak[i] == "null":
        break
      let wV = weak[i].split('|')
      eWe.add([wV[0], wV[1]])

    return true

proc writeChar(c: string, xy: array[2, int], sS: array[3, int]) =
  let ch: string = readFile(&"../data/chars/{c}")
  for cy in 0 .. sS[1] - 1:
    for cx in 0 .. sS[0] - 1:
      let wCh: char = ch[cy * (sS[0] + 1) + cx]
      sCr[(sS[1] * xy[1] + cy) * (sS[2] + 1) + (sS[0] * xy[0] + cx)] = wCh

proc screen(sS: array[6, int], eType: string, msg: string) =
  let s3S: array[3, int] = [sS[3], sS[4], sS[2]]
  for y in 0 .. sS[1] - 1:
    for x in 0 .. sS[0] - 1:
      if x == 0 or x == sS[0] - 1:
        writeChar("battle/lr", [x, y], s3S)
        if y == 0 or y == sS[1] - 1: 
          writeChar("battle/cor", [x, y], s3S)
      elif y == 0 or y == sS[1] - 1: 
        writeChar("battle/tb", [x, y], s3S)

  let 
    scX: float = sS[0].toFloat
    scY: float = sS[1].toFloat
    pLN: int = sS[1] - (scY * 3/7).toInt - 1
    pLX: int = (scX / 4).toInt 
    eLN: int = (scY * 3/7).toInt - 1
    eLX: int = sS[0] - (scX / 4).toInt - 1

  if animation == true:
    sleep(100)
    for y in 1 .. sS[1] - 2:
      for x in 1 .. sS[0] - 2:
        writeChar(&"{sS[5]}/wall", [x, y], s3S)
        discard execShellCmd("clear")
        echo sCr

    for y in 1 .. sS[1] - 2:
      for x in 1 .. sS[0] - 2:
        if x == pLX and y == pLN:
          writeChar("player", [x, y], s3S)
        elif x == eLX and y == eLN:
          writeChar(&"{eType}/map", [x, y], s3S)
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

  var clLine: string
  for i in 0 .. sS[3] * (sS[0] - 2) - 1:
    clLine = &"{clLine} "
  for i in 0 .. 1:
    wrLine(clLine, 1, 1, i + 1)

  let message = msg.splitLines()
  for i in 0 .. message.len - 1:
    wrLine("  " & message[i], 1, 1, i + 1)

  wrLine(&"          ", pLN, pLX, -2)
  wrLine(&"          ", pLN, pLX, -1)
  wrLine(&"HP: {hpo}", pLN, pLX, -2)
  wrLine(&"SP: {spo}", pLN, pLX, -1)

  wrLine(&"          ", eLN, eLX, -2)
  wrLine(&"HP: {eHp}", eLN, eLX, -2)

  # Show enemy SP for testing
  wrLine(&"          ", eLN, eLX, -1)
  wrLine(&"SP: {eSp}", eLN, eLX, -1)

  discard execShellCmd("clear")
  echo sCr

proc calcMove(cat: array[2, string], eType: string, player: bool): string =
  var mvData: string
  case cat[1]
  of "flashlight":
    if eType == "entities/smiler":
      discard  
  of "iMove":
    let set = readFile("../data/moves/items").splitLines
    for i in 0 .. set.len - 1:
      if set[i].split('|')[0] == cat[0]:
        mvData = set[i]
  of "move":
    for i in 0 .. 9:
      if fileExists(&"../data/moves/set{i}"):
        let set = readFile(&"../data/moves/set{i}").splitLines
        for r in 0 .. set.len - 1:
          if set[r].split('|')[0] == cat[0]:
            mvData = set[r]
            break
  else:
    mvData = cat[1]

  let mSv = mvData.split('|')
  let dType: string = mSv[4]

  var 
    wSet: seq[array[2, string]]
    rSet: seq[array[2, string]]
    dPSt : int
    dMSt: int

  if player == true:
    wSet = eWe
    rSet = eRe
    dPSt = str
    dMSt = dMSt
  else:
    wSet = wea
    rSet = res
    dPSt = eSt
    dMSt = eMs

  let 
    nat: float = mSv[2].parseFloat
    mat: float = mSv[2].parseFloat
    acr: int = mSv[7].parseInt
    pRds: int = mSv[10].parseInt
    mRds: int = mSv[11].parseInt

  var mMult: float
  var pMult: float
  for i in 1 .. 100:
    if wSet.contains([dType, &"{i}"]):
      mMult = 1 + (i / 100)
      break
    if rSet.contains([dType, &"{i}"]):
      mMult = 1 + (i / 100)
      break
    if mat > 0 and nat > 0:
      if wSet.contains(["physical", &"{i}"]):
        pMult = 1 + (i / 100)
        break
      if rSet.contains(["physical", &"{i}"]):
        pMult -= (i / 100)
        break
    else:
      pMult = mMult

  let phyDam: int = (nat * pMult).toInt + rand(-pRds .. pRds) + dPSt
  let magDam: int = (mat * mMult).toInt + rand(-mRds .. mRds) + dMSt

  var damage: int = phyDam + magDam
  if damage < 0: damage = 0

  if rand(1 .. 100) < acr:
    if player == true:
      eHp -= damage
    else:
      hpo -= damage

  var rMS: string = mSv[1]
  if player == true:
    rMS = rMS.replace("%user%", "You")
    rMS = rMS.replace("%target%", eType[9 .. ^2])
  else:
    rMS = rMS.replace("%user%", eType[9 .. ^2])
    rMS = rMS.replace("%target%", "you")

  rMS = rMS.replace("%dmg%", &"{damage}")

  return rMS

proc enemyMove(eType: string): string =
  var mvData: seq[string]
  for i in 0 .. eMa.len + eAt.len - 2:
    for j in 0 .. 9:
      if fileExists(&"../data/moves/set{j}"):
        let set = readFile(&"../data/moves/set{j}").splitLines
        for k in 0 .. set.len - 1:
          if i <= eMa.len - 1:
            if set[k].split('|')[0] == eMa[i]:
              if not mvData.contains(set[k]):
                mvData.add(set[k])
          if i <= eAt.len - 1:
            if set[k].split('|')[0] == eAt[i]:
              if not mvData.contains(set[k]):
                mvData.add(set[k])

  var cat: array[2, string] = ["", ""]

  let move: string = selEMove(eType, count) 
  for i in 0 .. mvData.len - 1:
    let mV = mvData[i].split('|') 
    if eSp >= mV[11].parseInt:
      if mV[0] == move:
        cat[0] = move
        cat[1] = mvData[i]

  if cat[0] == "":
    for i in 0 .. mvData.len - 1:
      let mV = mvData[i].split('|')
      if eSp >= mV[11].parseInt:
        for r in 1 .. 100:
          if wea.contains([mV[4], &"{r}"]):
            cat[0] = mV[0]
            cat[1] = mvData[i]
            break

  if cat[0] == "":
    var chk: seq[int]
    for i in 0 .. mvData.len - 1:
      var randSel: int = rand(0 .. mvData.len - 1)
      while chk.contains(randSel):
        randSel = rand(0 .. mvData.len - 1)
      
      chk.add(randSel)
      let rM = mvData[randSel].split('|')
      if eSp >= rM[11].parseInt:
        for r in 1 .. 100:
          if not res.contains([rM[4], &"{r}"]):
            cat[0] = rM[0]
            cat[1] = mvData[randSel]
            break

  if cat[0] == "":
    let randSel: int = rand(0 .. mvData.len - 1)
    let rM = mvData[randSel].split('|')
    if eSp >= rM[11].parseInt:
      cat[0] = rM[0]
      cat[1] = mvData[randSel]

  return calcMove(cat, eType, false)

proc combat(eType: string, sS: array[6, int]) =
  proc event(cat: array[2, string]) =
    count += 1
    if eSe > spe or eSe == spe and rand(1) == 1:
      msg = enemyMove(eType)
      msg = &"{msg}\n{calcMove(cat, eType, true)}"
    else:
      msg = calcMove(cat, eType, true)
      msg = &"{msg}\n{enemyMove(eType)}"

  screen(sS, eType, msg)
  msg = ""
  let input = getch()
  case input
  of '1': 
    screen(sS, eType, msg)
    event([cInv(sCr, [sS[3], sS[4]], "move", atk), "move"])
  of '2':
    screen(sS, eType, msg)
    event([cInv(sCr, [sS[3], sS[4]], "move", mag), "move"])
  of '3', 'i': 
    screen(sS, eType, msg)
    event([cInv(sCr, [sS[3], sS[4]], "item", @["", ""]), "item"])
  else: discard
  if input != 'q' and eHp > 0: 
    combat(eType, sS)

proc initBattle*(xy: array[2, int], sS: array[6, int], bg: string) =
  let eType: string = absoluteFindEntity(xy)[0 .. ^4]
  if setStats(eType) == true:
    sCr = bg
    animation = true
    combat(eType, sS)

