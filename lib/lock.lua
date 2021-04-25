local Lock={}

function Lock:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self

  o.group=o.group or 1
  o.modified={}
  -- updates modified thigns
  return o
end

function Lock:debug(s)
  if mode_debug then
    print("param ("..self.group.."): "..s)
  end
end


function Lock:set(k,v)
  self.modified[k]=v
end

function Lock:play_if_locked()
  if #self.modified==0 then
    -- no need to update engine since sound is not modified
    do return end
  end
  local voice=voices:get_voice(self.group)
  if voice==nil then
    -- nothing to update, voice has been stolen
    do return end
  end
  self:debug("updating")
  for k,v in self.modified do
    if k=="amp" then
      -- TODO: set amp with a little lag
      -- engine.tt_amp(voice,v,0.1)
    end
  end
end


return Lock
