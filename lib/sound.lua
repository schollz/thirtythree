--
-- Sound class
-- contains information for sample
-- includes splicing informatoin
--

Sound={}

function Sound:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self

  -- parameters
  if o.melodic==nil then
    o.melodic=true
  end
  o.op_id=o.op_id
  o.id=o.id or 1
  o.snd_id=o.snd_id or 1
  o.s=o.s or 0
  o.e=o.e or 1
  o.pitch=o.pitch or 0
  o.amp=o.amp or 1
  o.lpf=o.lpf or 20000
  o.hpf=o.hpf or 20
  o.resonance=o.resonance or 1
  if o.is_lpf == nil then 
    o.is_lpf=true
  end
  o.wav=o.wav or nil
  o.loaded=o.loaded or false

  return o
end


function Sound:marshal()
  local data = {}
  for k,v in pairs(self) do
    data[k]=json.encode(v)
  end
  return json.encode(data)
end

function Sound:unmarshal(content)
  local data=json.decode(content)
  if data==nil then
    print("no data found in save file")
    do return end
  end
  for k,v in pairs(data) do
    self[k]=json.decode(v)
  end
end

function Sound:load(filename)
  self.wav=wav:get(filename)
  -- partition transients
  if (not self.melodic) and self.wav.onsets[self.id]~=nil then
    self.s=self.wav.onsets[self.id][1]
    self.e=self.wav.onsets[self.id][2]
  end

  self.loaded=true
end

function Sound:dump()
  return {
    op_id=self.op_id,
    melodic=self.melodic,
    id=self.id,
    snd_id=self.snd_id,
    s=self.s,
    e=self.e,
    amp=self.amp,
    lpf=self.lpf,
    hpf=self.hpf,
    resonance=self.resonance,
    is_lpf=self.is_lpf,
    pitch=self.pitch,
    wav=self.wav,
    loaded=self.loaded,
  }
end

-- Sound:press will play a sound from a sample
function Sound:play(override)
  if not self.loaded then
    print("sound not loaded")
    do return end
  end
  local voice=nil
  local s=self.s
  local e=self.e
  local effect=0
  local amp=self.amp
  local lpf=self.lpf
  local hpf=self.hpf 
  local lpf_resonance=self.resonance
  local hpf_resonance=self.resonance
  local is_lpf=self.is_lpf
  if override~=nil then
    voice=override.voice
    s=override.s or s
    e=override.e or e
    effect=override.effect or 0
    amp=override.amp or amp
    if override.is_lpf ~= nil then 
      is_lpf=override.is_lpf
    end
  end
  if voice==nil then
    voice=voices:new_voice(self.snd_id)
  end
  if is_lpf then
    hpf_resonance=1 
    hpf=20
  else
    lpf_resonance=1 
    lpf=20000
  end
  if mode_debug then
    print("playing "..self.wav.name.." on voice "..voice.." at pos ("..s..","..e..")")
    print(voice,-- which sampler player
      self.wav.sc_index,-- buffer number
      effect,
      amp,
      pitch.transpose_rate(self.pitch),
      s,
    e)
  end
  engine.tt_play(
    voice,-- which sampler player
    self.wav.sc_index,-- buffer number
    effect,
    amp*ops[self.op_id].amp_global,
    pitch.transpose_rate(self.pitch),
    s,
    e,
    lpf,
    lpf_resonance,
    hpf,
    hpf_resonance
  )
end

function Sound:get_start_end(s,e)
  local s=util.linlin(0,1,0,self.wav.duration,s)
  local e=util.linlin(0,1,0,self.wav.duration,e)
  return s,e
end

return Sound


