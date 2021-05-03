local Voices={}

-- TEST: add duration to hold the voices for

function Voices:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  o.max=12
  o.played={}
  o:reset()
  o.pos=0
  o.main=1

  -- collect position information from supercollider
  -- osc input
  -- osc.event=function(path,args,from)
  --   if path=="tt_pos" then
  --     if args[1]>0 then
  --       o.pos=args[2]
  --       if sel_adj==ADJ_TRIM then
  --         graphics:update()
  --       end
  --     end
  --   end
  -- end

  return o
end


function Voices:reset()
  print("reseting voices")
  for i=1,self.max do
    self.played[i]={snd_id=0,last_played=0,locked=false,duration=0}
  end
end

function Voices:get_main()
  engine.tt_amp(self.main,0,0.1)
  self.main=3-self.main
  return self.main
end

-- get_voice returns the voice currently being used for a sound
function Voices:get_voice(op_id,snd_id)
  snd_id=16*(op_id-1)+snd_id
  -- find the newest voice
  local newest_voice=nil
  local current_time=os.time2()
  local newest_time=100000000
  for i=3,self.max do
    if self.played[i].snd_id==snd_id and current_time-self.played[i].last_played<newest_time then
      newest_time=current_time-self.played[i].last_played
      newest_voice=i
    end
  end
  return newest_voice
end

function Voices:lock(voice,lockit)
  if voice==nil then
    do return end
  end
  self.played[voice].locked=lockit
end

-- new_voice will make a new voice for a sound, fading out previous sound
function Voices:new_voice(op_id,snd_id,duration)
  local snd_id2=16*(op_id-1)+snd_id
  local current_time=os.time2()
  local voice=0
  local voice_oldest=1
  local longest_duration=-1

  -- fade it out if its playing
  for i=3,self.max do
    if self.played[i].snd_id==snd_id2 then
      print("turning down voice "..i.." of sound "..snd_id2)
      -- turn this voice down
      engine.tt_amp(i,0,0.2)
      self.played[i].snd_id=0 -- reset it
      self.played[i].locked=false
      self.played[i].duration=0
    end
  end

  -- get the current voice used already, or the oldest voice
  for i=3,self.max do -- voice 1 is reserved
    local d=current_time-self.played[i].last_played
    if d>longest_duration and
      (not self.played[i].locked) and
      (d<0 or d>=self.played[i].duration) then
      longest_duration=d
      voice_oldest=i
    end
  end

  -- steal oldest voice
  if voice==0 then
    voice=voice_oldest
  end

  if voice==0 then
    print("NO VOICES!?")
    do return end
  end
  print(current_time,self.played[voice].last_played,self.played[voice].duration,longest_duration)
  print("stealing voice "..voice.." with longest duration "..longest_duration)
  self.played[voice]={snd_id=snd_id2,last_played=os.time2(),locked=false,duration=duration}
  return voice
end


return Voices
