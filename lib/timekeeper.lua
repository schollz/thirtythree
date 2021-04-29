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

  -- TODO: allow different operators to select divisions
  self.pattern={}
  for i,_ in ipairs(ops) do
    self.pattern[i]=self.lattice:new_pattern{
      action=function(t)
        ops[i]:pattern_step()
        if sel_operator==i then
          if ops[i].mode_play and ops[i].cur_ptn_step==1 then 
            self.metronome_val=0
          else
            self.metronome_val = self.metronome_val+1
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

return Timekeeper
