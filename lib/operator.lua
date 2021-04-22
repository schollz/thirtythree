--
-- Operator class
-- contains information for each operator
--

Operator={}

function Operator:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  self.__tostring=function(t) return t:to_string() end

  o.index=o.index or 1
  o.sound={}
  o.sound_current=1
  o.sound_button=1
  for i=1,16 do
    o.sound[i]=sound_:new({
      index_sc=(o.index-1)*16+i
      melodic=i<9,
    })
  end

  o.pattern={}
  o.pattern_current=1
  for i=1,16 do
    o.pattern[i]={}
  end
  return o
end

function Operator:to_string()
  return self.filename
end

function Operator:sound_load(i,filename)
  o.sound[i]:load(filename)
end

function Operator:press_button(button)
  -- TODO: check mode first
  o.sound[o.sound_current]:play(button)
end

-- pattern_update will toggle the position of the
-- current button of the current sound in the current pattern
function Operator:pattern_update(position)
  if self.pattern[self.pattern_current][self.sound_current]==nil then
    self.pattern[self.pattern_current][self.sound_current]={}
  end
  if self.pattern[self.pattern_current][self.sound_current][self.sound_button]==nil then
    self.pattern[self.pattern_current][self.sound_current][self.sound_button]=position
  else
    self.pattern[self.pattern_current][self.sound_current][self.sound_button]=nil
    if #self.pattern[self.pattern_current][self.sound_current]==0 then
      self.pattern[self.pattern_current][self.sound_current]=nil
    end
  end
end

function Operator:pattern_play(step)
  -- play all buttons at specified step
  for _,pattern in pairs(self.pattern[self.pattern_curent]) do
    for _,sound_id in pairs(pattern) do
      for _,button in pairs(sound_pattern) do
        if button==step then
          self.sound[sound_id]:play(button)
        end
      end
    end
  end
end


return Operato
