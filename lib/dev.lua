local Dev={}


function Dev:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self


  sel_filename="/home/we/dust/audio/amen/amenbreak_bpm136.wav"
  ops[1]:sound_load(9,sel_filename)
  sel_filename="/home/we/dust/audio/mx.samples/claus_piano/42.1.3.1.0.wav"
  ops[1]:sound_load(1,sel_filename)
  ops[1].cur_snd_id=1
  sel_adj=ADJ_TRIM
  return o
end

return Dev
