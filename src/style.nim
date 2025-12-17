import strutils, strformat, random, os

proc refresh*(lv: int): bool =
  if fileExists(&"../data/levels/{lv}"):
    let rData = readFile(&"../data/levels/{lv}")
    if rData.contains("refresh"):
      return true

let loot: string = readFile("../data/config").splitLines[5].split(' ')[1]

proc getSize(lv: int): array[2, int] =
  let sData = readFile(&"../data/levels/{lv}").splitLines
  for i in 0 .. sData.len - 1:
    let size = sData[i].split('.')
    if size[0] == "halls":
      return [size[1].parseInt, size[2].parseInt]

var aData: seq[string]
var rValues: seq[int]
proc audioZone*(xy: array[2, int], t: array[2, int], lv: int): string =
  var rAudio: array[2, string]
  for i in 0 .. aData.len - 1:
    let lAd = aData[i].split(' ')
    if lAd[0] == &"{lv}":
      rAudio[0] = &"{lv}/{lAd[1]}"
    if lAd[0] == &"{lv}|Hall":
      rAudio[1] = &"{lv}/{lAd[1]}"
  if rValues.len > 0:
    let size: array[2, int] = getSize(lv)
    let nx: int = xy[0] div size[0]
    let ny: int = xy[1] div size[1]
    if rValues[nx + (ny * rValues[0]) + 1] == 1:
      return rAudio[1]
  return rAudio[0]

var
  eC: float = 10000
  cel: bool
  cor: bool
  halls: bool
  wM: bool
  doOV: bool
  doDH: bool
  link: bool
  cD: array[3, char]
  h1: bool = false
  h2: bool = false
  b1: bool = false
  b2: bool = false
  oVdata: seq[string]
  celData: seq[string]
  corData: seq[string]
  hData: seq[string]
  wMdata: seq[char]
  cList: seq[char]

proc setRValues*(lv: int, s: array[4, int]) =
  if fileExists(&"../data/audio/{lv}/match"):
    aData = readFile(&"../data/audio/{lv}/match").splitLines
  else:
    aData = @[&"{lv} {lv}"]

  cel = false
  cor = false
  halls = false
  wM = false
  doOV = false
  doDH = false

  var rSV: array[3, int] = [-1, 0, 0]
  if fileExists(&"../data/levels/{lv}"):
    let data = readFile(&"../data/levels/{lv}").splitLines
    for i in 0 .. data.len - 1:
      if data[i].len > 1:
        let dLine = data[i].split('.')
        case dLine[0]
        of "ceilings": 
          cel = true
          celData.setLen(0)
          for j in 1 .. dLine.len - 1:
            celData.add(dLine[j])
          if celData[1] == "true":
            b1 = true

        of "corridors": 
          cor = true
          corData.setLen(0)
          if dLine[1] == "true":
            b2 = true

        of "halls": 
          halls = true
          hData.setLen(0)
          for j in 3 .. dLine.len - 1:
            hData.add(dLine[j])
          if hData[0] == "true":
            h1 = true
          if hData[1] == "true":
            h2 = true
          cD = [hData[2][0], hData[3][0], hData[4][0]]

        of "writeMap":
          wM = true
          wMdata.setLen(0)
          for j in 1 .. dLine.len - 1:
            wmData.add(dLine[j][0])

        of "delHalls":
          doDH = true
          if dLine[1] == "true": link = true
          else: link = false

        of "overlay":
          doOV = true
          oVdata.setLen(0)
          for j in 1 .. dLine.len - 1:
            oVdata.add(dLine[j])

        of "rSV":
          for i in 0 .. 2:
            rSV[i] = dLine[i + 1].parseInt

        of "eC":
          eC = dLine[1].parseFloat
        else: discard

  rValues.setLen(0)
  cList.setLen(0)
  if rSV[0] != -1:
    let size: array[2, int] = getSize(lv)
    let rX: int = s[1] div size[0]
    let rY: int = s[0] div size[1]
    rValues.add(rX)
    for i in 0 .. (rX + 1) * (rY + 1):
      if rand(rSV[0] .. rSV[1]) <= rSV[2]:
        rValues.add(1)
      else:
        rValues.add(0)

proc returnEC*(): float =
  return eC

proc noCorner(nx: int, ny: int) =
  let n: int = nx + (ny * rValues[0]) + 1
  if n - rValues[0] - 1 > 0:
    if n - 1 < rValues.len:
      if rValues[n - rValues[0] - 1] == 1:
        if rValues[n - 1] == 0:
          if rValues[n - rValues[0]] == 0:
            rValues[n - rValues[0] - 1] = 0

  if n - rValues[0] > 0:
    if n + 1 < rValues.len:
      if rValues[n - rValues[0] + 1] == 1:
        if rValues[n + 1] == 0:
          if rValues[n - rValues[0]] == 0:
            rValues[n - rValues[0] - 1] = 0

  if n - 1 > 0:
    if n + rValues[0] < rValues.len:
      if rValues[n + rValues[0] - 1] == 1:
        if rValues[n - 1] == 0:
          if rValues[n + rValues[0]] == 0:
            rValues[n + rValues[0] - 1] = 0

  if n + 1 > 0:
    if n + rValues[0] + 1 < rValues.len:
      if rValues[n + rValues[0] + 1] == 1:
        if rValues[n + 1] == 0:
          if rValues[n + rValues[0]] == 0:
            rValues[n + rValues[0] + 1] = 0

var hSize: array[2, int]
var zton: string = "`!@#$%^&*()_+-=[];{}:|<>?,."
proc adjustVisible*(v: string, xy: array[2, int], level: int, mS: array[2, string], t: array[2, int]): array[2, string] =
  var visible: string = v 
  var map = mS[1]
  var rows = v.splitLines
  let lw = rows[0].len
  var coords: array[2, int]

  proc setCoords(): array[2, int] =
    for y in 0 .. rows.len - 1:
      for x in 0 .. lw - 1:
        if rows[y][x] == 'S':
          return [x, y]

  proc writeMap(n: seq[char], coords: array[2, int]) =
    let mW = mS[0].parseInt
    for y in 1 .. rows.len - 2:
      for x in 1 .. lw - 2:
        let uC: char = visible[y * (lw + 1) + x]
        if n.contains(uC):
          let wx: int = xy[0] - coords[0] + x
          let wy: int = xy[1] - coords[1] + y
          map[wy * mW + wx] = uC

  proc ceilings(y: int, x: int, c: char, tW: bool) =
    var incr: int = 0
    let c1: char = rows[y][x]
    let c2: char = visible[y * (lw + 1) + x]
    var clear: bool = false
    if c1 == c or c2 == c:
      clear = true
    if c1 == ' ' and c2 == ' ':
      clear = true
    if clear == true:
      var r = v.replace(c, ' ').splitLines
      if r[y + 1][x] == ' ':
        if y == r.len - 2:
          incr += 1
        elif r[y + 2][x] != ' ':
          incr += 1
        if r[y][x - 1] != ' ' or r[y + 1][x - 1] != ' ':
          incr += 2
        if r[y][x + 1] != ' ' or r[y + 1][x + 1] != ' ':
          incr += 4
        if rows[y - 1][x] != ' ':
          incr += 8
        let c = "abcdefghijklmnop"[incr]
        visible[y * (lw + 1) + x] = c
      elif r[y - 1][x] != ' ' and tW == true:
        if r[y][x - 1] != ' ': 
          visible[y * (lw + 1) + x] = '0'
          if r[y][x + 1] != ' ':
            visible[y * (lw + 1) + x] = '3'
        elif r[y][x + 1] != ' ': 
          visible[y * (lw + 1) + x] = '1'
        else: 
          visible[y * (lw + 1) + x] = '2'
      elif r[y + 1][x] != ' ' and tW == true:
        if r[y][x - 1] != ' ': 
          visible[y * (lw + 1) + x] = '4'
          if r[y][x + 1] != ' ':
            visible[y * (lw + 1) + x] = '6'
        elif r[y][x + 1] != ' ': 
          visible[y * (lw + 1) + x] = '5'

  proc corridors(y: int, x: int, r3e: bool) =
    if rows[y][x] == ' ':
      var incr: int = 0
      if rows[y + 1][x] != ' ':
        incr += 1
      if rows[y][x - 1] != ' ':
        incr += 2
      if rows[y][x + 1] != ' ':
        incr += 4
      if rows[y - 1][x] != ' ':
        incr += 8
      if incr == 0:
        if rows[y + 1][x - 1] != ' ':
          incr = 16 
        elif rows[y + 1][x + 1] != ' ':
          incr = 17
        elif rows[y - 1][x - 1] != ' ':
          incr = 18
        elif rows[y - 1][x + 1] != ' ':
          incr = 19
      let c = "abcdefghijklmnopqrst"[incr]
      if r3e == true:
        case c
        of 'g', 'h', 'j', 'l', 'n', 'o', 'p':
          visible[y * (lw + 1) + x] = '*'
        else:
          visible[y * (lw + 1) + x] = c
      else:
        visible[y * (lw + 1) + x] = c

  proc halls(y: int, x: int, s: array[2, int], c: array[3, char], nC: array[2, bool]): bool =
    if rows[y][x] == ' ' or rows[y][x] == c[2] or c[0] != ' ':
      var nx: int = (xy[0] - coords[0] + x) div s[0]
      var ny: int = (xy[1] - coords[1] + y) div s[1]
      if rValues[nx + (ny * rValues[0]) + 1] == 1:
        if nC[0] == true:
          noCorner(nx, ny)
        let cx: int = xy[0] - coords[0] + x - (nx * s[0])
        let cy: int = xy[1] - coords[1] + y - (ny * s[1])
        if cx mod 2 == 0 or cy mod 2 == 0:
          if rows[y][x] == ' ' or rows[y][x] == c[2]:
            if c[1] != ' ' and loot == "true" and rand(1 .. 500) == 1:
              visible[y * (lw + 1) + x] = c[1]
            else:
              visible[y * (lw + 1) + x] = '*'
        else:
          if nC[1] == true:
            if rows[y][x] == ' ':
              visible[y * (lw + 1) + x] = c[0]
          else:
            visible[y * (lw + 1) + x] = c[0]
        return true
    return false

  proc delHalls(s: array[2, int], doLink: bool) =
    var dV: seq[int]
    var kV: seq[int]
    var link: seq[int]
    let l = rValues.len - 1
    proc linkHalls(n: int) =
      for i in 1 .. l:
        if n + i > l:
          break
        if rValues[n + i] == 1:
          if not kV.contains(n + i):
            kV.add(n + i)
            link.add(n + i)
        else:
          break
      for i in 1 .. l:
        if n - i < 0:
          break
        if rValues[n - i] == 1:
          if not kV.contains(n - i):
            kV.add(n - i)
            link.add(n - i)
        else:
          break
      for i in 1 .. l:
        if n + (i * rValues[0]) > l:
          break
        if rValues[n + (i * rValues[0])] == 1:
          if not kV.contains(n + (i * rValues[0])):
            kV.add(n + (i * rValues[0]))
            link.add(n + (i * rValues[0]))
        else:
          break
      for i in 1 .. l:
        if n - (i * rValues[0]) < 0:
          break
        if rValues[n - (i * rValues[0])] == 1:
          if not kv.contains(n - (i * rValues[0])):
            kV.add(n - (i * rValues[0]))
            link.add(n - (i * rValues[0]))
        else:
          break

    for y in 1 .. rows.len - 2:
      for x in 1 .. lw - 2:
        let nx: int = (xy[0] - coords[0] + x) div s[0]
        let ny: int = (xy[1] - coords[1] + y) div s[1]
        let n: int = nx + (ny * rValues[0]) + 1
        if rValues[n] == 1:
          if not dV.contains(n):
            dV.add(n)
          if rows[y][x] != ' ':
            if not kV.contains(n):
              kV.add(n)
              if doLink == true:
                link.setLen(0)
                link.add(n)
                while true:
                  let ll: int = link.len
                  for i in 0 .. link.len - 1:
                    linkHalls(link[i])
                  if ll == link.len:
                    break

    for i in 0 .. kV.len - 1:
      if dV.contains(kV[i]):
        let d: int = find(dV, kV[i])
        dV.del(d)
    for i in 0 .. dV.len - 1:
      rValues[dV[i]] = 0

  proc overlay(y: int, x: int, d: char, target: string) =
    if rows[y][x] == d or visible[y * (lw + 1) + x] == d:
      var tile: string
      let c: char = visible[y * (lw + 1) + x]
      let match: seq[string] = readFile(&"../data/chars/{level}/match").splitLines
      for i in 0 .. match.len - 1:
        if match[i].len > 0:
          if match[i][0] == c:
            if match[i].len > 0:
              let selTile = match[i].split(' ')[1]
              tile = readFile(&"../data/chars/{level}/{selTile}")
              break
      if tile.len > 0:
        if not cList.contains(c):
          cList.add(c)
        var nC: char
        for i in 0 .. cList.len - 1:
          if c == cList[i]:
            nC = zton[i]
            break
        if not fileExists(&"../data/chars/temp/{nC}"):
          let tg = readFile(&"../data/chars/{target}")
          for i in 0 .. tg.len - 1:
            if tg[i] != ' ':
              if tg[i] == 'X':
                tile[i] = ' '
              else:
                tile[i] = tg[i]
          writeFile(&"../data/chars/temp/{nC}", tile)
        visible[y * (lw + 1) + x] = nC

  if halls == true:
    coords = setCoords()
    hSize = getSize(level)
    if doDH == true:
      delHalls(hSize, link)
      
  for y in 1 .. rows.len - 2:
    for x in 1 .. lw - 2:
      var b0: bool = false
      if halls == true:
        b0 = halls(y, x, hSize, cd, [h1, h2])

      if cel == true and b0 == false:
        ceilings(y, x, celData[0][0], b1)

      elif cor == true and b0 == false:
        corridors(y, x, b2)
      
      if doOV == true:
        if b0 == false or oVdata[2] == "true": 
          overlay(y, x, oVdata[0][0], oVdata[1])

  if wM == true:
    if halls == false:
      coords = setCoords()
    writeMap(wMdata, coords)

  return [visible, map]

