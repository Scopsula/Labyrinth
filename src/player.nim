import illwill, strutils, random
import screen

var map: string = readFile("../loadedLevel/map")

var 
  tX: int = 10
  tY: int = 5
  w: int = terminalWidth()
  h: int = terminalHeight() - 1
  x: int = 0
  y: int = 0

let scX = w div tX
let scY = h div tY
let lD = (scY - 1) div 2
let xD = (scX - 1) div 2
w = scX * tX
h = scY * tY

randomize()
newLevel()

let mYC: int = map.splitLines.len
let mW: int = map.splitlines[0].len

while not map.contains("S"):
  for mY in 0 .. mYC - 1:
    for mX in 0 .. mW - 1:
      if map[mY * (mW + 1) + mX] == '*':
        if rand(1 .. map.len) == 1:
          map[mY * (mW + 1) + mX] = 'S'
          y = mY
          x = mX
          break
    if map.contains("S"): 
      break

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
  if x >= xD:
    if y - lD >= 0:
      if y + lD <= mYC - 1:
        if x + xD < mW: loadChunk(-lD, lD, pos - xD, pos + xD)
        else: loadChunk(-lD, lD, pos - xD, pos - x + mW - 1)
      else:
        if x + xD < mW: loadChunk(-lD, lD - (y + lD - mYC + 1), pos - xD, pos + xD)
        else: loadChunk(-lD, lD - (y + lD - mYC + 1), pos - xD, pos - x + mW - 1)
    else:
      if y + lD <= mYC - 1:
        if x + xD < mW: loadChunk(-(lD + (y - lD)), lD, pos - xD, pos + xD)
        else: loadChunk(-(lD + (y - lD)), lD, pos - xD, pos - x + mW - 1)
      else:
        if x + xD < mW: loadChunk(-(lD + (y - lD)), lD - (y + lD - mYC + 1), pos - xD, pos + xD)      
        else: loadChunk(-(lD + (y - lD)), lD - (y + lD - mYC + 1), pos - xD, pos - x + mW - 1)
  else:
    if y - lD >= 0:
      if y + lD <= mYC - 1:
        if x + xD < mW: loadChunk(-lD, lD, pos - x, pos + xD)
        else: loadChunk(-lD, lD, pos - x, pos - x + mW - 1)
      else:
        if x + xD < mW: loadChunk(-lD, lD - (y + lD - mYC + 1), pos - x, pos + xD)      
        else: loadChunk(-lD, lD - (y + lD - mYC + 1), pos - x, pos - x + mW - 1)      
    else:
      if y + lD <= mYC - 1:
        if x + xD < mW: loadChunk(-(lD + (y - lD)), lD, pos - x, pos + xD)
        else: loadChunk(-(lD + (y - lD)), lD, pos - x, pos - x + mW - 1)
      else:
        if x + xD < mW: loadChunk(-(lD + (y - lD)), lD - (y + lD - mYC + 1), pos - x, pos + xD)
        else: loadChunk(-(lD + (y - lD)), lD - (y + lD - mYC + 1), pos - x, pos - x + mW - 1)

illwillInit(fullscreen=true)
hideCursor()
var up: bool = true
while true:
  if up == true:
    update()
    sc(visible, terminalWidth(), terminalHeight(), tX, tY)
    up = false
  m[y * mW + x] = '*'
  let input = getKey()
  case input
  of Key.Left:
    if x - 1 >= 0:
      if m[y * mW + x - 1] != ' ':
        x -= 1
        up = true
  of Key.Right:
    if x + 1 <= mW - 1:
      if m[y * mW + x + 1] != ' ':
        x += 1
        up = true
  of Key.Up:
    if (y - 1) * mW + x >= 0:
      if m[(y - 1) * mW + x] != ' ':
        y -= 1
        up = true
  of Key.Down:
    if (y + 1) * mW + x < m.len:
      if m[(y + 1) * mW + x] != ' ':
        y += 1
        up = true
  of Key.Q: break
  else: discard
  m[y * mW + x] = 'S'

