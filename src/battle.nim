import os, strformat, strutils, terminal, random, sequtils
import entities, openInv, setMove

var 
  animation: bool = false
  count: int = 0
  msg: string
  sCr: string
  eAt: seq[string]
  eMa: seq[string]
  eHp: int
  eSt: float
  eMs: float
  eSe: int
  eSp: int
  eRe: seq[array[2, string]]
  eWe: seq[array[2, string]]
  eMo: seq[seq[string]]
  atk: seq[string]
  mag: seq[string]
  hpo: int
  str: float
  mSt: float
  spe: int
  spo: int
  res: seq[array[2, string]]
  wea: seq[array[2, string]]
  pMo: seq[seq[string]]

proc setStats(eType: string): bool =
  if not fileExists(&"../data/{eType}/stats"):
    return false

  let stats = readFile(&"../data/stats")
  hpo = stats.splitLines[2].split(' ')[1].parseInt
  str = stats.splitLines[3].split(' ')[1].parseFloat
  mSt = stats.splitLines[4].split(' ')[1].parseFloat
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
    eSt = stats.splitLines[3].split(' ')[1].parseFloat
    eMs = stats.splitLines[4].split(' ')[1].parseFloat
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
    let skipValue: int = (sS[0] div (sS[4] * sS[4])) + (sS[0] * sS[1] div (sS[3] * sS[3]))
    var skipCount: int = 0
    for y in 1 .. sS[1] - 2:
      for x in 1 .. sS[0] - 2:
        skipCount += 1
        writeChar(&"{sS[5]}/wall", [x, y], s3S)
        if skipCount >= skipValue:
          skipCount = 0
          discard execShellCmd("clear")
          echo sCr

    skipCount = 0
    for y in 1 .. sS[1] - 2:
      for x in 1 .. sS[0] - 2:
        skipCount += 1
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
        if skipCount >= skipValue:
          skipCount = 0
          discard execShellCmd("clear")
          echo sCr

    if fileExists &"../data/chars/{eType}/1":
      writeChar(&"{eType}/1", [eLX - 1, eLN + 0], s3S)
      writeChar(&"{eType}/2", [eLX + 0, eLN + 0], s3S)
      writeChar(&"{eType}/3", [eLX + 1, eLN + 0], s3S)
      writeChar(&"{eType}/4", [eLX - 1, eLN + 1], s3S)
      writeChar(&"{eType}/5", [eLX + 0, eLN + 1], s3S)
      writeChar(&"{eType}/6", [eLX + 1, eLN + 1], s3S)
      writeChar(&"{eType}/7", [eLX - 1, eLN + 2], s3S)
      writeChar(&"{eType}/8", [eLX + 0, eLN + 2], s3S)
      writeChar(&"{eType}/9", [eLX + 1, eLN + 2], s3S)

    if fileExists &"../data/chars/{eType}/t0":
      writeChar(&"{eType}/t0", [eLX + 1, eLN - 1], s3S)
      writeChar(&"{eType}/t1", [eLX + 2, eLN - 1], s3S)
      writeChar(&"{eType}/t2", [eLX + 3, eLN - 1], s3S)
      writeChar(&"{eType}/t3", [eLX + 2, eLN + 0], s3S)
      writeChar(&"{eType}/t4", [eLX + 3, eLN + 0], s3S)
      writeChar(&"{eType}/t5", [eLX + 2, eLN + 1], s3S)
      writeChar(&"{eType}/t6", [eLX + 3, eLN + 1], s3S)
      writeChar(&"{eType}/t7", [eLX + 2, eLN + 2], s3S)
      writeChar(&"{eType}/t8", [eLX + 3, eLN + 2], s3S)

    animation = false

  proc wrLine(line: string, num: int, xD: int, ovr: int) =
    var cD: int = ovr * (sS[2] + 1)
    if line.len < sS[3]:
      cD += (sS[3] - line.len) div 2
    let lB: int = (num * sS[4]) * (sS[2] + 1) + (xD * sS[3]) + cD
    let uB: int = lB + line.len - 1
    scr[lB .. uB] = line

  var clLine: string
  for i in 0 .. (sS[3] div 2) * (sS[0] - 3) - 1:
    clLine = &"{clLine} "
  for i in 0 .. sS[4] + 3:
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

proc calcModifier(data: seq[string], player: bool, eName: string): string =
  var mMs: string

  if data != @[]:
    case data[1]:
    of "health":
      if player == true:
        hpo += data[2].parseInt
      else:
        eHp += data[2].parseInt
    of "strength":
      if player == true:
        str += data[2].parseFloat
      else:
        eSt += data[2].parseFloat
    of "mStrength":
      if player == true:
        mSt += data[2].parseFloat
      else:
        eMs += data[2].parseFloat
    of "speed":
      if player == true:
        spe += data[2].parseInt
      else:
        eSe += data[2].parseInt
    of "stamina":
      if player == true:
        spo += data[2].parseInt
      else:
        eSp += data[2].parseInt
    if player == true:
      if data[2].parseInt < 0:
        mMs = &"You lost {data[2][1 .. ^1]} {data[1]} due to {data[0]}"
      else:
        mMs = &"You gained {data[2][1 .. ^1]} {data[1]} due to {data[0]}"
    else:
      if data[2].parseInt < 0:
        mMs = &"{eName} lost {data[2][1 .. ^1]} {data[1]} due to {data[0]}"
      else:
        mMs = &"{eName} gained {data[2][1 .. ^1]} {data[1]} due to {data[0]}"
    return mMs

  elif pMo.len > 0:
    var disp: int = 0
    for i in 0 .. pMo.len - 1:
      if pMo[i + disp][3] == "0" or pMo[i + disp][4] == "-1":
        pMo.del(i + disp)
        disp -= 1
    if pMo.len == 0:
      return ""

  elif eMo.len > 0:
    var disp: int = 0
    for i in 0 .. eMo.len - 1:
      if eMo[i + disp][3] == "0" or eMo[i + disp][4] == "-1":
        eMo.del(i + disp)
        disp -= 1
    if eMo.len == 0:
      return ""

  else:
    return ""

  for m in 0 .. pMo.len - 1:
    if pMo[m][4] == "n" and pMo[m][3] != "n" or pMo[m][4] == "0":
      var mV: int = pMo[m][2].parseInt
      if pMo[m][4] == "0":
        mV = mV * -1
      case pMo[m][1]:
      of "health":
        hpo += mV
      of "strength":
        str += mV.toFloat
      of "mStrength":
        mSt += mV.toFloat
      of "speed":
        spe += mV
      of "stamina":
        spo += mV
      if pMo[m][3] != "n":
        let dur: int = pMo[m][3].parseInt
        pMo[m][3] = &"{dur - 1}"
      if pMo[m][4] == "0":
        pMo[m][4] = "-1"
        if mV < 0:
          var nm: string = &"{pMo[m][0]} ended, you lost {pMo[m][2][1 .. ^1]} {pMo[m][1]}"
          nm[0] = nm[0].toUpperAscii
          mMs = &"{mMs}\n{nm}"
        else: 
          var nm: string = &"{pMo[m][0]} ended, you gained {pMo[m][2][1 .. ^1]} {pMo[m][1]}"
          nm[0] = nm[0].toUpperAscii
          mMs = &"{mMs}\n{nm}"
      elif pMo[m][2].parseInt < 0:
        mMs = &"{mMs}\nYou lost {pMo[m][2][1 .. ^1]} {pMo[m][1]} due to {pMo[m][0]}"
      else: 
        mMs = &"{mMs}\nYou gained {pMo[m][2][1 .. ^1]} {pMo[m][1]} due to {pMo[m][0]}"
    elif pMo[m][4] != "n":
      let dur: int = pMo[m][4].parseInt
      pMo[m][4] = &"{dur - 1}"

  for m in 0 .. eMo.len - 1:
    if eMo[m][4] == "n" and eMo[m][3] != "n" or eMo[m][4] == "0":
      var mV: int = eMo[m][2].parseInt
      if eMo[m][4] == "0":
        mV = mV * -1
      case eMo[m][1]:
      of "health":
        eHp += mV
      of "strength":
        eSt += mV.toFloat
      of "mStrength":
        eMs += mV.toFloat
      of "speed":
        eSe += mV
      of "stamina":
        eSp += mV
      if eMo[m][3] != "n":
        let dur: int = eMo[m][3].parseInt
        eMo[m][3] = &"{dur - 1}"
      if eMo[m][4] == "0":
        eMo[m][4] = "-1"
        if mV < 0:
          var nm: string =  &"{eMo[m][0]} ended, {eName} lost {eMo[m][2][1 .. ^1]} {eMo[m][1]}"
          nm[0] = nm[0].toUpperAscii
          mMs = &"{mMs}\n{nm}"
        else:
          var nm: string =  &"{eMo[m][0]} ended, {eName} gained {eMo[m][2][1 .. ^1]} {eMo[m][1]}"
          nm[0] = nm[0].toUpperAscii
          mMs = &"{mMs}\n{nm}"
      elif eMo[m][2].parseInt < 0:
        mMs = &"{mMs}\n{eName} lost {eMo[m][2][1 .. ^1]} {eMo[m][1]} due to {eMo[m][0]}"
      else:
        mMs = &"{mMs}\n{eName} gained {eMo[m][2][1 .. ^1]} {eMo[m][1]} due to {eMo[m][0]}"
    elif eMo[m][4] != "n":
      let dur: int = eMo[m][4].parseInt
      eMo[m][4] = &"{dur - 1}"

  if mMs == "":
    return mMs
  else:
    return mMs[1 .. ^1]

proc addModifier(id: string, player: bool, eName: string): string =
  var mData: seq[seq[string]]
  let buffs = readFile("../data/moves/buff").splitLines
  for i in 0 .. buffs.len - 1:
    if buffs[i].split(' ')[0] == id:
      mData.add(buffs[i].split(' '))
  let debuffs = readFile("../data/moves/debuff").splitLines
  for i in 0 .. buffs.len - 1:
    if debuffs[i].split(' ')[0] == id:
      mData.add(debuffs[i].split(' '))
  
  if mData.len > 0:
    var n: string
    for m in 0 .. mData.len - 1:
      if mData[m][3] == "n":
        if player == true:
          var c2: int = 0
          for i in 0 .. pMo.len - 1:
            if pMo[i][0 .. 1] == mData[m][0 .. 1]:
              if pMo[i][4] != "-1":
                c2 += 1
          if c2 == 0:
            n = &"{n}{calcModifier(mData[m], player, eName)}\n"
          else:
            var mn: string = &"{mData[m][0]} is already active on you, extended"
            mn[0] = mn[0].toUpperAscii
            n = &"{n}{mn}\n"
        else:
          var c2: int = 0
          for i in 0 .. eMo.len - 1:
            if eMo[i][0 .. 1] == mData[m][0 .. 1]:
              if eMo[i][4] != "-1":
                c2 += 1
          if c2 == 0:
            n = &"{n}{calcModifier(mData[m], player, eName)}\n"
          else:
            var mn: string = &"{mData[m][0]} is already active on {eName}, extended"
            mn[0] = mn[0].toUpperAscii
            n = &"{n}{mn}\n"

      if mData[m][4] == "n" and mData[m][3] == "n":
        discard

      elif player == true:
        if pMo.len > 0:
          for i in 0 .. pMo.len - 1:
            if pMo[i][0 .. 1] == mData[m][0 .. 1]:
              pMo.del(i)
              break
        pMo.add(mData[m])

      else:
        if eMo.len > 0:
          for i in 0 .. eMo.len - 1:
            if eMo[i][0 .. 1] == mData[m][0 .. 1]:
              eMo.del(i)
              break
        eMo.add([mData[m]])

      if mData[m][3] == "n":
        if m == mData.len - 1:
          return n[0 .. ^2]

  return ""

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
    dPSt: float
    dMSt: float

  if player == true:
    wSet = eWe
    rSet = eRe
    dPSt = str
    dMSt = mSt

  else:
    wSet = wea
    rSet = res
    dPSt = eSt
    dMSt = eMs

  let 
    nat: float = mSv[2].parseFloat
    mat: float = mSv[3].parseFloat
    pRds: int = mSv[10].parseInt
    mRds: int = mSv[11].parseInt

  var mMult: float = 1.0
  var pMult: float = 1.0
  for i in 1 .. 100:
    if wSet.contains([dType, &"{i}"]):
      mMult += (i / 100)
      break
    if rSet.contains([dType, &"{i}"]):
      mMult -= (i / 100)
      break
    
  if mat > 0 and nat > 0:
    for i in 1 .. 100:
      if wSet.contains(["physical", &"{i}"]):
        pMult += (i / 100)
        break
      if rSet.contains(["physical", &"{i}"]):
        pMult -= (i / 100)
        break
  else:
    pMult = mMult

  if nat == 0:
    pMult = 0
  if mat == 0:
    mMult = 0

  let phyDam: int = ((nat + rand(-pRds .. pRds).toFloat + dPSt) * pMult).toInt
  let magDam: int = ((mat + rand(-mRds .. mRds).toFloat + dMSt) * mMult).toInt

  var damage: int = phyDam + magDam
  if damage < 0: damage = 0

  var eName: string = eType[9 .. ^2]
  eName[0] = eName[0].toUpperAscii

  if rand(1 .. 100) <= mSv[7].parseInt:  
    var opposite: bool = false
    if player == false:
      opposite = true

    var rMs: string
    if mSv[5] != "null":
      if rand(1 .. 100) <= mSv[8].parseInt:
        rMs = &"{addModifier(mSv[5], player, eName)}"

    if mSv[6] != "null":
      if rand(1 .. 100) <= mSv[9].parseInt:
        let MOD2U: string = addModifier(mSv[6], opposite, eName)
        if MOD2U != "":
          rMs = &"{rMs}\n{MOD2U}"

    if player == true:
      eHp -= damage
    else:
      hpo -= damage

    if rMs == "":
      rMs = mSv[1]
    else:
      rMs = &"{mSv[1]}\n{rMs}"

    if player == true:
      spo -= mSv[12].parseInt
      rMS = rMS.replace("%user%", "You")
      rMS = rMS.replace("%target%", eName)
    else:
      eSp -= mSv[12].parseInt
      rMS = rMS.replace("%user%", eName)
      rMS = rMS.replace("%target%", "you")

    rMS = rMS.replace("%dmg%", &"{damage}")
    rMS = rMS.replace("%type%", dType)
    return rMS
  else:
    if player == true:
      return "You missed"
    else:
      return &"{eName} missed"

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
    if eSp >= mV[12].parseInt:
      if mV[0] == move:
        cat = [move, mvData[i]]

  if cat[0] == "":
    for i in 0 .. mvData.len - 1:
      let mV = mvData[i].split('|')
      if eSp >= mV[12].parseInt:
        for r in 1 .. 100:
          if wea.contains([mV[4], &"{r}"]):
            cat = [mV[0], mvData[i]]
            break

  if cat[0] == "":
    var chk: seq[int]
    for i in 0 .. mvData.len - 1:
      var randSel: int = rand(0 .. mvData.len - 1)
      while chk.contains(randSel):
        randSel = rand(0 .. mvData.len - 1)
      
      chk.add(randSel)
      let rM = mvData[randSel].split('|')
      if eSp >= rM[12].parseInt:
        for r in 1 .. 100:
          if not res.contains([rM[4], &"{r}"]):
            cat = [rM[0], mvData[randSel]]
            break

  if cat[0] == "":
    let randSel: int = rand(0 .. mvData.len - 1)
    let rM = mvData[randSel].split('|')
    if eSp >= rM[12].parseInt:
      cat = [rM[0], mvData[randSel]]

  if cat[0] == "":
    for i in 0 .. mvData.len - 1:
      let aM = mvData[i].split('|')
      if eSP >= aM[12].parseInt:
        cat = [aM[0], mvData[i]]

  if cat[0] == "":
    cat = ["rest", "move"]

  return calcMove(cat, eType, false)

proc combat(eType: string, sS: array[6, int]) =
  proc event(cat: array[2, string]) =
    if cat[0] != "":
      count += 1
      if eSe > spe or eSe == spe and rand(1) == 1:
        msg = enemyMove(eType)
        msg = &"{msg}\n{calcMove(cat, eType, true)}"
      else:
        msg = calcMove(cat, eType, true)
        msg = &"{msg}\n{enemyMove(eType)}"

      var eName: string = eType[9 .. ^2]
      eName[0] = eName[0].toUpperAscii
      msg = &"{msg}\n{calcModifier(@[], false, eName)}"

  screen(sS, eType, msg)
  msg = ""
  let input = getch()
  case input
  of '1': 
    screen(sS, eType, msg)
    event([cInv(sCr, [sS[3], sS[4]], "move", concat(atk, mag)), "move"])
  of '2':
    screen(sS, eType, msg)
    event(["guard", "move"])
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
    msg = ""
    count = 0
    pMo.setLen(0)
    eMo.setLen(0)
    combat(eType, sS)

