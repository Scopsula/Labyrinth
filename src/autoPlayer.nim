import illwill, strutils, strformat, random, os
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
w = scX * tX
h = scY * tY

echo "Set level size: "
let n: int = readLine(stdin).parseInt

randomize()
illwillInit(fullscreen=true)
hideCursor()

var lv: int = 0
proc main() =
  if not fileExists(&"../chars/{lv}"): lv = 0
  writeFile("../loadedLevel/level", &"{lv}")
  newLevel()
  autoGenLv(n)
  var map: string = readFile("../loadedLevel/map")
  let mYC: int = map.splitLines.len
  let mW: int = map.splitlines[0].len

  var stEn: char = 'S'
  for i in 1 .. 2:
    if i == 2: stEn = 'X'
    while not map.contains(stEn):
      let mY = rand(0 .. mYC - 1)
      let mX = rand(0 .. mW - 1)
      if map[mY * (mW + 1) + mX] == '*':
        map[mY * (mW + 1) + mX] = stEn
        if i == 1:
          y = mY
          x = mX

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
    of Key.R:
      lv -= 1
      break
    of Key.Q: quit(0)
    else: discard
    if m[y * mW + x] == 'X': break
    m[y * mW + x] = 'S'
  lv += 1
  main()
main()

