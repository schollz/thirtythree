local Voices={}


function Voices:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  o.max=15
  o.played={}
  for i=1,o.max do
    o.played[i]={snd_id=0,last_played=os.clock(),locked=false}
  end
  o.pos=0
  o.main=1

  -- collect position information from supercollider
  -- osc input
  osc.event=function(path,args,from)
    if path=="tt_pos" then
      if args[1] > 0 then
        o.pos=args[2]
        if sel_adj==ADJ_TRIM then
          graphics:update()
        end
      end
    end
  end

  return o
end

function Voices:get_main()
  engine.tt_amp(self.main,0,0.1)
  self.main=3-self.main
  return self.main
end

-- get_voice returns the voice currently being used for a sound
function Voices:get_voice(op_id,snd_id)
  snd_id=16*(op_id-1)+snd_id
  for i=3,self.max do
    if self.played[i].snd_id==snd_id then
      return i
    end
  end
  return nil
end

function Voices:lock(voice,lockit)
  self.played[voice].locked=lockit
end

-- new_voice will make a new voice for a sound, fading out previous sound
function Voices:new_voice(op_id,snd_id)
  local snd_id=16*(op_id-1)+snd_id
  local current_time=os.clock()
  local voice=0
  local voice_oldest=1
  local longest_duration=-1

  -- fade it out if its playing
  for i=3,self.max do
    if self.played[i].snd_id==snd_id and current_time-self.played[i].last_played<1 then
      -- turn this voice down
      engine.tt_amp(i,0,0.1)
      self.played[i].snd_id=0 -- reset it
      self.played[i].locked=false
    end
  end

  -- get the current voice used already, or the oldest voice
  for i=3,self.max do -- voice 1 is reserved
    if current_time-self.played[i].last_played>longest_duration and not self.played[i].locked then
      longest_duration=current_time-self.played[i].last_played
      voice_oldest=i
    end
  end

  -- steal oldest voice
  if voice==0 then
    voice=voice_oldest
  end

  self.played[voice]={snd_id=snd_id,last_played=os.clock(),locked=false}
  return voice
end


return Voices
