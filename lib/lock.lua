local Lock={}

function Lock:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self

  o.snd_id=o.snd_id or 1
  o.modified={}
  o.has_modified=false
  -- updates modified thigns
  return o
end

function Lock:debug(s)
  if mode_debug then
    print("lock ("..self.snd_id.."): "..s)
  end
end


function Lock:set(k,v)
  self.modified[k]=v
  self.has_modified=true
end

function Lock:play_if_locked()
  if not self.has_modified then
    self:debug("nothing modified")
    -- no need to update engine since sound is not modified
    do return end
  end
  local voice=voices:get_voice(self.snd_id)
  if voice==nil then
    -- nothing to update, voice has been stolen
    self:debug("can't get voice")
    do return end
  end
  self:debug("updating")
  for k,v in pairs(self.modified) do
    if k=="amp" then
      -- set amp with a little lag
      engine.tt_amp(voice,v,0.1)
    end
  end
end


return Lock
