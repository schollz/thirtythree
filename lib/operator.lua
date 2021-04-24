--
-- Operator class
-- contains information for each operator
--

Operator={}


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
  for snd_id=1,16 do
    self:sound_initialize(snd_id)
  end
  -- self.sound[snd_id][smpl_id] => is sound object

  -- patterns
  self.pattern={}
  self.pattern_chain={}
  self.pattern_chain_index=1
  for ptn_id=1,16 do
    self.pattern[ptn_id]={}
    self:pattern_initialize(ptn_id)
    -- pattern is a map of sounds that maps to samples
    -- self.pattern[ptn_id][ptn_step]={fx_id=16,snd={}}
    -- self.pattern[ptn_id][ptn_step].snd[snd_id]=<sound>
  end

  -- params
  self.division=1/4
  self.s=0
  self.e=1
  self.amp=0.5
  self.lpf=20
  self.hpf=20000
  self.resonance=1.0
  self.rate=1

  -- currents
  self.cur_snd_id=1
  self.cur_smpl_id=1
  self.cur_ptn_id=1
  self.cur_ptn_step=0
  self.cur_fx_id=0

  self:buttons_register()

  self:debug("initialized operator")
end

function Operator:to_string()
  return self.filename
end

function Operator:debug(s)
  if mode_debug then
    print("operator"..self.id..": "..s)
  end
end


--
-- sound functions
--

function Operator:sound_initialize(snd_id)
  self.sound[snd_id]={}
  for smpl_id=1,16 do
    local s=0
    local e=1
    if smpl_id>8 then
      s=(smpl_id-1)/16
      e=smpl_id/16
    end
    self.sound[snd_id][smpl_id]=sound:new({
      id=smpl_id,
      group=(self.id-1)*16+snd_id,
      s=s,
      e=e,
      melodic=snd_id<9,
      amp=self.amp,
      rate=self.rate,
      lpf=self.lpf,
      hpf=self.hpf,
      res=self.res,
    })
  end
end

function Operator:sound_load(snd_id,filename)
  for smpl_id=1,16 do
    self.sound[snd_id][smpl_id]:load(filename)
  end
end

function Operator:sound_play_from_press(overwrite)
  overwrite=overwrite or {}
  overwrite.voice=1
  -- show sound
  local snd=self.sound[self.cur_snd_id][self.cur_smpl_id]
  if snd.loaded then
    renderer:expand(snd.wav.filename,snd.s,snd.e)
    snd:play(overwrite)
  end
end

function Operator:sound_clone(snd_id,smpl_id)
  local o=self.sound[snd_id][smpl_id].dump()
  -- overwrite with the current parameters
  o.amp=self.amp
  o.rate=self.rate
  o.lpf=self.lpf
  o.hpf=self.hpf
  o.res=self.res
  return sound:new(o)
end

--
-- drawing
--
function Operator:trim_select()
  local snd=self.sound[self.cur_snd_id][self.cur_smpl_id]
  if not snd.loaded then
    do return end
  end
  renderer:expand(snd.wav.filename,snd.s,snd.e)
end

function Operator:trim_draw()
  if not self.sound[self.cur_snd_id][self.cur_smpl_id].loaded then
    do return end
  end
  renderer:draw(self.sound[self.cur_snd_id][self.cur_smpl_id].wav.filename)
end

function Operator:trim_zoom(sel_looppoint,d)
  if not self.sound[self.cur_snd_id][self.cur_smpl_id].loaded then
    do return end
  end
  renderer:zoom(self.sound[self.cur_snd_id][self.cur_smpl_id].wav.filename,sel_looppoint,d)
end

function Operator:trim_jog(sel_looppoint,d)
  if not self.sound[self.cur_snd_id][self.cur_smpl_id].loaded then
    do return end
  end
  local se=renderer:jog(self.sound[self.cur_snd_id][self.cur_smpl_id].wav.filename,sel_looppoint,d)
  self.sound[self.cur_snd_id][self.cur_smpl_id].s=se[1]
  self.sound[self.cur_snd_id][self.cur_smpl_id].e=se[2]
end


--
-- parameters
--

function Operator:set_trim(s,e)
  -- set current playing
  if self.mode_play and self.buttons[B_WRITE].pressed and self.cur_ptn_step>0 then
    for o,_ in pairs(self.pattern[self.cur_ptn_id][self.cur_ptn_step].snd) do
      o.s=s -- TODO: check that this works
      o.e=e
    end
    do return end
  end

  -- set current selected sound
  local i1=1
  local i2=16
  if self.cur_snd_id>8 then
    -- only change this sound
    i1=self.cur_smpl_id
    i2=self.cur_smpl_id
  end
  for i=i1,i2 do
    self.sound[self.cur_snd_id][i].s=s
    self.sound[self.cur_snd_id][i].s=e
  end
end

--
-- pattern functions
--
function Operator:pattern_step()
  -- increase step
  self.cur_ptn_step=self.cur_ptn_step+1

  if self.cur_ptn_step>16 then
    -- goto next pattern
    self.pattern_chain_index=self.pattern_chain_index+1
    if self.pattern_chain_index>#self.pattern_chain then
      self.pattern_chain_index=1
    end
    self.cur_ptn_id=self.pattern_chain[self.pattern_chain_index]
    self.cur_ptn_step=1
  end

  -- play sounds associated with step
  for _,snd in pairs(self.pattern[self.cur_ptn_id][self.cur_ptn_step].snd) do
    local overwrite=overwrite or {}
    if self.button[B_FX].pressed and self.cur_fx_id>0 and overwrite.effect==nil then
      -- perform effect
      overwrite.effect=self.cur_fx_id
    else
      -- get effect from the pattern
      overwrite.effect=self.pattern[self.cur_ptn_id][self.cur_ptn_step].fx_id
    end
    snd:play(overwrite)
  end
end

function Operator:pattern_reset()
  self.cur_ptn_step=0
end

function Operator:pattern_has_sound(ptn_id)
  for ptn_step,_ in ipairs(self.pattern[ptn_id]) do
    if #self.pattern[ptn_id][ptn_step].snd>0 then
      return true
    end
  end
  return false
end

function Operator:pattern_get_sample_id(ptn_id,ptn_step,snd_id)
  if self.pattern[ptn_id][ptn_step].snd[snd_id]~=nil then
    return self.pattern[ptn_id][ptn_step].snd[snd_id].id -- returns smpl_id or nil
  else
    return nil
  end
end


function Operator:pattern_initialize(ptn_id)
  -- initialize all the steps
  for ptn_step=1,16 do
    self.pattern[ptn_id][ptn_step]={fx_id=16,snd={}}
  end
end

function Operator:pattern_toggle_sample(ptn_id,ptn_step,snd_id,smpl_id)
  if self:pattern_get_sample_id(ptn_id,ptn_step,snd_id)==smpl_id then
    self:debug("pattern_toggle_sample: removing sample "..smpl_id.." from sound "..snd_id.." on pattern "..ptn_id.." step "..ptn_step)
    self.pattern[ptn_id][ptn_step].snd[snd_id]=nil
  else
    self:debug("pattern_toggle_sample: adding sample "..smpl_id.." from sound "..snd_id.." on pattern "..ptn_id.." step "..ptn_step)
    self.pattern[ptn_id][ptn_step].snd[snd_id]=self:sound_clone(snd_id,smpl_id)
  end
end

--
-- button logic
--

function Operator:buttons_register()
  self.mode_fx=false
  self.mode_play=false
  self.mode_write=false
  self.mode_switchpattern=false
  self.mode_adjust=ADJ_NONE
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
      else
        return 5
      end
    end
  end

  --
  -- button positions
  --
  for i=1,3 do
    self.buttons[i].pos=function()
      return 3,i
    end
  end
  for i=B_WRITE,B_RECORD do
    self.buttons[i].pos=function()
      return 8,i-B_WRITE+1
    end
  end
  for i=B_BUTTON_FIRST,B_BUTTON_LAST do
    local b=i-B_BUTTON_FIRST+1
    self.buttons[i].pos=function()
      return math.ceil(b/4.0)+3,(b-1)%4+1
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
      self:pattern_reset()
    else
      self:debug("on_press: play stopped")
    end
  end
  self.buttons[B_SOUND].on_press=function()
    if self.buttons[B_RECORD].pressed then
      -- delete current sound
      self:sound_initialize(self.cur_snd_id)
    end
  end
  self.buttons[B_PATTERN].on_press=function()
    self.mode_switchpattern=true
    if self.buttons[B_RECORD].pressed then
      -- clear current pattern
      self:pattern_initialize(self.cur_ptn_id)
    end
  end
  self.buttons[B_PATTERN].off_press=function()
    self.mode_switchpattern=false
  end
  self.buttons[B_FX].on_press=function()
    if self.mode_play then
      self.mode_fx=true
      self.cur_fx_id=0
    end
  end
  self.buttons[B_FX].off_press=function()
    self.mode_fx=false
  end

  -- steps "1" to "16"
  for i=B_BUTTON_FIRST,B_BUTTON_LAST do
    local b=i-B_BUTTON_FIRST+1 -- the button number [1,16]
    --
    --
    -- button off
    --
    --
    self.buttons[i].off_press=function()
      if self.mode_write then
        -- toggle a step here for the current sound
        self:pattern_toggle_sample(self.cur_ptn_id,self.cur_snd_id,b)
      end
      if self.buttons[B_FX].pressed then
        self.cur_fx_id=0
      end
    end
    --
    --
    -- button presses
    --
    --
    self.buttons[i].on_press=function()
      if self.buttons[B_PATTERN].pressed then
        -- chain pattern
        if self.mode_switchpattern then
          -- new chain
          self:debug("switching pattern to "..i)
          self.pattern_chain={i}
          self.pattern_chain_index=1
          self.cur_ptn_id=i
          self.mode_switchpattern=false
        else
          -- add to the chain
          self:debug("chaining pattern, adding "..i)
          table.insert(self.pattern_chain,i)
        end
      elseif self.buttons[B_SOUND].pressed then
        -- change sound
        self.cur_snd_id=b
      elseif self.buttons[B_FX].pressed and self.mode_play then
        -- update the current effect
        self.cur_fx_id=b
        if self.mode_write then
          -- save effect on current samples
          self:sound_set_fx_all_current()
        end
      elseif not self.mode_write then
        -- set this sample to default
        self.cur_smpl_id=b
        -- play this sample in sound, without effects
        self:sound_play_from_press()
        if self.mode_play and self.buttons[B_WRITE].pressed and self.cur_ptn_step>0 then
          -- put current sound onto current playing step
          self.pattern[self.cur_ptn_id][self.cur_ptn_step].snd[self.cur_snd_id]=self:sound_clone(self.cur_snd_id,self.cur_smpl_id)
          -- TODO (stretch goal): actually, put current sound onto *closest* playing step
        end
      end
    end
    --
    --
    -- lighting of the button
    --
    --
    self.buttons[i].light=function()
      if self.buttons[i].pressed then
        return 14
      end
      if self.buttons[B_SOUND].pressed then
        -- if sound pressed, show if this button has sound loaded / is active sound
        if self.cur_snd_id==b then
          -- active sound
          return 14
        elseif self.sound[b].loaded then
          -- has sound
          return 7
        end
      elseif self.buttons[B_PATTERN].pressed then
        -- if pattern pressed, show if this button has pattern / is active pattern
        if self.cur_ptn_id==b then
          -- active pattern
          return 14
        elseif self:pattern_has_sound(b) then
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
        -- if playing, show indicator of the beat
        if self.mode_play and self.cur_ptn_step==b then
          return 14
        end
        -- show if this button corresponds to the sample of the current sound while playing
        if self.mode_play and self:pattern_get_sample_id(self.cur_ptn_id,b,self.cur_snd_id)==b then
          return 7
        end
        -- TODO (stretch goal): (also, not po-33 but) show dim light if this sound is part of current pattern
      end
    end
  end

  -- done
end


return Operator
