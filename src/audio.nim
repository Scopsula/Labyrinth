import parasound/dr_wav
import parasound/miniaudio
import os

var engine = newSeq[uint8](ma_engine_size())
proc play*(data: string) =
  discard ma_engine_init(nil, engine[0].addr)
  discard ma_engine_play_sound(engine[0].addr, data, nil)
  
proc stop*() =
  ma_engine_uninit(engine[0].addr)
  engine = newSeq[uint8](ma_engine_size())

