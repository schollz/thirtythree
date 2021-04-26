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

function Lock:marshal()
  local data={}
  for k,v in pairs(self) do
    data[k]=json.encode(v)
  end
  return json.encode(data)
end

function Lock:unmarshal(content)
  local data=json.decode(content)
  if data==nil then
    print("no data found in save file")
    do return end
  end
  for k,v in pairs(data) do
    self[k]=json.decode(v)
  end
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
    v2 = nil 
    if k=="lpf" or k=="hpf" then
      v2=self.modified["resonance"]
      if v2==nil then 
        v2 = 1.0
      end
    end
    -- skip filters if they are not activated
    if k=="lpf" and self.modified["is_lpf"]==false then
    elseif k=="hpf" and self.modified["is_lpf"]==true then
    else
      ngen:update(voice,k,v,v2)
    end
  end
end


return Lock
