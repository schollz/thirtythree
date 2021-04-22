local Dev={}


function Dev:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self


  sel_filename="/home/we/dust/audio/tehn/something.wav"

  return o
end

return De
