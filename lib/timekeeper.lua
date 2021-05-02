local Timekeeper={}

function Timekeeper:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  return o
end

function Timekeeper:init()
  self.metronome_val=0
  self.metronome_tick=false
  self.bpm_current=0
  self.lattice=lattice:new({
    ppqn=64
  })
  self.last_beat_time=0
  self.last_last_beat_time=0


  -- TODO: allow different operators to select divisions
  self.pattern={}
  for i=1,4 do
    self.pattern[i]=self.lattice:new_pattern{
      action=function(t)
        ops[i]:pattern_step()
        if sel_operator==i then
          self.last_last_beat_time=self.last_beat_time
          self.last_beat_time=os.time2()
          if ops[i].mode_play and ops[i].cur_ptn_step==1 then
            self.metronome_val=0
          else
            self.metronome_val=self.metronome_val+1
          end
          if self.metronome_val%2==0 then
            self.metronome_tick=not self.metronome_tick
          end
          graphics:update()
        end
      end,
      division=1/8
    }
  end

  self.lattice:start()
end


-- closer_beat returns 0 if the current beat is closer,
-- and returns 1 if the next beat is closer
function Timekeeper:closer_beat()
  local last=self.last_beat_time
  local beat_length=self.last_beat_time-self.last_last_beat_time
  local next=last+beat_length
  local current=os.time2()
  print(last,current,next)
  if current-last<next-current then
    return 0
  else
    return 1
  end
end

function Timekeeper:adjust_swing(i,d)
  self.pattern[i]:set_swing(d+self.pattern[i].swing)
end

function Timekeeper:get_swing(i)
  return self.pattern[i].swing
end

function Timekeeper:tick()
  return self.metronome_tick
end

function Timekeeper:reset()
  self.lattice:hard_restart()
  for _,op in pairs(ops) do
    op:pattern_reset()
  end
end

function Timekeeper:hard_restart()
  print("reseting lattice")
  self.lattice:hard_restart()
  print("reseting voices")
  voices:reset()
end

return Timekeeper
