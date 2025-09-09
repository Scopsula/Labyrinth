import terminal, strutils, random
import screen

const
  tX: int = 10
  tY: int = 5

var
  map: string = readFile("../loadedLevel/map")
  w: int = terminalWidth()
  h: int = terminalHeight() - 1
  x: int = 0
  y: int = 0

let 
  scX = w div tX
  scY = h div tY
  yD = (scY - 1) div 2 + 2
  xD = (scX - 1) div 2 + 2

var h0: int = 0
echo "Enable Coordinates? [y/n]"
let eC: string = readLine(stdin).toUpper
if eC == "Y": h0 = 1

randomize()
newLevel()
hideCursor()

let mYC: int = map.splitLines.len
let mW: int = map.splitlines[0].len

var 
  stEn: char = 'S'
  gY: int
  gX: int

for i in 1 .. 2:
  if i == 2: stEn = 'X'
  while not map.contains(stEn):
    let mY = rand(0 .. mYC - 2)
    let mX = rand(0 .. mW - 1)
    if map[mY * (mW + 1) + mX] == '*':
      map[mY * (mW + 1) + mX] = stEn
      if i == 1:
        y = mY
        x = mX
      else:
        gY = mY
        gX = mX

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
  if y >= yD: lYB = -yD
  else: lYB = -(yD + (y - yD))

  var uYB: int
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

var up: bool = true
while true:
  if up == true:
    m[y * mW + x] = 'S'
    update()
    m = sc(visible, [w, h, tX, tY], [x, y], [gX, gY, h0], [xD, yD, mW, mYC], m)
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
  of "q":
    showCursor()
    quit(0)
  else: discard
