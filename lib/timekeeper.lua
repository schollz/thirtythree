local Timekeeper={}

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

  -- TODO: allow different operators to select divisions

  self.pattern={}
  for i,_ in ipairs(ops) do
    self.pattern[i]=self.lattice:new_pattern{
      action=function(t)
        self:emit_note(i,t)
        if sel_operator==i then
          self.metronome_tick=not self.metronome_tick
          graphics:update()
        end
      end,
      division=1/8
    }
  end

  self.sync=self.lattice:new_pattern{
    action=function(t)
      -- TODO: reset all operators to first step
      for _,op in ipairs(ops) do
        if op.cur_ptn_step>1 and op.cur_ptn_step<16 then
          print("master clock reseting operator")
          op:pattern_reset()
        end
      end
    end,
    division=2 -- 16 beats
  }

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

function Timekeeper:emit_note(i,t)
  ops[i]:pattern_step()
end

function Timekeeper:reset()
  self.lattice:hard_restart()
  for _,op in pairs(ops) do
    op:pattern_reset()
  end
end

return Timekeeper
