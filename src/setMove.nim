proc selEMove*(eType: string, turn: int): string =
  let entity = eType[9 .. ^2]
  case entity
  of "smiler":
    if turn == 1:
      return "chase"
    if turn mod 3 == 0:
      return "darkEnergyExpansion"
    if turn mod 2 == 0:
      return "bite"
  else:
    discard
