local Ngen={}

function Ngen:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self

 o.engine={}
  o.engine["amp"]=function(voice,amp)
    engine.tt_amp(voice,amp,0.1)
  end
  o.engine["pitch"]=function(voice,rate)
    engine.tt_rate(voice,pitch.transpose_rate(rate),0.05)
  end
  o.engine["lpf"]=function(voice,lpf,resonance)
    engine.tt_lpf(voice,lpf,0.05,resonance)
  end
  o.engine["hpf"]=function(voice,hpf,resonance)
    engine.tt_hpf(voice,hpf,0.05,resonance)
  end
  o.engine[FX_REVERSE]=function(voice,on)
    print("tt_fx_reverse",on and 1 or 0)
    engine.tt_fx_reverse(voice,on and 1 or 0)
  end
  -- updates modified thigns
  return o
end

function Ngen:update(voice,k,v1,v2,v3)
  if self.engine[k] ~= nil then 
    self.engine[k](voice,v1,v2,v3)
  end
end

function Ngen:fx(voice,fx_id,on)
  print("fx",voice,fx_id)
  if self.engine[fx_id]~=nil then
    self.engine[fx_id](voice,on)
  end
end


return Ngen


