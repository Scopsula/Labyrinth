import random

var evType: seq[int]
var coords: seq[array[2,int]]
proc resetCEv*() =
  evType.setlen(0)
  coords.setlen(0)

proc cEvents*(c: char, xy: array[2, int], dir: string): string =
  case c
  of 'W':
    if dir == "up" or dir == "down":
      if not coords.contains(xy):
        coords.add(xy)
        let r: int = rand(99)
        if r < 1:
          evType.add(2)
        elif r < 10:
          evType.add(1)
        else:
          evType.add(0)
      let i: int = find(coords, xy)
      case evType[i]
      of 1:
        return "battle window"
      of 2:
        return "exit"
      else:
        return "This window is locked"
  else:
    discard
  return "This is a wall..."

proc cExit*(c: char): string =
  case c
  of 'W':
    return "You escaped via the window..."
  else:
    return "You escaped..."

proc cBattle*(c: string): string =
  case c
  of "window":
    return "A figure in the window reached out to grab you!"
  else:
    return ""

