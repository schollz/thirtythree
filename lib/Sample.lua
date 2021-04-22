--
-- Sample class
-- contains information for sample
-- includes splicing informatoin
--

Sample = {}

function Sample:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.__tostring = function(t) return t:to_string() end
  o.index_sc = o.index_sc or 1
  o.splices = {}
  for i=1,16 do 
    o.splices[i]={
      s=(i-1)*16,
      e=i/16,
      amp=1.0,
      effect=0,
    }
  end
  o.type == "melodic" or o.type
  if o.type == "melodic" then
    o.splices[1].e=1
  end
  
  o.loaded = false
  return o
end

function Sample:to_string()
  return self.filename
end

-- Sample:load gets audio info and loads into supercollider
function Sample:load(filename)
  -- loads sample
  self.name = filename:match("^.+/(.+).wav$")
  self.ch, self.samples, self.sample_rate = audio.file_info(filename)
  self.duration = samples / 48000.0
  self.filename = filename

  -- load it into supercollider
  engine.tt_load(self.index_sc,self.filename)
  self.loaded=true

  if mode_debug then 
    print("loaded "..filename.." into sc slot "..self.index_sc)
  end
end


-- Sample:play will play splice i
function Sample:play(i,override)
  local s = override.s or self.splices[i].s
  local e = override.e or self.splices[i].e
  if mode_debug then 
    print("playing "..self.name.." on sc slot "..self.index_sc.." at pos ("..s..","..e..")")
  end
  engine.tt_play(
    self.index_sc,
    override.amp or self.splices[i].amp,
    s,
    e,
    override.effect or self.splices[i].effect,
  )
end

-- Sample:get_start_end converts from 0,1 to the actual duration
-- and returns converted s,e and duration
function Sample:get_start_end(s,e)
  s = util.linlin(0,1,0,self.duration,s)
  e = util.linlin(0,1,0,self.duration,e)
  return s,e,e-s
end

function Sample:set_start_end(i,s,e)
  if mode_debug then 
    print("setting "..self.name.." on sc slot "..self.index_sc.." to pos ("..s..","..e..")")
  end
  self.splices[i].s=s
  self.splices[i].e=e
end

return Sample