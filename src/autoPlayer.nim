import terminal, strutils, strformat, random, os
import screen, autoGen

const
  tX: int = 10
  tY: int = 5

var 
  w: int = terminalWidth()
  h: int = terminalHeight() - 1
  x: int = 0
  y: int = 0

let scX = w div tX
let scY = h div tY
let lD = (scY - 1) div 2
let xD = (scX - 1) div 2

echo "Set level size: "
let n: int = readLine(stdin).parseInt

var h0: int = 0
echo "\nEnable Coordinates? [y/n]"
let eC: string = readLine(stdin).toUpper
if eC == "Y": h0 = 1

randomize()
hideCursor()

var lv: int = 0
proc main() =
  if not fileExists(&"../chars/{lv}"): lv = 0
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
    var po: array[2, int] = sample(valPoint)
    var nx = po[0] - valPoint[0][0]
    var ny = po[1] - valPoint[0][1]
    while map[ny * (mW + 1) + nx] != '*':
      po = sample(valPoint)
      nx = po[0] - valPoint[0][0]
      ny = po[1] - valPoint[0][1]
    if i == 1:
      map[ny * (mW + 1) + nx] = 'S'
      x = nx
      y = ny
    else:
      map[ny * (mW + 1) + nx] = 'X'
      gX = nx
      gY = ny

  var m = map.replace("\n", "")

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

    var lXB: int
    if x >= xD: lXB = pos - xD 
    else: lXB = pos - x

    var uXB: int
    if x + xD < mW: uXB = pos + xD
    else: uXB = pos - x + mW - 1

    var lYB: int
    if y >= lD: lYB = -lD
    else: lYB = -(lD + (y - lD))

    var uYB: int
    if y + lD <= mYC - 2: uYB = lD 
    else: uYB = lD - (y + lD - mYC + 2)

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

  var up: bool = true
  while true:
    if up == true:
      m[y * mW + x] = 'S'
      update()
      sc(visible, w, h, tX, tY, [x, y], [gX, gY, h0])
      up = false
    let input = getKey()
    case input
    of "a", "h", "left":
      if x - 1 >= 0:
        if m[y * mW + x - 1] != ' ':
          m[y * mW + x] = '*'
          x -= 1
          up = true
    of "d", "l", "right":
      if x + 1 <= mW - 1:
        if m[y * mW + x + 1] != ' ':
          m[y * mW + x] = '*'
          x += 1
          up = true
    of "w", "k", "up":
      if (y - 1) * mW + x >= 0:
        if m[(y - 1) * mW + x] != ' ':
          m[y * mW + x] = '*'
          y -= 1
          up = true
    of "s", "j", "down":
      if (y + 1) * mW + x < m.len:
        if m[(y + 1) * mW + x] != ' ':
          m[y * mW + x] = '*'
          y += 1
          up = true
    of "r":
      lv -= 1
      break
    of "q":
      showCursor()
      quit(0)
    else: discard
    if m[y * mW + x] == 'X': break
  lv += 1
  main()
main()

