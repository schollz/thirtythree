local Timekeeper={}
local lattice=require 'lattice'


function Timekeeper:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self

  return o
end

function Timekeeper:init()
  self.metronome_tick=false
  self.bpm_current=0
  self.lattice=lattice:new({
    ppqn=64
  })
  self.timers={}
  self.divisions={1/4}
  for _,division in ipairs(self.divisions) do
    self.timers[division]={}
    self.timers[division].lattice=self.lattice:new_pattern{
      action=function(t)
        self:emit_note(division,t)
      end,
    division=division}
  end
  self.lattice:new_pattern{
    action=function(t)
      self.metronome_tick=not self.metronome_tick
    end,
    division=1/4
  }
  self.lattice:start()

end

function Timekeeper:tick()
  return self.metronome_tick
end

function Timekeeper:emit_note(division,t)
  for _, op in pairs(ops) do
    if op.division==division do 
      op:pattern_step()
    end
  end
end

function Timekeeper:reset()
  self.lattice:hard_restart()
  for _, op in pairs(ops) do
    op:pattern_reset()
  end
end

return Timekeeper
