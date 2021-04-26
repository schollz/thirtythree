local Voices={}


function Voices:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  o.max=16
  o.played={}
  for i=1,16 do
    o.played[i]={snd_id=0,last_played=os.clock()}
  end
  o.pos=0
  o.main=1

  -- collect position information from supercollider
  -- osc input
  osc.event=function(path,args,from)
    if path=="tt_pos" then
      o.pos=args[2]
    end
  end

  return o
end

function Voices:get_main()
  engine.tt_amp(self.main,0,0.1)
  self.main=3-self.main
  return self.main
end

-- pos returns the position of the index-1 voice
function Voices:pos()
  return self.pos
end

-- get_voice returns the voice currently being used for a sound
function Voices:get_voice(snd_id)
  for i=3,16 do
    if self.played[i].snd_id==snd_id then
      return i
    end
  end
  return nil
end

-- new_voice will make a new voice for a sound, fading out previous sound
function Voices:new_voice(snd_id)
  local current_time=os.clock()
  local voice=0
  local voice_oldest=1
  local longest_duration=-1

  -- fade it out if its playing
  for i=3,16 do
    if self.played[i].snd_id==snd_id and current_time-self.played[i].last_played<1 then
      -- turn this voice down
      engine.tt_amp(i,0,0.1)
      self.played[i].snd_id=0 -- reset it
    end
  end

  -- get the current voice used already, or the oldest voice
  for i=3,16 do -- voice 1 is reserved
    if current_time-self.played[i].last_played>longest_duration then
      longest_duration=current_time-self.played[i].last_played
      voice_oldest=i
    end
  end

  -- steal oldest voice
  if voice==0 then
    voice=voice_oldest
  end

  self.played[voice]={snd_id=snd_id,last_played=os.clock()}
  return voice
end


return Voices
