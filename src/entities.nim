import strformat, strutils, random, std/monotimes, times, os, sequtils
import custGen

const dir: seq[array[2, int]] = @[[1, 0], [-1, 0], [0, 1], [0, -1]]

var 
  rValue: float = cEGen(0)
  eloc: seq[array[3, int]]
  eTime: seq[MonoTime]
  eTypes: seq[array[3, string]]
  deadZones: seq[seq[array[2, int]]]
  eSelect: int
  eCMult: float
  eChance: int

let aE = toSeq(walkDir("../data/entities", relative=true))

proc setEData(lv: int) =
  for i in 0 .. aE.len - 1:
    if fileExists(&"../data/chars/entities/{aE[i][1]}/map"):
      let eDa: string = readFile(&"../data/entities/{aE[i][1]}/stats")
      let eSl: seq[string] = eDa.splitLines
      var eCm: string
      var mSe: string
      for i in 0 .. eSl.len:
        let data: seq[string] = eSl[10 + i].split(' ')
        case data[0]
        of "END":
          eCM = "0"
          break
        of "A":
          eCm = data[1]
          mSe = data[2]
          break
        if lv == data[0].parseInt:
          eCm = data[1]
          mSe = data[2]
          break
      if eCM != "0":
        eTypes.add([aE[i][1], mSe, eCm])
setEData(0)

proc selEn() =
  eSelect = rand(0 .. eTypes.len - 1)
  eCMult = 1 / eTypes[eSelect][2].parseFloat
  eChance  = (rValue * eCMult).toInt
selEn()

proc resetEntities*(lv: int) =
  eloc.setLen(0)
  eTypes.setLen(0)
  eTime.setLen(0)
  deadZones.setLen(0)
  rValue = cEGen(lv)
  setEData(lv)
  if eTypes.len > 0:
    selEn()

proc deleteEntity*(xy: array[2, int]) =
  for i in 0 .. eTypes.len - 1:
    if eloc.contains([xy[0], xy[1], i]):
      let d: int = find(eloc, [xy[0], xy[1], i])
      eloc.delete(d)
      eTime.delete(d)
      deadZones.delete(d)

proc absoluteFindEntity*(xy: array[2, int]): string =
  for i in 0 .. eTypes.len - 1:
    if eloc.contains([xy[0], xy[1], i]):
      return &"entities/{eTypes[i][0]}/map"

proc findEntity*(v: string, xy: array[2, int], exy: array[2, int]): string =
  let rows = v.splitLines
  var coords: array[2, int]
  for y in 0 .. rows.len - 1:
    for x in 0 .. rows[0].len - 1:
      if rows[y][x] == 'S':
        coords = [x, y]

  let wx: int = xy[0] - coords[0] + exy[0]
  let wy: int = xy[1] - coords[1] + exy[1]

  return absoluteFindEntity([wx, wy])

proc moveEntities*(xy: array[2, int], m: string, mW: int): array[2, string] =
  var map: string = m
  var update: bool = false
  if eloc.len > 0:
    for i in 0 .. eloc.len - 1:
      let eT: float = eTypes[eloc[i][2]][1].parseFloat
      if (getMonoTime() - eTime[i]).inMilliseconds().toFloat >= eT * 1000:
        update = true
        eTime[i] = getMonoTime()
        var eM: string = map.replace("E", " ")

        if deadZones[i].len > 0:
          if deadZones[i].contains(xy):
            deadZones[i].setLen(0)
          else:
            for r in 0 .. deadZones[i].len - 1:
              eM[deadZones[i][r][1] * mW + deadZones[i][r][0]] = ' '

        var eXY: array[2, int] = [eloc[i][0], eloc[i][1]]

        let chk: int = eXY[1] * mW + eXY[0]
        if map[chk] != 'X': map[chk] = '*'
        if (eXY[1] + 1) * mW + eXY[0] + 1 > map.len - 1: discard
        elif (eXY[1] - 1) * mW + eXY[0] - 1 < 0: discard
        elif eXY[0] < xy[0] and eM[chk + 1] != ' ':
          eXY[0] += 1
        elif eXY[0] > xy[0] and eM[chk - 1] != ' ':
          eXY[0] -= 1 
        elif eXY[1] < xy[1] and eM[chk + mW] != ' ':
          eXY[1] += 1
        elif eXY[1] > xy[1] and eM[chk - mW] != ' ':
          eXY[1] -= 1
        else:
          if eM[chk + 1] == ' ':
            if eM[chk - 1] == ' ':
              if eM[chk + mW] == ' ':
                if eM[chk - mW] == ' ':
                  let mv: array[2, int] = sample(dir)
                  if map[chk + mv[1] * mW + mv[0]] != ' ':
                    if map[chk + mv[1] * mW + mv[0]] != 'E':
                      deadZones[i].add([eXY[0], eXY[1]]) 
                      eXY[0] += mv[0]
                      eXY[1] += mv[1]

          deadZones[i].add([eXY[0], eXY[1]]) 
          let mv: array[2, int] = sample(dir)
          if eM[chk + mv[1] * mW + mv[0]] != ' ':
            eXY[0] += mv[0]
            eXY[1] += mv[1]

        eloc[i][0] = eXY[0]
        eloc[i][1] = eXY[1]

        map[eXY[1] * mW + eXY[0]] = 'E'
  return [map, &"{update}"]

proc entities*(v: string, mS: array[2, string], xy: array[2, int]): array[2, string] =
  if eTypes.len == 0:
    return [v, mS[1]]

  var visible: string = v
  var rows = v.splitLines
  var coords: array[2, int]
  let lw: int = rows[0].len
  for y in 0 .. rows.len - 1:
    for x in 0 .. lw - 1:
      if rows[y][x] == 'S':
        coords = [x, y]

  var map: string = mS[1]
  let mW: int = mS[0].parseInt
  for y in 0 .. rows.len - 1:
    for x in 0 .. lw - 1:
      if y == 0 or y == rows.len - 1 or x == 0 or x == lw - 1:
        if rows[y][x] == '*':
          if rand(1 .. eChance) == 1:
            let wx: int = xy[0] - coords[0] + x
            let wy: int = xy[1] - coords[1] + y
            eloc.add([wx, wy, eSelect])
            eTime.add(getMonoTime())
            deadZones.setLen(eloc.len)
            visible[y * (lw + 1) + x] = 'E'
            map[wY * mW + wx] = 'E'
            selEn()

  return [visible, map]

