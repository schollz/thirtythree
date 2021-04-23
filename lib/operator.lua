--
-- Operator class
-- contains information for each operator
--

Operator={}

B_SOUND=1
B_PATTERN=2
B_BPM=3
B_BUTTON_FIRST=4
B_BUTTON_LAST=19
B_WRITE=20
B_PLAY=21
B_FX=22
B_RECORD=23

function Operator:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  self.__tostring=function(t) return t:to_string() end

  -- parameters
  o.id=o.id or 1

  return o
end

function Operator:init()
  -- defaults
  self.sound={}
  for i=1,16 do
    self:sound_initialize(i)
  end

  -- patterns
  self.pattern={}
  self.pattern_chain={}
  for ptn_id=1,16 do
    self.pattern[ptn_id]={}
    self:pattern_initialize(ptn_id)
    -- pattern is a map of sounds that maps to samples
    -- self.pattern[ptn_id][ptn_step]={fx_id=16,snd={}}
    -- self.pattern[ptn_id][ptn_step].snd[snd_id]=smpl_id
  end

  -- current effect
  self.effect_current=0

  -- TODO: current pitch / amp /filter

  -- currents
  self.cur_snd_id=1
  self.cur_smpl_id=1
  self.cur_ptn_id=1
  self.cur_ptn_step=1

  self:debug("initialized operator")
end

function Operator:to_string()
  return self.filename
end

function Operator:pattern_initialize(ptn_id)
  -- initialize all the steps
  for ptn_step=1,16 do
    self.pattern[ptn_id][ptn_step]={fx_id=16,snd_id=0,smpl_id=0}
  end
end

function Operator:sound_initialize(i)
  self.sound[i]=sound_:new({
    id=(self.id-1)*16+i,
    melodic=i<9,
  })
end

function Operator:debug(s)
  if mode_debug then
    print("operator"..self.id..": "..s)
  end
end

function Operator:sound_load(i,filename)
  self.sound[i]:load(filename)
end

function Operator:sound_play(snd_id,smpl_id)
  overwrite={}
  if self.button[B_FX].pressed and self.effect_current>0 then
    overwrite.effect=self.effect_current
  end
  -- TODO: check for overwriting filter/pitch
  self:sound[snd_id]:play(smpl_id,overwrite)
end

function Operator:sound_set_fx(snd_id,smpl_id,fx_id)
  self:sound[snd_id]:set_fx(smpl_id,fx_id)
end

function Operator:sound_set_fx_all_current()
  -- TODO
end

function Operator:pattern_get_sample(ptn_id,ptn_step,snd_id)
  return self.pattern[ptn_id][ptn_step].snd[snd_id] -- returns smpl_id or nil
end

function Operator:pattern_toggle_sample(ptn_id,ptn_step,snd_id,smpl_id)
  if self:pattern_get_sample(ptn_id,ptn_step,snd_id)==smpl_id then
    self:debug("pattern_toggle_sample: removing sample "..smpl_id.." from sound "..snd_id.." on pattern "..ptn_id.." step "..ptn_step)
    self.pattern[ptn_id][ptn_step].snd[snd_id]=nil
  else
    self:debug("pattern_toggle_sample: adding sample "..smpl_id.." from sound "..snd_id.." on pattern "..ptn_id.." step "..ptn_step)
    self.pattern[ptn_id][ptn_step].snd[snd_id]=smpl_id
  end
end

function Operator:buttons_register()
  self.mode_fx=false
  self.mode_play=false
  self.mode_write=false
  self.mode_switchpattern=false
  self.buttons={}
  for i=1,23 do
    self.buttons[i]={pressed=false,time_press=0}
    self.buttons[i].press=function(on)
      self.buttons[i].pressed=on
      if on then
        self:debug("buttons_register: button "..i.." pressed on")
        self.buttons[i].time_press=os.clock()
        if self.buttons[i].on_press~=nil then
          self.buttons[i].on_press()
        end
      else
        self:debug("buttons_register: button "..i.." pressed off")
        local cur_time=os.clock()
        if cur_time-self.buttons[i].time_press<0.04 and self.buttons[i].on_short_press~=nil then
          -- long press
          self.buttons[i].on_short_press()
        elseif self.buttons[i].off_press~=nil then
          self.buttons[i].off_press()
        end
      end
    end
    self.buttons[i].light=function()
      if self.buttons[i].pressed then
        return 14
      end
    end
  end

  self.buttons[B_WRITE].on_short_press=function()
    self.mode_write=not self.mode_write
    if self.mode_write then
      self:debug("on_short_press: write mode")
    else
      self:debug("on_short_press: performance mode")
    end
  end
  self.buttons[B_PLAY].on_press=function()
    self.mode_play=not self.mode_play
    if self.mode_play then
      self:debug("on_press: play activated")
    else
      self:debug("on_press: play stopped")
    end
  end
  self.buttons[B_SOUND].on_press=function()
    if self.buttons[B_RECORD].pressed then
      -- TODO: delete current sound
    end
  end
  self.buttons[B_PATTERN].on_press=function()
    self.mode_switchpattern=true
    if self.buttons[B_RECORD].pressed then
      -- TODO: clear current pattern
    end
  end
  self.buttons[B_PATTERN].off_press=function()
    self.mode_switchpattern=false
  end
  self.buttons[B_FX].on_press=function()
    if self.mode_play then
      self.mode_fx=true
      self.effect_current=0
    end
  end
  self.buttons[B_FX].off_press=function()
    self.mode_fx=false
  end

  -- steps "1" to "16"
  for i=B_BUTTON_FIRST,B_BUTTON_LAST do
    b=i-B_BUTTON_FIRST+1 -- the button number [1,16]
    self.buttons[i].off_press=function()
      if self.mode_write then
        -- toggle a step here for the current sound
        self:pattern_toggle_sample(self.pattern_current,self.sound_current,b)
      end
      if self.buttons[B_FX].pressed then
        self.effect_current=0
      end
    end
    self.buttons[i].on_press=function()
      if self.buttons[B_PATTERN].pressed then
        -- chain pattern
        if self.mode_switchpattern then
          -- new chain
          self:debug("switching pattern to "..i)
          self.pattern_chain={i}
          self.pattern_current=i
          self.mode_switchpattern=false
        else
          -- add to the chain
          self:debug("chaining pattern, adding "..i)
          table.insert(self.pattern_chain,i)
        end
      elseif self.buttons[B_SOUND].pressed then
        -- change sound
        self.sound_current=b
      elseif self.buttons[B_FX].pressed and self.mode_play then
        -- update the current effect
        self.effect_current=b
        if self.mode_write then
          -- save effect on current samples
          self:sound_set_fx_all_current()
        end
      elseif not self.mode_write then
        -- TODO: play this sound
        if self.mode_play and self.buttons[B_WRITE].pressed then
          -- TODO: put current sound onto current playing step
        end
      end
    end
    self.buttons[i].light=function()
      if self.buttons[i].pressed then
        return 14
      end
      if self.buttons[B_SOUND].pressed then
        -- if sound pressed, show if this button has sound loaded / is active sound
        if self.sound_current==b then
          -- active sound
          return 14
        elseif self.sound[b].loaded then
          -- has sound
          return 7
        end
      elseif self.buttons[B_PATTERN].pressed then
        -- if pattern pressed, show if this button has pattern / is active pattern
        if self.pattern_current==b then
          -- active pattern
          return 14
        elseif #self.pattern[i]>0 then
          -- has pattern
          return 7
        end
      elseif self.mode_write then
        -- if write mode, show if this button has current sound and this sample in it
        local ptn_step=b
        local ptn_smpl_id=self:pattern_get_sample(self.cur_ptn_id,ptn_step,self.cur_snd_id)
        if ptn_smpl_id==self.cur_smpl_id then
          return 14
        elseif ptn_smpl_id~=nil then
          return 7
        end
      elseif not self.mode_write then
        -- TODO: if performance mode, show if this button corresponds to the sound playing
        -- TODO: (also, not po-33 but) show dim light if this sound is part of current pattern
      end
    end
  end

  -- done
end


return Operator
