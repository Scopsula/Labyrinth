import illwill, strutils, random
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

let scX = w div tX
let scY = h div tY
let lD = (scY - 1) div 2
let xD = (scX - 1) div 2

var hide: bool = true
echo "Enable Coordinates? [y/n]"
let eC: string = readLine(stdin).toUpper
if eC == "Y": hide = false

randomize()
newLevel()

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
  if y >= lD: lYB = -lD
  else: lYB = -(lD + (y - lD))

  var uYB: int
  if y + lD <= mYC - 2: uYB = lD 
  else: uYB = lD - (y + lD - mYC + 2)

  loadChunk(lYB,uYB,lXB,uXB)

illwillInit(fullscreen=true)
hideCursor()
var up: bool = true
while true:
  if up == true:
    m[y * mW + x] = 'S'
    update()
    sc(visible, w, h + 1, tX, tY, x, y, gX, gY, hide)
    up = false
  let input = getKey()
  case input
  of Key.Left:
    if x - 1 >= 0:
      if m[y * mW + x - 1] != ' ':
        m[y * mW + x] = '*'
        x -= 1
        up = true
  of Key.Right:
    if x + 1 <= mW - 1:
      if m[y * mW + x + 1] != ' ':
        m[y * mW + x] = '*'
        x += 1
        up = true
  of Key.Up:
    if (y - 1) * mW + x >= 0:
      if m[(y - 1) * mW + x] != ' ':
        m[y * mW + x] = '*'
        y -= 1
        up = true
  of Key.Down:
    if (y + 1) * mW + x < m.len:
      if m[(y + 1) * mW + x] != ' ':
        m[y * mW + x] = '*'
        y += 1
        up = true
  of Key.Q: break
  else: discard

