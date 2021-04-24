local Dev={}


function Dev:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self


  sel_filename="/home/we/dust/audio/amen/amenbreak_bpm136.wav"
  ops[1].cur_snd_id=9
  ops[1]:sound_load(9,sel_filename)
  return o
end

return Dev
