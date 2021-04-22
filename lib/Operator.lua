--
-- Operator class
-- contains information for each operator
--

Operator = {}

function Operator:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.__tostring = function(t) return t:to_string() end

  o.index=o.index or 1
  o.pattern_current=1
  o.sound_current=1
  o.sound={}
  for i=1,16 do 
    o.sound[i]=sound_class:new({
      index_sc=(o.index-1)*16+i
      melodic=i<9,
    })
  end

  return o
end

function Operator:to_string()
  return self.filename
end

function Operator:load_sound(i,filename)
  o.sound[i]:load(filename)
end

function Operator:play(button)
  o.sound[o.sound_current]:play(button)
end