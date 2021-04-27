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
    engine.tt_fx_reverse(voice,on and 1 or 0)
  end
  o.engine[FX_BITCRUSH]=function(voice,on)
    engine.tt_bitcrush(voice,on and 1 or 0,8,12000)
  end
  o.engine[FX_TIMESTRETCH]=function(voice,on)
    engine.tt_fx_timestretch(voice,on and 1 or 0,4,4)
  end
  o.engine[FX_OCTAVE_UP]=function(voice,on)
    engine.tt_fx_octaveup(voice,on and 1 or 0)
  end
  o.engine[FX_OCTAVE_DOWN]=function(voice,on)
    engine.tt_fx_octavedown(voice,on and 1 or 0)
  end
  o.engine[FX_AUTOPAN]=function(voice,on)
    engine.tt_fx_autopan(voice,on and 1 or 0)
  end
  o.engine[FX_SCRATCH]=function(voice,on)
    engine.tt_fx_scratch(voice,on and 1 or 0)
  end
  o.engine[FX_STROBE]=function(voice,on)
    engine.tt_fx_strobe(voice,on and 1 or 0)
  end
  o.engine[FX_STUTTER]=function(voice,on,snd)
    local s=math.random(math.floor(snd.s*1000),math.floor(snd.e*1000))/1000
    local e=s+clock.get_beat_sec()/snd.wav.duration/4
    engine.tt_fx_loop(voice,s,s,e,1)
  end
  o.engine[FX_LOOP]=function(voice,on,snd)
    local s=snd.s
    local e=s+clock.get_beat_sec()/snd.wav.duration
    engine.tt_fx_loop(voice,s,s,e,1)
  end
  -- updates modified thigns
  return o
end

function Ngen:update(voice,k,v1,v2,v3)
  if self.engine[k]~=nil then
    self.engine[k](voice,v1,v2,v3)
  end
end

function Ngen:fx(snd,fx_id,on)
  local voice=voices:get_voice(snd.id)
  if voice==nil then
    do return end
  end
  print("fx",voice,fx_id)
  if self.engine[fx_id]~=nil then
    self.engine[fx_id](voice,on,snd)
  end
end


return Ngen


