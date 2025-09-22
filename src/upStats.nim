import strformat, strutils, random
import openInv

proc tDrain*(steps: int, tM: int): array[2, string] =
  var msg: string
  var ste: string = &"{steps}"
  var stats = readFile("../data/stats")
  let health: int = stats.splitLines[0].split(' ')[1].parseInt
  let thirst: int = stats.splitLines[1].split(' ')[1].parseInt

  if thirst > 0 and steps == tM:
    let t1: string = &"thirst {thirst}"
    let t2: string = &"thirst {thirst - 1}"
    stats = stats.replace(t1, t2)
    writeFile("../data/stats", stats)
    msg = "Lost hydration"
    ste = "0"

  elif thirst == 0 and steps == 3 and health > 0:
    let h1: string = &"health {health}"
    let h2: string = &"health {health - 1}"
    stats = stats.replace(h1, h2)
    writeFile("../data/stats", stats)
    msg = "Dying to dehydration"
    ste = "0"

  return [msg, ste]

proc iCount(item: char, bound: int): bool = 
  let n: int = checkCount(item)
  if n < bound:
    writeFile(&"../data/items/{item}", &"{n + 1}")
    return true
  else: return false

proc iUpdate*(item: char): string =
  var msg: string
  if item == 'A':
    var stats: string = readFile("../data/stats")
    var thirst: int = stats.splitLines[1].split(' ')[1].parseInt
    if thirst == 50:
      if iCount(item, 6) == true:
        msg = "Picked up almond water"
      else:
        msg = "Out of room, destroyed"

    elif thirst < 50:
      let t1: string = &"thirst {thirst}"
      if thirst + 5 > 50: thirst = 45
      let t2: string = &"thirst {thirst + 5}"
      stats = stats.replace(t1, t2)
      writeFile("../data/stats", stats)
      msg = "Drank almond water"
      
  elif item == 'B':
    var stats: string = readFile("../data/stats")
    let health: int = stats.splitLines[0].split(' ')[1].parseInt
    if health == 50:
      if iCount(item, 6) == true:
        msg = "Picked up canned food"
      else:
        msg = "Out of room, destroyed"

    elif health < 50:
      let t1: string = &"health {health}"
      let t2: string = &"health {health + 5}"
      stats = stats.replace(t1, t2)
      writeFile("../data/stats", stats)
      msg = "Ate canned food"

  elif item == 'F':
    if iCount(item, 3) == true:
      msg = "Picked up flashlight"
    else:
      msg = "Out of room, destroyed"

  elif item == 'R':
    let 
      r1: int = rand(4)
      r2: int = rand(4)
      r3: int = rand(1)

    if r1 > 0:
      for i in 1 .. r1:
        discard iCount('A', 6)
    if r2 > 0:
      for i in 1 .. r2:
        discard iCount('B', 6)
    if r3 > 0:
      for i in 1 .. r3:
        discard iCount('F', 3)

    msg = "Opened crate, check inventory"

  return msg
