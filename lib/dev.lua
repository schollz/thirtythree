local Dev={}


function Dev:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self


  sel_filename="/home/we/dust/audio/amen/amenbreak_bpm136.wav"

  return o
end

return Dev
