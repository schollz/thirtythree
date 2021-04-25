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
  o.pos=0

  -- collect position information from supercollider
  -- osc input
  osc.event=function(path,args,from)
    if path=="tt_pos" then
      o.pos=args[2]
    end
  end

  return o
end

-- pos returns the position of the index-1 voice
function Voices:pos()
  return self.pos
end

-- get returns the best voice for id
function Voices:get(id)
  local current_time=os.clock()
  local voice=0
  local voice_oldest=1
  local longest_duration=-1

  -- fade it out if its playing
  for i=2,16 do
    if self.played[i].id==id and current_time-self.played[i].last_played<1 then
      -- turn this voice down
      engine.tt_amp(i,0,0.1)
    end
  end

  -- get the current voice used already, or the oldest voice
  for i=2,16 do -- voice 1 is reserved
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
