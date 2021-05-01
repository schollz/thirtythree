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
  o.pitch_base=o.pitch_base or 0
  o.pitch=0
  o.amp=o.amp or 1
  o.lpf=o.lpf or 20000
  o.hpf=o.hpf or 20
  o.resonance=o.resonance or 1
  if o.is_lpf==nil then
    o.is_lpf=true
  end
  o.loaded=o.loaded==nil and false or o.loaded

  return o
end

function Sound:marshal()
  local data={}
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
    pitch_base=self.pitch_base,
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
  local amp=self.amp
  local lpf=self.lpf
  local hpf=self.hpf
  local lpf_resonance=self.resonance
  local hpf_resonance=self.resonance
  local is_lpf=self.is_lpf
  local pitch=self.pitch
  if override~=nil then
    voice=override.voice
    s=override.s or s
    e=override.e or e
    pitch=override.pitch or pitch
    amp=override.amp or amp
    if override.is_lpf~=nil then
      is_lpf=override.is_lpf
    end
  else
    override={}
  end
  if override.fx == nil then 
    override.fx={}
  end

  if is_lpf then
    hpf_resonance=1
    hpf=20
  else
    lpf_resonance=1
    lpf=20000
  end

  -- get new voice
  do_update=false
  if voice==nil then
    voice=voices:new_voice(self.op_id,self.snd_id,(e-s)*self.wav.duration)
  elseif voice==1 then -- main voice
    voice=voices:get_main()
  else
    -- entered previous voice, just do update
    do_update=true
  end
  if do_update then
    if mode_debug then
      print("updating "..self.wav.name.." on voice "..voice.." at pos ("..s..","..e..")")
    end
    engine.tt_update(voice,s,e)
  else
    if mode_debug then
      print("playing "..self.wav.name.." on voice "..voice.." at pos ("..s..","..e..")")
    end
    local fx_stutter=override.fx[FX_STUTTER3]==nil and 0 or 1
    local fx_stutter_beats=1/6
    if fx_stutter==0 then
    	fx_stutter=override.fx[FX_STUTTER4]==nil and 0 or 1
    	fx_stutter_beats=1/4
    end
    engine.tt_play(
      voice,-- which sampler player
      self.wav.sc_index,-- buffer number
      amp*ops[self.op_id].amp_global,
      self.pitch_base,
      pitch,
      s,
      e,
      lpf,
      lpf_resonance,
      hpf,
      hpf_resonance,
      override.fx[FX_BITCRUSH]==nil and 0 or 1,
      fx_stutter,
      fx_stutter_beats,
      override.fx[FX_AUTOPAN]==nil and 0 or 1,
      override.fx[FX_REVERSE]==nil and 0 or 1,
      override.fx[FX_OCTAVEUP]==nil and 0 or 1,
      override.fx[FX_OCTAVEDOWN]==nil and 0 or 1
    )
  end
  return voice
end

function Sound:get_start_end(s,e)
  local s=util.linlin(0,1,0,self.wav.duration,s)
  local e=util.linlin(0,1,0,self.wav.duration,e)
  return s,e
end

return Sound


