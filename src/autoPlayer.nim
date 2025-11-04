import illwill, strutils, strformat, random, os, times, std/monotimes
import screen, autoGen, style, openMap, openInv, entities, upStats, battle

const
  tX: int = 10
  tY: int = 5

var 
  x: int = 0
  y: int = 0
  h0: int = 0
  h1: int = 0
  h2: int = 0
  h3: int = 0
  h4: int = 0

let
  w: int = terminalWidth()
  h: int = terminalHeight() - 1
  scX: int = w div tX
  scY: int = h div tY
  yD: int = (scY - 1) div 2 + 2
  xD: int = (scX - 1) div 2 + 2

var stats = """
normal swing riser
magic null
health 50
strength 3 
mStrength 3
speed 50
stamina 50
resists light|25 physical|5
weaknesses dark|50
thirst 50
level 0
"""

let conf = readFile("../data/config").splitLines
let n = conf[0].split(' ')[1].parseInt
if conf[1].split(' ')[1] == "true": h0 = 1 
if conf[2].split(' ')[1] == "true":
  removeDir("../data/items")
  createDir("../data/items")
  writeFile("../data/stats", stats)
if conf[3].split(' ')[1] == "true": h1 = 1
if conf[4].split(' ')[1] == "true": h2 = 1
if conf[9].split(' ')[1] == "true": h3 = 1
if conf[10].split(' ')[1] == "true": h4 = 1
let sV: int = conf[7].split(' ')[1].parseInt
let eT: float = conf[8].split(' ')[1].parseFloat

removeDir("../data/chars/temp")
createDir("../data/chars/temp")

randomize()
illwillInit()
hideCursor()

var lv: int = 0
proc main() =
  if not dirExists(&"../data/chars/{lv}"): lv = 0
  writeFile("../data/level", &"{lv}")
  newLevel()
  let valPoint: seq[array[2, int]] = autoGenLv(n)
  var map: string = readFile("../data/map")
  let sMap: string = map
  let mYC: int = map.splitLines.len
  let mW: int = map.splitlines[0].len

  var gX: int
  var gY: int
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

  var 
    up: bool = true
    bypass: bool = true
    closeMenu: bool = false
    steps: int = 0
    bg: string
    msg: string
    time = getMonoTime()

  while true:
    msg = ""
    if h1 == 1:
      if steps == tX * tY or steps == 3:
        let tUpdate: array[2, string] = tDrain(steps, tY * tX)
        msg = tUpdate[0]
        steps = tUpdate[1].parseInt

    msg = iUpdate(m[y * mW + x])

    if h2 == 1:
      if (getMonoTime() - time).inMilliseconds().toFloat >= eT * 1000:
        m = moveEntities([x, y], m, mW)
        if m[gY * mW + gX] != 'X':
          m[gY * mW + gX] = 'X'
          deleteEntity([gX, gY])
        time = getMonoTime()
        update()
        if visible.contains('E'):
          up = true
      if m[y * mW + x] == 'E':
        var sSx: int = scX
        var sSy: int = scY
        if scX mod 2 == 0:
          sSx -= 1
        if scY mod 2 == 0:
          sSy -= 1
        initBattle([x, y], [sSx, sSy, w, tX, tY, lV], bg)
        deleteEntity([x, y])

    if up == true:
      m[y * mW + x] = 'S'
      update()
      let rSc: array[2, string] = sc(visible, [w, h, tX, tY], [x, y], [gX, gY, h0, h2, h3], [xD, yD, mW, mYC], m, msg)
      m = rSc[0]
      bg = rSc[1]
      up = false

    if bypass == true:
      bypass = false
      if refresh() == true or closeMenu == true:
        closeMenu = false
        up = true

    else:
      let input = getKey()
      case input
      of Key.Left:
        if x - 1 >= 0:
          if m[y * mW + x - 1] != ' ' or h4 == 1:
            m[y * mW + x] = '9'
            x -= 1
            steps += 1
            up = true
      of Key.Right:
        if x + 1 <= mW - 1:
          if m[y * mW + x + 1] != ' ' or h4 == 1:
            m[y * mW + x] = '9'
            x += 1
            steps += 1
            up = true
      of Key.Up:
        if (y - 1) * mW + x >= 0:
          if m[(y - 1) * mW + x] != ' ' or h4 == 1:
            m[y * mW + x] = '9'
            y -= 1
            steps += 1
            up = true
      of Key.Down:
        if (y + 1) * mW + x < m.len:
          if m[(y + 1) * mW + x] != ' ' or h4 == 1:
            m[y * mW + x] = '9'
            y += 1
            steps += 1
            up = true
      of Key.M:
        openMap([w, h], [x, y], m, mW, h0, bg, sMap)
        while true:
          if getKey() == Key.M:
            break
          sleep(sV)
        bypass = true
        closeMenu = true
      of Key.I:
        oInv(bg)
        bypass = true
        closeMenu = true
      of Key.R:
        lv -= 1
        break
      of Key.N:
        break
      of Key.Q:
        showCursor()
        quit(0)
      else: discard
      if m[y * mW + x] == 'X': break

    if bypass == false:
      sleep(sV)

  lv += 1
  bypass = true
  removeDir("../data/chars/temp")
  createDir("../data/chars/temp")
  resetEntities()
  main()
main()

