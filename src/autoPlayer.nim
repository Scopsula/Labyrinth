import terminal, strutils, strformat, random, os
import screen, autoGen, style, openMap, openInv, entities

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
inventory
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
  let sMap: string = map
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
    closeMenu: bool = false
    steps: int = 0
    bg: string
    msg: string

  while true:
    msg = ""
    if h1 == 1:
      if steps == tX * tY or steps == 3:
        stats = readFile("../data")
        health = stats.splitLines[0].split(' ')[1].parseInt
        thirst = stats.splitLines[1].split(' ')[1].parseInt

        if thirst > 0 and steps == tX * tY:
          let t1: string = &"thirst {thirst}"
          let t2: string = &"thirst {thirst - 1}"
          stats = stats.replace(t1, t2)
          writeFile("../data", stats)
          thirst -= 1
          steps = 0
          msg = "Lost hydration"

        elif thirst == 0 and steps == 3 and health > 0:
          let h1: string = &"health {health}"
          let h2: string = &"health {health - 1}"
          stats = stats.replace(h1, h2)
          writeFile("../data", stats)
          health -= 1
          steps = 0
          msg = "Dying to dehydration"

      elif health == 0:
        quit(0)

    if m[y * mW + x] == 'A':
      if thirst == 50:
        if checkCount()[0] < 6:
          stats = readFile("../data")
          let inv = stats.splitLines[2]
          stats = stats.replace(inv, &"{inv} A")
          writeFile("../data", stats)
          msg = "Picked up almond water"
        else:
          msg = "Out of room, destroyed"

      elif thirst < 50:
        stats = readFile("../data")
        thirst = stats.splitLines[1].split(' ')[1].parseInt
        let t1: string = &"thirst {thirst}"
        if thirst + 5 > 50: thirst = 45
        let t2: string = &"thirst {thirst + 5}"
        stats = stats.replace(t1, t2)
        writeFile("../data", stats)
        thirst += 5
        msg = "Drank almond water"
      
    if m[y * mW + x] == 'B':
      if health == 50:
        if checkCount()[1] < 6:
          stats = readFile("../data")
          let inv = stats.splitLines[2]
          stats = stats.replace(inv, &"{inv} C")
          writeFile("../data", stats)
          msg = "Picked up canned food"
        else:
          msg = "Out of room, destroyed"

      elif health < 50:
        stats = readFile("../data")
        health = stats.splitLines[0].split(' ')[1].parseInt
        let t1: string = &"health {health}"
        if thirst + 5 > 50: thirst = 45
        let t2: string = &"health {health + 5}"
        stats = stats.replace(t1, t2)
        writeFile("../data", stats)
        health += 5
        msg = "Ate canned food"

    if m[y * mW + x] == 'F':
      if checkCount()[2] < 3:
        stats = readFile("../data")
        let inv = stats.splitLines[2]
        stats = stats.replace(inv, &"{inv} F")
        writeFile("../data", stats)
        msg = "Picked up flashlight"
      else:
        msg = "Out of room, destroyed"

    if m[y * mW + x] == 'R':
      let 
        r1: int = rand(4)
        r2: int = rand(4)
        r3: int = rand(1)

      stats = readFile("../data")

      if r1 > 0:
        for i in 1 .. r1:
          if checkCount()[0] < 6:
            let inv = stats.splitLines[2]
            stats = stats.replace(inv, &"{inv} A")
            writeFile("../data", stats)
      if r2 > 0:
        for i in 1 .. r2:
          if checkCount()[1] < 6:
            let inv = stats.splitLines[2]
            stats = stats.replace(inv, &"{inv} C")
            writeFile("../data", stats)
      if r3 > 0:
        for i in 1 .. r3:
          if checkCount()[2] < 3:
            let inv = stats.splitLines[2]
            stats = stats.replace(inv, &"{inv} F")
            writeFile("../data", stats)

      msg = "Opened crate, check inventory"

    if up == true:
      m[y * mW + x] = 'S'
      if h2 == 1: m = moveEntities([x, y], m, mW)
      update()
      let rSc: array[2, string] = sc(visible, [w, h, tX, tY], [x, y], [gX, gY, h0, h2], [xD, yD, mW, mYC], m, msg)
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
        openMap([w, h], [x, y], m, mW, h0, bg, sMap)
        while true:
          if getch() == 'm':
            break
        bypass = true
        closeMenu = true
      of "i":
        oInv(bg)
        bypass = true
        closeMenu = true
      of "r":
        lv -= 1
        break
      of "n":
        break
      of "q":
        showCursor()
        quit(0)
      else: discard
      if m[y * mW + x] == 'X': break
  lv += 1
  bypass = true
  resetEntities()
  main()
main()

