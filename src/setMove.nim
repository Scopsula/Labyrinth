proc selEMove*(eType: string, turn: int): string =
  let entity = eType
  case entity
  of "smiler":
    if turn mod 2 == 0:
      return "bite"
    elif turn < 5:
      return "chase"
    elif turn > 4:
      return "darkEnergyExpansion"
  else:
    discard

