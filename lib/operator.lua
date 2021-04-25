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
  o.buttons={}

  return o
end

function Operator:init()
  -- layout
  self.layout=1s

  -- defaults
  self.sound={}
  for snd_id=1,16 do
    self:sound_initialize(snd_id)
  end
  -- self.sound[snd_id][smpl_id] => is sound object

  -- patterns
  self.pattern={}
  self.pattern_chain={1}
  self.pattern_chain_index=1
  for ptn_id=1,16 do
    self.pattern[ptn_id]={}
    self:pattern_initialize(ptn_id)
    -- pattern is a map of sounds that maps to samples
    -- self.pattern[ptn_id][ptn_step]={fx_id=16,snd={},parm={}}
    -- self.pattern[ptn_id][ptn_step].snd[snd_id]=<sound>
    -- self.pattern[ptn_id][ptn_step].lock[snd_id]=<param> -- used for parameter locking
  end

  -- params
  self.division=1/16
  self.s=0
  self.e=1
  self.amp=0.5
  self.is_lpf=true
  self.lpf=20000
  self.hpf=20
  self.resonance=0.0
  self.pitch=0

  -- currents
  self.cur_snd_id=1
  self.cur_smpl_id=1
  self.cur_ptn_id=1
  self.cur_ptn_step=0
  self.cur_fx_id=0

  -- filter
  self.cur_filter_number=51 -- [1,101]

  -- operator "global" parameters
  self.amp_global=1.0
  self.bpm=clock.get_tempo()

  self:buttons_register()

  self:debug("initialized operator")
end

function Operator:backup()
  self:debug("saving")
  local t1=clock.get_beat_sec()*clock.get_beats()
  -- TODO: automatically generate the save name
  local filename=_path.data.."thirtythree/save.json"
  print("saving to ")
  file=io.open(filename,"w+")
  local data={}
  for k,v in pairs(self) do
    data[k]=json.encode(v)
  end
  io.write(json.encode(data))
  io.close
  print("saved in "..(clock.get_beat_sec()*clock.get_beats()-t1).." seconds")
end

function Operator:restore()
  self:debug("loading")
  local t1=clock.get_beat_sec()*clock.get_beats()
  -- TODO: get the last save point
  local filename=_path.data.."thirtythree/save.json"
  if not util.file_exists(filename) then
    print("no save file to load")
    do return end
  end

  local f=io.open(filename,"rb")
  local content=f:read("*all")
  f:close()

  local data=json.decode(content)
  if data==nil then
    print("no data found in save file")
    do return end
  end
  for k,v in pairs(data) do
    self[k]=json.decode(v)
  end
  print("loaded in "..(clock.get_beat_sec()*clock.get_beats()-t1).." seconds")
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
    if snd_id>8 then
      s=(smpl_id-1)/16
      e=smpl_id/16
    end
    local rate=1
    if snd_id<=8 then
      rate=pitch.transpose_rate(INVERTED_KEYBOARD[smpl_id]-9)
    end
    self.sound[snd_id][smpl_id]=sound:new({
      id=smpl_id,
      snd_id=snd_id,
      op_id=self.id,
      s=s,
      e=e,
      melodic=snd_id<9,
      rate=rate,
    })
  end
end

function Operator:sound_load(snd_id,filename)
  for smpl_id=1,16 do
    self.sound[snd_id][smpl_id]:load(filename)
  end
end

function Operator:sound_play_from_press(override)
  override=override or {}
  override.voice=1
  -- show sound
  local snd=self.sound[self.cur_snd_id][self.cur_smpl_id]
  if snd.loaded then
    renderer:expand(snd.wav.filename,snd.s,snd.e)
    snd:play(override)
  end
end

function Operator:sound_clone(snd_id,smpl_id)
  local o=self.sound[snd_id][smpl_id]:dump()
  return sound:new(o)
end

--
-- parameters
--
function Operator:volume_draw()
  graphics:volume(self.amp)
end

function Operator:volume_set(d)
  self.amp=util.clamp(self.amp+d/100,0,1)
  if self.buttons[B_WRITE].pressed and self.mode_play then
    -- add parameter lock for volume
    self:debug("updating lock for amp on snd_id "..self.cur_snd_id.." to "..self.amp)
    local next_step=(self.cur_ptn_step-1+1)%16+1
    self.pattern[self.cur_ptn_id][next_step].lock[self.cur_snd_id]:set("amp",self.amp)
  else
    for i=1,16 do
      self.sound[self.cur_snd_id][i].amp=self.amp
    end
  end
end

function Operator:pitch_draw()
  graphics:pitch(self.pitch)
end

function Operator:pitch_set(d)
  self.pitch=util.clamp(self.pitch+math.sign(d),-12,12)
end

function Operator:filter_draw()
  if self.is_lpf then
    graphics:filter("lowpass",self.lpf,self.resonance)
  else
    graphics:filter("highpass",self.hpf,self.resonance)
  end
end

function Operator:resonance_set(d)
  self.resonance=util.clamp(self.resonance+d/100,0,1)
end

function Operator:filter_set(d)
  self.cur_filter_number=util.clamp(self.cur_filter_number+d,1,101)
  if self.cur_filter_number>50 then
    self.hpf=util.linexp(51,101,20,20000,self.cur_filter_number)
    self.is_lpf=false
  else
    self.lpf=util.linexp(1,50,20,20000,self.cur_filter_number)
    self.is_lpf=true
  end
  graphics:update()
end

function Operator:trim_select()
  local snd=self.sound[self.cur_snd_id][self.cur_smpl_id]
  if not snd.loaded then
    do return end
  end
  renderer:expand(snd.wav.filename,snd.s,snd.e)
end

function Operator:trim_draw()
  if not self.sound[self.cur_snd_id][self.cur_smpl_id].loaded then
    graphics:text_center("no sound loaded")
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
  if se==nil then
    do return end
  end

  if self.mode_play and self.buttons[B_WRITE].pressed and self.cur_ptn_step>0 then
    -- set current playing
    for snd_id,snd in pairs(self.pattern[self.cur_ptn_id][self.cur_ptn_step].snd) do
      self:debug("updating trim "..sel_looppoint.." on snd "..snd_id.." sample "..snd.id)
      if sel_looppoint==1 then
        snd.s=se
      else
        snd.e=se
      end
    end
  else
    -- set the trim on the current sound
    if self.cur_snd_id<9 then
      -- if melodic, set the trim for *all* sounds
      for i=1,16 do
        if sel_looppoint==1 then
          self.sound[self.cur_snd_id][i].s=se
        else
          self.sound[self.cur_snd_id][i].e=se
        end
      end
    else
      -- set current sound
      if sel_looppoint==1 then
        self.sound[self.cur_snd_id][self.cur_smpl_id].s=se
      else
        self.sound[self.cur_snd_id][self.cur_smpl_id].e=se
      end
    end
  end

end



--
-- pattern functions
--
function Operator:pattern_step()
  if clock.get_tempo()~=self.bpm then 
    self.bpm=clock.get_tempo()
  end
  if not self.mode_play then
    do return end
  end
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
    self:debug("continuing with pattern "..self.cur_ptn_id)
  end

  -- play sounds associated with step
  for snd_id,snd in pairs(self.pattern[self.cur_ptn_id][self.cur_ptn_step].snd) do
    self:debug("pattern_step: playing sound "..snd_id.." sample "..snd.id)
    local override={}
    if self.buttons[B_FX].pressed and self.cur_fx_id>0 and override.effect==nil then
      -- perform effect
      override.effect=self.cur_fx_id
    else
      -- get effect from the pattern
      override.effect=self.pattern[self.cur_ptn_id][self.cur_ptn_step].fx_id
    end
    if snd.loaded then
      -- override with parameter locks
      for k,v in pairs(self.pattern[self.cur_ptn_id][self.cur_ptn_step].lock[snd_id].modified) do
        self:debug("override with parameter lock "..k..": "..v)
        override[k]=v
      end
      snd:play(override)
      if self.cur_snd_id==snd_id and (not self.buttons[B_WRITE].pressed) then
        renderer:expand(snd.wav.filename,snd.s,snd.e)
      end
    end
  end
  -- update sound with parameter locks for any sound thats doing stuff in the pattern
  local snd_list=self:pattern_sound_list(self.cur_ptn_id)
  tab.print(snd_list)
  for snd_id,_ in pairs(snd_list) do
    print(snd_id,"in pattern")
    self.pattern[self.cur_ptn_id][self.cur_ptn_step].lock[snd_id]:play_if_locked()
  end
end

function Operator:pattern_reset()
  self.cur_ptn_step=0
end

function Operator:pattern_sound_list(ptn_id)
  local snd_list={}
  for ptn_step,_ in ipairs(self.pattern[ptn_id]) do
    for snd_id,_ in pairs(self.pattern[ptn_id][ptn_step].snd) do
      snd_list[snd_id]=true
    end
  end
  return snd_list
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

function Operator:pattern_has_sample(ptn_id,snd_id,smpl_id)
  for ptn_step,_ in pairs(self.pattern[ptn_id]) do
    for snd_id2,snd in pairs(self.pattern[ptn_id][ptn_step].snd) do
      if snd_id2==snd_id and snd.id==smpl_id then
        do return true end
      end
    end
  end
  return false
end


function Operator:pattern_initialize(ptn_id)
  -- initialize all the steps
  for ptn_step=1,16 do
    self.pattern[ptn_id][ptn_step]={fx_id=16,snd={},lock={}}
    for snd_id=1,16 do
      self.pattern[ptn_id][ptn_step].lock[snd_id]=lock:new({snd_id=snd_id})
    end
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
  self:pattern_remove_locks(ptn_id,ptn_step,snd_id)
end


-- pattern_remove_locks removes locks from
-- ptn_step until next step with a slice from snd_id
function Operator:pattern_remove_locks(ptn_id,ptn_step,snd_id)
  for i=1,16 do
    local step=((ptn_step+i-2)%16)+1
    -- always remove first one
    if i==1 then
      self.pattern[ptn_id][step].lock[snd_id]=lock:new({snd_id=snd_id})
    elseif self.pattern[ptn_id][step].snd[snd_id]~=nil then
      break
    else
      self.pattern[ptn_id][step].lock[snd_id]=lock:new({snd_id=snd_id})
    end
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
        -- if recording, ignore all on presses!
        if recorder.is_recording then
          do return end
        end
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
        return 10
      else
        return 5
      end
    end
    self.buttons[i].pos=function()
      local startrow=PO33_LAYOUT[self.layout][24][1]
      local startcol=PO33_LAYOUT[self.layout][24][2]*(self.id-1)+1
      return PO33_LAYOUT[self.layout][i][1]+startrow,PO33_LAYOUT[self.layout][i][2]+startcol
    end
  end

  self.buttons[B_FX].on_short_press=function()
    sel_adj=sel_adj+1
    if sel_adj<ADJ_FIRST then
      sel_adj=ADJ_LAST
    elseif sel_adj>ADJ_LAST then
      sel_adj=ADJ_FIRST
    end
    graphics:update()
  end
  self.buttons[B_WRITE].on_short_press=function()
    self.mode_write=not self.mode_write
    if self.mode_write then
      self:debug("on_short_press: write mode")
    else
      self:debug("on_short_press: performance mode")
    end
  end
  self.buttons[B_WRITE].light=function()
    if self.mode_write then
      return 10
    else
      return 5
    end
  end
  self.buttons[B_PLAY].on_press=function()
    if self.buttons[B_WRITE].pressed and self.buttons[B_SOUND].pressed then
      self:backup()
      do return end
    end
    self.mode_play=not self.mode_play
    if self.mode_play then
      self:debug("on_press: play activated")
      self:pattern_reset()
    else
      self:debug("on_press: play stopped")
    end
  end
  self.buttons[B_PLAY].light=function()
    if self.mode_play then
      return 10
    else
      return 5
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
  self.buttons[B_RECORD].on_press=function()
    if self.buttons[B_WRITE].pressed and self.buttons[B_SOUND].pressed then
      self:restore()
    end
  end
  self.buttons[B_RECORD].off_press=function()
    if recorder.is_recording then
      recorder:record_stop()
      local fname=recorder:recorded_file()
      if fname~=nil then
        -- there was a recording, load it into the currenet sound
        self:sound_load(self.cur_snd_id,fname)
      end
    end
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
        -- preventing setting write buttons while doing other stuff
        for j=B_FIRST,B_BUTTON_FIRST-1 do
          if self.buttons[j].pressed then
            do return end
          end
        end
        for j=B_BUTTON_LAST+1,B_LAST do
          if self.buttons[j].pressed then
            do return end
          end
        end
        -- toggle a step here for the current sound
        self:pattern_toggle_sample(self.cur_ptn_id,b,self.cur_snd_id,self.cur_smpl_id)
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
      if self.buttons[B_PATTERN].pressed and self.buttons[B_WRITE].pressed then
        -- copy current pattern to the new button
        if self.cur_ptn_id ~= b then
          self.pattern[b]=json.decode(json.encode(self.pattern[self.cur_ptn_id]))
        end
      elseif self.buttons[B_PATTERN].pressed then
        -- chain pattern
        if self.mode_switchpattern then
          -- new chain
          self:debug("switching pattern to "..b)
          self.pattern_chain={b}
          self.pattern_chain_index=1
          self.cur_ptn_id=b
          self.mode_switchpattern=false
        else
          -- add to the chain
          self:debug("chaining pattern, adding "..b)
          table.insert(self.pattern_chain,b)
        end
      elseif self.buttons[B_BPM].pressed then
        -- change the global amp volume
        self.amp_global=util.linlin(1,16,0,2,b)
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
      elseif self.buttons[B_RECORD].pressed then
        -- record into this sample
        self.cur_snd_id=b
        sel_adj=ADJ_TRIM
        recorder:record_start()
      elseif not self.mode_write then
        -- set this sample to default
        self.cur_smpl_id=b
        -- play this sample in sound, without effects
        self:sound_play_from_press()
        if self.mode_play and self.buttons[B_WRITE].pressed and self.cur_ptn_step>0 then
          -- put current sound onto current playing step
          self.pattern[self.cur_ptn_id][self.cur_ptn_step].snd[self.cur_snd_id]=self:sound_clone(self.cur_snd_id,self.cur_smpl_id)
          self:pattern_remove_locks(self.cur_ptn_id,self.cur_ptn_step,self.cur_snd_id)
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
        return 10
      end
      if self.buttons[B_SOUND].pressed then
        -- if sound pressed, show if this button has sound loaded / is active sound
        if self.cur_snd_id==b then
          -- active sound
          return 10
        elseif self.sound[b][1].loaded then
          -- has sound
          return 4
        end
      elseif self.buttons[B_BPM].pressed then
        local val=util.linlin(0,2,1,16,self.amp_global)
        if b<=val then
          return 14
        end
      elseif self.buttons[B_PATTERN].pressed then
        -- if pattern pressed, show if this button has pattern / is active pattern
        if self.cur_ptn_id==b then
          -- active pattern
          return 10
        elseif self:pattern_has_sound(b) then
          -- has pattern
          return 7
        end
      elseif self.mode_play and self.cur_ptn_step==b then
        -- if playing, show indicator of the beat
        return 15
      elseif self.mode_write then
        -- if write mode, show if this button has current sound and this sample in it
        local ptn_step=b
        local ptn_smpl_id=self:pattern_get_sample_id(self.cur_ptn_id,ptn_step,self.cur_snd_id)
        if ptn_smpl_id==self.cur_smpl_id then
          return 10
        elseif ptn_smpl_id~=nil then
          return 3
        end
      elseif self:pattern_has_sample(self.cur_ptn_id,self.cur_snd_id,b) then
        -- show if this button corresponds to the sample of the current sound while playing
        -- return 1
        -- TODO (stretch goal): (also, not po-33 but) show dim light if this sound is part of current pattern
      end
    end
  end

  -- done
end


return Operator
