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
  self.__tostring=function(t) return t:to_string() end

  -- parameters
  o.melodic=o.melodic or true
  o.id=o.id or 1

  -- defaults
  o.sample={}
  for i=1,16 do
    o.sample[i]={
      s=0,
      e=1,
      amp=1.0,
      effect=0,
      rate_from_type=i/4,-- TODO calculate from scale
    }
  end
  if not o.melodic then
    for i=1,16 do
      o.sample[i]={
        s=(i-1)/16,
        e=i/16,
        rate_from_type=1,
      }
    end
  end

  o.loaded=false
  return o
end

function Sound:to_string()
  return self.filename
end

-- Sound:load gets audio info and loads into supercollider
function Sound:load(filename)
  -- loads sample
  self.name=filename:match("^.+/(.+).wav$")
  self.ch,self.samples,self.sample_rate=audio.file_info(filename)
  self.duration=self.samples/48000.0
  self.filename=filename

  -- load it into supercollider
  -- engine.tt_load(self.index_sc,self.filename)
  self.loaded=true

  if mode_debug then
    print("loaded "..filename.." into with id "..self.id)
  end
end


-- Sound:press will play a sound from a sample
function Sound:play(i,override)
  local voice=voices:get(self.id)
  local s=override.s or self.sample[i].s
  local e=override.e or self.sample[i].e
  if mode_debug then
    print("playing "..self.name.." on voice "..voice.." at pos ("..s..","..e..")")
  end
  -- engine.tt_play(
  --   voice,
  --   override.amp or self.sample[i].amp,
  --   self.sample[i].rate_from_type,
  --   s,
  --   e,
  --   override.effect or self.sample[i].effect
  -- )
end

-- Sound:get_start_end converts from 0,1 to the actual duration
-- and returns converted s,e and duration
function Sound:get_start_end(s,e)
  s=util.linlin(0,1,0,self.duration,s)
  e=util.linlin(0,1,0,self.duration,e)
  return s,e
end

function Sound:set_start_end(i,s,e)
  if mode_debug then
    print("setting "..self.name.." to pos ("..s..","..e..")")
  end
  self.sample[i].s=s
  self.sample[i].e=e
end


return Sound


