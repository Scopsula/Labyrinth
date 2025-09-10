import terminal, strutils, strformat, random, os
import screen, autoGen, style, openMap

const
  tX: int = 10
  tY: int = 5

var 
  w: int = terminalWidth()
  h: int = terminalHeight() - 1
  x: int = 0
  y: int = 0

let 
  scX = w div tX
  scY = h div tY
  yD = (scY - 1) div 2 + 2
  xD = (scX - 1) div 2 + 2

var stats = """
health 50
thirst 50
"""

var
  health: int = 50
  thirst: int = 50
  h0: int = 0
  h1: int = 0
  h2: int = 0

let conf = readFile("../config").splitLines
let n = conf[0].split(' ')[1].parseInt
if conf[1].split(' ')[1] == "true": h0 = 1 
if conf[2].split(' ')[1] == "true" or not fileExists("../data"): 
  writeFile("../data", stats)
else:
  stats = readFile("../data")
  health = stats.splitLines[0].split(' ')[1].parseInt
  thirst = stats.splitLines[1].split(' ')[1].parseInt
if conf[3].split(' ')[1] == "true": h1 = 1
if conf[4].split(' ')[1] == "true": h2 = 1

randomize()
hideCursor()

var lv: int = 0
proc main() =
  if not dirExists(&"../chars/{lv}"): lv = 0
  writeFile("../loadedLevel/level", &"{lv}")
  newLevel()
  let valPoint: seq[array[2, int]] = autoGenLv(n)
  var map: string = readFile("../loadedLevel/map")
  let mYC: int = map.splitLines.len
  let mW: int = map.splitlines[0].len

  var 
    gX: int
    gY: int

  for i in 1 .. 2:
    var 
      po: array[2, int] = sample(valPoint)
      nx = po[0] - valPoint[^1][0]
      ny = po[1] - valPoint[^1][1]

    while map[ny * (mW + 1) + nx] != '*':
      po = sample(valPoint)
      nx = po[0] - valPoint[^1][0]
      ny = po[1] - valPoint[^1][1]
    if i == 1:
      map[ny * (mW + 1) + nx] = 'S'
      x = nx
      y = ny
    else:
      map[ny * (mW + 1) + nx] = 'X'
      gX = nx
      gY = ny

  var m: string = map.replace("\n", "")

  var visible: string
  proc loadChunk(lYB: int, uYB: int, lXB: int, uXB: int) =
    for i in lYB .. uYB:
      let lY: int = i * mW
      let l: string = m[lXB + lY .. uXB + lY]
      if i < uYB: visible = visible & l & "\n"
      else: visible = visible & l

  proc update() =
    visible = ""
    let pos = y * mW + x

    var 
      lXB: int
      uXB: int
      lYB: int
      uYB: int

    if x >= xD: lXB = pos - xD 
    else: lXB = pos - x
    if x + xD < mW: uXB = pos + xD
    else: uXB = pos - x + mW - 1
    if y >= yD: lYB = -yD
    else: lYB = -(yD + (y - yD))
    if y + yD <= mYC - 2: uYB = yD 
    else: uYB = yD - (y + yD - mYC + 2)

    loadChunk(lYB,uYB,lXB,uXB)

  proc getKey(): string =
    let fC = getch()
    if fC == '\e':
      if getch() == '[':
        case getch()
        of 'C': return "right"
        of 'D': return "left"
        of 'A': return "up"
        of 'B': return "down"
        else: discard
    else:
      return $fC

  var 
    up: bool = true
    bypass: bool = true
    closeMap: bool = false
    steps: int = 0

  while true:
    if h1 == 1:
      if steps == tX * tY and thirst > 0:
        let t1: string = &"thirst {thirst}"
        let t2: string = &"thirst {thirst - 1}"
        stats = stats.replace(t1, t2)
        writeFile("../data", stats)
        thirst -= 1
        steps = 0

    if up == true:
      m[y * mW + x] = 'S'
      update()
      m = sc(visible, [w, h, tX, tY], [x, y], [gX, gY, h0], [xD, yD, mW, mYC], m)
      up = false
    if bypass == true:
      bypass = false
      if refresh() == true or closeMap == true:
        closeMap = false
        up = true
    else:
      let input = getKey()
      case input
      of "a", "h", "left":
        if x - 1 >= 0:
          if m[y * mW + x - 1] != ' ':
            m[y * mW + x] = '9'
            x -= 1
            steps += 1
            up = true
      of "d", "l", "right":
        if x + 1 <= mW - 1:
          if m[y * mW + x + 1] != ' ':
            m[y * mW + x] = '9'
            x += 1
            steps += 1
            up = true
      of "w", "k", "up":
        if (y - 1) * mW + x >= 0:
          if m[(y - 1) * mW + x] != ' ':
            m[y * mW + x] = '9'
            y -= 1
            steps += 1
            up = true
      of "s", "j", "down":
        if (y + 1) * mW + x < m.len:
          if m[(y + 1) * mW + x] != ' ':
            m[y * mW + x] = '9'
            y += 1
            steps += 1
            up = true
      of "m":
        openMap([w, h], [x, y], m, mW, h0)
        while true:
          if getch() == 'm':
            break
        bypass = true
        closeMap = true
      of "r":
        lv -= 1
        break
      of "q":
        showCursor()
        quit(0)
      else: discard
      if m[y * mW + x] == 'X': break
  lv += 1
  bypass = true
  main()
main()

