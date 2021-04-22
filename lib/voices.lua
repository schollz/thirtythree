local Voices={}


function Voices:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  o.max=16
  o.played={}
  for i=1,16 do
    o.played[i]={id=0,last_played=os.clock()}
  end
  return o
end

-- get returns the best voice for id
function Voices:get(id)
  local current_time=os.clock()
  local voice=0
  local voice_oldest=1
  local longest_duration

  -- get the current voice used already, or the oldest voice
  for i=1,16 do
    if self.played[i].id==0 or self.played[i].id==id then
      voice=i
      break
    end
    if current_time-self.played[i].last_played>longest_duration then
      longest_duration=current_time-self.played[i].last_played
      voice_oldest=i
    end

  end

  -- steal oldest voice
  if voice==0 then
    voice=voice_oldest
  end

  self.played[voice]={id=id,last_played=os.clock()}
  return voice
end

return Voices
