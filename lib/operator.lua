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
  -- defaults
  self.sound={}
  self.sound_prevent={}
  self.sound_fx_current={}
  for snd_id=1,16 do
    self.sound_fx_current[snd_id]={}
    for fx_id=1,16 do
      self.sound_fx_current[snd_id][fx_id]=false
    end
    self.sound_prevent[snd_id]=false -- used to prevent new sounds when using fx
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
    -- self.pattern[ptn_id][ptn_step]={snd={},plock={},flock={}}
    -- self.pattern[ptn_id][ptn_step].snd[snd_id]=<sound>
    -- self.pattern[ptn_id][ptn_step].plock[snd_id]=<param> -- used for parameter locking
    -- self.pattern[ptn_id][ptn_step].flock[snd_id][fx_id]=true -- used for fx locking
  end

  -- params
  self.division=1/16
  self.s=0
  self.e=1
  self.amp=0.5
  self.is_lpf=true
  self.lpf=20000
  self.hpf=20
  self.resonance=1.0
  self.pitch=0

  -- currents
  self.cur_snd_id=1
  self.cur_smpl_id=1
  self.cur_ptn_id=1
  self.cur_ptn_step=0
  self.cur_ptn_sync_step=0
  self.cur_fx_id={}
  self.skip_sound_once=0

  -- filter
  self.cur_filter_number=51 -- [1,101]

  -- operator "global" parameters
  self.amp_global=1.0
  self.swing=50
  self.cur_scale=1

  self:buttons_register()

  self:debug("initialized operator")
end

function Operator:marshal()
  local data={}
  for k,v in pairs(self) do
    print(k,v)
    if k~="buttons" and k~="pattern" and k~="sound" and k~="sound_prevent" and k~="mode_write" and k~="mode_play" and k~="sound_fx_current" then
      self:debug("encoding "..k)
      data[k]=json.encode(v)
    end
  end
  data.pattern={}
  for ptn_id,_ in ipairs(self.pattern) do
    for ptn_step,_ in ipairs(self.pattern[ptn_id]) do
      for snd_id,snd in pairs(self.pattern[ptn_id][ptn_step].snd) do
        if snd.loaded==true then
          table.insert(data.pattern,{"snd",ptn_id,ptn_step,snd_id,snd:marshal()})
        end
      end
      for snd_id,plock in pairs(self.pattern[ptn_id][ptn_step].plock) do
        if not table.isempty(plock) then
          table.insert(data.pattern,{"plock",ptn_id,ptn_step,snd_id,plock:marshal()})
        end
      end
      for snd_id,flock in pairs(self.pattern[ptn_id][ptn_step].flock) do
        if not table.isempty(plock) then
          table.insert(data.pattern,{"flock",ptn_id,ptn_step,snd_id,json.encode(flock)})
        end
      end
    end
  end
  data.sound={}
  for snd_id,_ in ipairs(self.sound) do
    for smpl_id,snd in ipairs(self.sound[snd_id]) do
      if snd.loaded then
        table.insert(data.sound,{snd_id,smpl_id,snd:marshal()})
      end
    end
  end
  return json.encode(data)
end

function Operator:unmarshal(content)
  local data=json.decode(content)
  if data==nil then
    print("no data found in save file")
    do return end
  end

  -- reinitialize
  self:init()

  for k,v in pairs(data) do
    if k~="buttons" and k~="pattern" and k~="sound" then
      self[k]=json.decode(v)
    end
  end

  for _,p in ipairs(data.pattern) do
    ptn_id=p[2]
    ptn_step=p[3]
    snd_id=p[4]
    if p[1]=="snd" then
      self.pattern[ptn_id][ptn_step].snd[snd_id]=sound:new()
      self.pattern[ptn_id][ptn_step].snd[snd_id]:unmarshal(p[5])
    elseif p[1]=="plock" then
      self.pattern[ptn_id][ptn_step].plock[snd_id]:unmarshal(p[5])
    elseif p[1]=="flock" then
      self.pattern[ptn_id][ptn_step].flock[snd_id]=json.decode(p[5])
    end
  end

  for _,p in ipairs(data.sound) do
    snd_id=p[1]
    smpl_id=p[2]
    self.sound[snd_id][smpl_id]:unmarshal(p[3])
  end
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
function Operator:sound_current_name()
  if self.sound[self.cur_snd_id][1].wav ~= nil then 
    do return self.sound[self.cur_snd_id][1].wav.name end
  end
  return ""
end

function Operator:sound_initialize(snd_id)
  self.sound[snd_id]={}
  for smpl_id=1,16 do
    local s=0
    local e=1
    if snd_id>8 then
      s=(smpl_id-1)/16
      e=smpl_id/16
    end
    local pitch=0
    if snd_id<=8 then
       -- pitch=INVERTED_KEYBOARD[smpl_id]-9
      if self.cur_scale==nil then 
        self.cur_scale=1
      end
      local scale=MusicUtil.generate_scale_of_length(0,self.cur_scale,96)
      pitch=scale[INVERTED_KEYBOARD_MAP[smpl_id]+27]-60
    end
    self.sound[snd_id][smpl_id]=sound:new({
      id=smpl_id,
      snd_id=snd_id,
      op_id=self.id,
      s=s,
      e=e,
      melodic=snd_id<9,
      pitch_base=pitch,
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
    if sel_operator==self.id then
      renderer:expand(snd.wav.filename,snd.s,snd.e)
    end
    snd:play(override)
  end
end

function Operator:sound_clone(snd_id,smpl_id)
  local o=self.sound[snd_id][smpl_id]:dump()
  o.pitch_base=o.pitch_base+o.pitch -- rebase the pitch
  return sound:new(o)
end

--
-- parameters
--
function Operator:parameter_update_sounds_and_locks(k,v,update,v2,v3)
  if self.buttons[B_WRITE].pressed and self.mode_play then
    if (type(v)~="boolean") then
      self:debug("updating lock for "..k.." on snd_id "..self.cur_snd_id.." to "..v)
    else
      self:debug("updating lock for "..k.." on snd_id "..self.cur_snd_id)
    end
    local next_step=(self.cur_ptn_step-1+1)%16+1
    self.pattern[self.cur_ptn_id][next_step].plock[self.cur_snd_id]:set(k,v)
  else
    for i=1,16 do
      self.sound[self.cur_snd_id][i][k]=v
    end
    -- update current engine
    if update==nil or update==true then
      ngen:update(1,k,v,v2,v3)
      ngen:update(2,k,v,v2,v3)
    end
  end
end

function Operator:volume_draw()
  graphics:volume(self.amp)
end

function Operator:volume_set(d)
  self.amp=util.clamp(self.amp+d/100,0,1)
  self:debug("updating volume to "..self.amp)
  self:parameter_update_sounds_and_locks("amp",self.amp)
end

function Operator:pitch_draw()
  graphics:pitch(self.pitch)
end

function Operator:pitch_set(d)
  self.pitch=util.clamp(self.pitch+math.sign(d),-12,12)
  -- determine pitch based on the scale
  local note = 0
  if self.pitch ~= 0 then 
    local notes = MusicUtil.generate_scale_of_length(0,self.cur_scale,96)
    note=notes[36+self.pitch]-60 -- note relative to a fixed root of "C"
  end
  self:parameter_update_sounds_and_locks("pitch",note)
end

function Operator:filter_draw()
  if self.is_lpf then
    graphics:filter("lowpass",self.lpf,self.resonance)
  else
    graphics:filter("highpass",self.hpf,self.resonance)
  end
end

function Operator:resonance_set(d)
  self.resonance=util.clamp(self.resonance+d/100,0.1,1)
  self:parameter_update_sounds_and_locks("resonance",self.resonance,false) -- add to lock but don't update
  graphics:update()
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
  self:parameter_update_sounds_and_locks("lpf",self.lpf,self.is_lpf==true,self.resonance)
  self:parameter_update_sounds_and_locks("is_lpf",self.is_lpf,false)
  self:parameter_update_sounds_and_locks("hpf",self.hpf,self.is_lpf==false,self.resonance)
  self:parameter_update_sounds_and_locks("resonance",self.resonance,false) -- add to lock but don't update
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
  -- update the tempo each step (if needed)
  if clock.get_tempo()~=self.bpm then
    self.bpm=clock.get_tempo()
    -- update engine (only first operator does this)
    if self.id==1 then
      engine.tt_bpm(self.bpm)
    end
  end

  -- skip the rest if not playing
  if not self.mode_play then
    do return end
  end

  -- increase step
  self.cur_ptn_step=self.cur_ptn_step+1
  self.cur_ptn_sync_step=self.cur_ptn_sync_step+1
  self:debug("cur_ptn_step: "..self.cur_ptn_step)

  -- jump to next pattern or return to beginning
  if self.cur_ptn_step>16 or self.cur_ptn_sync_step%16==1 then
    -- goto next pattern
    self.pattern_chain_index=self.pattern_chain_index+1
    if self.pattern_chain_index>#self.pattern_chain then
      self.pattern_chain_index=1
    end
    self.cur_ptn_id=self.pattern_chain[self.pattern_chain_index]
    self.cur_ptn_step=1
    self:debug("continuing with pattern "..self.cur_ptn_id)
  end

  -- if holding down write after selecting parameter,
  -- then continually lock in that parameter
  if self.buttons[B_WRITE].pressed and self.mode_play then
    if sel_parm==PARM_VOLUME then
      self:volume_set(0) -- add 0 will adjust it by nothing by call all the updates
    end
    if sel_parm==PARM_PITCH then
      self:pitch_set(0) -- add 0 will adjust it by nothing by call all the updates
    end
    if sel_parm==PARM_FILTER then
      self:filter_set(0) -- add 0 will adjust it by nothing by call all the updates
      self:resonance_set(0) -- add 0 will adjust it by nothing by call all the updates
    end
  end


  -- determine effects to play with sound from parameter locks
  local fx_to_play={}
  for i=1,16 do
    fx_to_play[i]={}
  end
  for snd_id,snd in pairs(self.pattern[self.cur_ptn_id][self.cur_ptn_step].snd) do
    -- if no FX are pressed, apply FX from parameter locks
    for fx_id,dofx in pairs(self.pattern[self.cur_ptn_id][self.cur_ptn_step].flock[snd_id]) do
      if dofx and not FX_LOOPING[fx_id] then
        fx_to_play[snd_id][fx_id]=true
      end
    end
  end

  -- special case: punch-in effects into the current sound
  if self.buttons[B_FX].pressed then
    for i=B_BUTTON_FIRST,B_BUTTON_LAST do
      local fx_id=i-B_BUTTON_FIRST+1
      if self.buttons[i].pressed then
        if not FX_LOOPING[fx_id] then
          -- play fx
          fx_to_play[self.cur_snd_id][fx_id]=true
          -- play fx globally
          if params:get("fx global")==2 then
            self:debug("applying fx "..fx_id.." to all")
            for snd_id2=1,16 do 
              fx_to_play[snd_id2][fx_id]=true
            end
          end
        end
        if self.mode_write then
          -- save this fx
          self.pattern[self.cur_ptn_id][self.cur_ptn_step].flock[self.cur_snd_id][fx_id]=true
          -- save this fx globally
          if params:get("fx global")==2 then
            for snd_id2=1,16 do 
               self.pattern[self.cur_ptn_id][self.cur_ptn_step].flock[snd_id2][fx_id]=true
            end
          end
          if fx_id==FX_NONE then
            -- erase fx
            for j=1,16 do
              self.pattern[self.cur_ptn_id][self.cur_ptn_step].flock[self.cur_snd_id][j]=false
            end
            -- erase fx globally
            if params:get("fx global")==2 then
              for snd_id2=1,16 do 
                for j=1,16 do
                   self.pattern[self.cur_ptn_id][self.cur_ptn_step].flock[snd_id2][j]=false
                 end
              end
            end
          end
        end
      end
    end
  end

  -- play sounds associated with step
  local snd_played=nil
  local snds_played={}
  for snd_id,snd in pairs(self.pattern[self.cur_ptn_id][self.cur_ptn_step].snd) do
    self:debug("pattern_step: playing sound "..snd_id.." sample "..snd.id)

    -- check if it is already doing a looping effect
    local is_looping=false
    for fx_id,fx_val in pairs(self.sound_fx_current[snd_id]) do
      if FX_LOOPING[fx_id] and fx_val then
        is_looping=true
        break
      end
    end

    if self.sound_prevent[snd_id]==true then
      self:debug("sound prevented!")
    end
    if not snd.loaded then
      self:debug("not loaded!")
    end
    -- if snd.loaded and (not self.sound_prevent[snd_id]) then
    if snd.loaded and snd_id~=self.skip_sound_once then
      -- override with parameter locks
      local override={}
      for k,v in pairs(self.pattern[self.cur_ptn_id][self.cur_ptn_step].plock[snd_id].modified) do
        if type(v)~="boolean" then
          self:debug("override with parameter lock "..k..": "..v)
        else
          self:debug("override with parameter lock "..k)
        end
        override[k]=v
      end
      override.fx={}
      if not fx_to_play[snd_id][FX_NONE] then
        override.fx=fx_to_play[snd_id]
      end
      for fx_id,fx_apply in pairs(override.fx) do
        -- prevent it from being triggered again after sounding
        -- but only take care of ones that can be sounded
        if fx_id~=FX_RETRIGGER and fx_id~=FX_68 and FX_LOOPING[fx_id]==false then
          self.sound_fx_current[snd_id][fx_id]=fx_apply
        end
        self:debug("playing fx "..fx_id.." on sound "..snd_id)
      end
      snd_played=snd
      if is_looping then
        -- pass override voice so that it uses sound update
        override.voice=voices:get_voice(self.id,snd_id)
        if override.voice~=nil then
          voices:lock(voice,override.voice)
        end
      end
      snd:play(override)
      snds_played[snd_id]=true
      if self.cur_snd_id==snd_id and (not self.buttons[B_WRITE].pressed) and self.id==sel_operator then
        renderer:expand(snd.wav.filename,snd.s,snd.e)
      end
    end
  end

  local snd_list=self:pattern_sound_list(self.cur_ptn_id)

  -- update sound with parameter locks for any sound thats doing stuff in the pattern
  for snd_id,_ in pairs(snd_list) do
      self.pattern[self.cur_ptn_id][self.cur_ptn_step].plock[snd_id]:play_if_locked()
  end

  -- update any current playing sounds with fx
  for snd_id,snd in pairs(snd_list) do
    self.sound_prevent[snd_id]=false
    local nofx=false
    local voice=voices:get_voice(self.id,snd_id)
    -- apply effects to any sounds in pattern have have a voice
    if voice~=nil then
      local fx_to_apply={}
      for i=1,16 do
        fx_to_apply[i]=false
      end
      if self.buttons[B_FX].pressed and (self.cur_snd_id==snd_id or params:get("fx global")==2) then
        -- if FX are pressed, only apply those
        for i=B_BUTTON_FIRST,B_BUTTON_LAST do
          local fx_id=i-B_BUTTON_FIRST+1
          if self.buttons[i].pressed then
            fx_to_apply[fx_id]=true
          end
        end
      else
        -- if no FX are pressed, apply FX from parameter locks
        for fx_id,dofx in pairs(self.pattern[self.cur_ptn_id][self.cur_ptn_step].flock[snd_id]) do
          if dofx then
            fx_to_apply[fx_id]=true
          end
        end
      end

      -- apply fx to the voice

      -- initiate lock voice
      local lock_voice=false

      -- turn on/off all effects
      for fx_id,fx_apply in pairs(fx_to_apply) do
        -- only update if its new
        if fx_apply==self.sound_fx_current[snd_id][fx_id] then
          goto continue
        end

        -- update current
        self.sound_fx_current[snd_id][fx_id]=fx_apply

        -- make sure to keep voice locked if doing a looping fx
        if FX_LOOPING[fx_id] and fx_apply then
          lock_voice=true
        end

        -- apply the effect
        if fx_id==FX_NONE then
          nofx=true
        elseif fx_id==FX_RETRIGGER then
          if fx_apply then
            self:debug("RETRIGGER")
            self.cur_ptn_step=math.random(1,16)
          end
        elseif fx_id==FX_68 then
          if fx_apply then
            self:debug("6/8 TIME")
            timekeeper.pattern[self.id]:set_swing(66)
          else
            self:debug("4/4 TIME")
            timekeeper.pattern[self.id]:set_swing(self.swing)
          end
        else
          ngen:fx(snd,fx_id,fx_apply)
        end
        ::continue::
      end

      -- finished with effects
      -- lock voice so it doesn't get stolen while effect is going
      -- (or unlock it if the effect has disappeared)
      if not nofx then
        voices:lock(voice,lock_voice)
      end
    end
  end
  self.skip_sound_once=0
end

function Operator:pattern_reset()
  self.cur_ptn_step=0
  self.cur_ptn_sync_step=0 -- resets the sync
  self.pattern_chain_index=1
  self.cur_ptn_id=self.pattern_chain[1]

  -- check other operators, if they are playing, then reset
  -- to their current settings
  local others_playing=false
  for i,op in ipairs(ops) do
    if op.mode_play and i~=self.id then
      others_playing=true
      self.cur_ptn_step=op.cur_ptn_step
      self.cur_ptn_sync_step=op.cur_ptn_sync_step
    end
  end
  if not others_playing then 
    self:debug("hard restart")
    timekeeper:hard_restart()
  end
end

function Operator:pattern_sound_list(ptn_id)
  local snd_list={}
  for ptn_step,_ in ipairs(self.pattern[ptn_id]) do
    for snd_id,snd in pairs(self.pattern[ptn_id][ptn_step].snd) do
      snd_list[snd_id]=snd
    end
  end
  return snd_list
end

function Operator:pattern_has_sound(ptn_id)
  for ptn_step=1,16 do
    for snd_id,_ in pairs(self.pattern[ptn_id][ptn_step].snd) do
      do return true end
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
    self.pattern[ptn_id][ptn_step]={snd={},plock={},flock={}}
    for snd_id=1,16 do
      self.pattern[ptn_id][ptn_step].plock[snd_id]=lock:new({snd_id=snd_id,op_id=self.id})
      self.pattern[ptn_id][ptn_step].flock[snd_id]={}
    end
  end
end

function Operator:pattern_copy(from_ptn_id,to_ptn_id)
  self:debug("copying pattern "..from_ptn_id.." to "..to_ptn_id)
  self:pattern_initialize(to_ptn_id)
  -- self.pattern[ptn_id][ptn_step].snd[snd_id]=<sound>
  -- self.pattern[ptn_id][ptn_step].plock[snd_id]=<param> -- used for parameter locking
  -- self.pattern[ptn_id][ptn_step].flock[snd_id][fx_id]=true -- used for fx locking
  for ptn_step=1,16 do
    for snd_id,snd in pairs(self.pattern[from_ptn_id][ptn_step].snd) do
      self.pattern[to_ptn_id][ptn_step].snd[snd_id]=sound:new(snd:dump())
    end
    for snd_id,plock in pairs(self.pattern[from_ptn_id][ptn_step].plock) do
      self.pattern[to_ptn_id][ptn_step].plock[snd_id]=lock:new({snd_id=snd_id,op_id=self.id})
      self.pattern[to_ptn_id][ptn_step].plock[snd_id]:unmarshal(plock:marshal())
    end
    for snd_id,flock in pairs(self.pattern[from_ptn_id][ptn_step].flock) do
      self.pattern[to_ptn_id][ptn_step].flock[snd_id]=json.decode(json.encode(flock))
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
  self:pattern_remove_plocks(ptn_id,ptn_step,snd_id)
end


-- pattern_remove_plocks removes plocks from
-- ptn_step until next step with a slice from snd_id
function Operator:pattern_remove_plocks(ptn_id,ptn_step,snd_id)
  for i=1,16 do
    local step=((ptn_step+i-2)%16)+1
    -- always remove first one
    if i==1 then
      self.pattern[ptn_id][step].plock[snd_id]=lock:new({snd_id=snd_id,op_id=self.id})
    elseif self.pattern[ptn_id][step].snd[snd_id]~=nil then
      break
    else
      self.pattern[ptn_id][step].plock[snd_id]=lock:new({snd_id=snd_id,op_id=self.id})
    end
  end
end


--
-- button logic
--

function Operator:buttons_register()
  self.mode_play=false
  self.mode_write=false
  self.mode_switchpattern=false
  self.mode_adjust=ADJ_NONE
  self.buttons={}
  for i=1,23 do
    self.buttons[i]={pressed=false,time_press=0}
    self.buttons[i].press=function(on)
      -- register current operator
      sel_operator=self.id
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
      local startrow=PO33_LAYOUT[params:get("layout")][24][1]
      local startcol=PO33_LAYOUT[params:get("layout")][24][2]*(self.id-1)+1
      return PO33_LAYOUT[params:get("layout")][i][1]+startrow,PO33_LAYOUT[params:get("layout")][i][2]+startcol
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
      snapshot:backup()
      do return end
    end
    if not self.mode_play then
      self:debug("on_press: play activated")
      self:pattern_reset()
    else
      self:debug("on_press: play stopped")
      -- turn off all the sounds
      snd_list=self:pattern_sound_list(self.cur_ptn_id)
      for snd_id,_ in pairs(snd_list) do
        local voice=voices:get_voice(self.id,snd_id)
        if voice~=nil then
          engine.tt_amp(voice,0,1)
        end
      end
      engine.tt_amp(1,0,1)
      engine.tt_amp(2,0,1)
    end
    self.mode_play=not self.mode_play
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
  self.buttons[B_FX].off_press=function()
    -- fx removal done in the pattern playing
  end
  self.buttons[B_RECORD].on_press=function()
    if self.buttons[B_WRITE].pressed and self.buttons[B_SOUND].pressed then
      snapshot:restore()
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
  self.buttons[B_BPM].on_short_press=function()
    --update the bpm to next closest
    if params:get("clock_tempo")>=140 or params:get("clock_tempo")<80 then
      params:set("clock_tempo",80)
    elseif params:get("clock_tempo")>=120 then
      params:set("clock_tempo",140)
    elseif params:get("clock_tempo")>=80 then
      params:set("clock_tempo",120)
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
      if self.buttons[B_FX].pressed then
        -- handled in the pattern update
      end
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

    end
    --
    --
    -- button presses
    --
    --
    self.buttons[i].on_press=function()
      if self.buttons[B_PATTERN].pressed and self.buttons[B_WRITE].pressed then
        -- copy current pattern to the new button
        self:pattern_copy(self.cur_ptn_id,b)
      elseif self.buttons[B_PATTERN].pressed then
        -- chain pattern
        if self.mode_switchpattern then
          -- new chain
          self:debug("switching pattern to "..b)
          self.pattern_chain={b}
          self.pattern_chain_index=1
          if self.mode_play then
            self:debug("playing this pattern next")
            self.pattern_chain_index=1000
          else
            self:debug("updating pattern")
            self.cur_ptn_id=b
          end
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
        sel_adj=ADJ_TRIM
      elseif self.buttons[B_FX].pressed and self.mode_play then
        -- add to fx lock
        -- is handled in the pattern update
      elseif self.buttons[B_RECORD].pressed then
        if params:get("load sounds")==2 then
          -- open file
          sel_files=true
          fileselect.enter(_path.audio,function(fname)
            sel_files=false
            if fname~=nil and fname~="cancel" then
              self:debug("selected "..fname)
              self.cur_snd_id=b
              sel_adj=ADJ_TRIM
              self:sound_load(self.cur_snd_id,fname)
            end
          end)
        else
          -- record into this sample
          self.cur_snd_id=b
          sel_adj=ADJ_TRIM
          recorder:record_start()
        end
      elseif not self.mode_write then
        -- set this sample to default
        self.cur_smpl_id=b
        -- play this sample in sound, without effects
        self:sound_play_from_press()
        if self.mode_play and self.buttons[B_WRITE].pressed and self.cur_ptn_step>0 then
          -- put current sound onto closest step
          local closest_beat=self.cur_ptn_step+timekeeper:closer_beat()
          if closest_beat>16 then
            closest_beat=1
          end
          self.skip_sound_once=self.cur_snd_id
          self.pattern[self.cur_ptn_id][closest_beat].snd[self.cur_snd_id]=self:sound_clone(self.cur_snd_id,self.cur_smpl_id)
          self:pattern_remove_plocks(self.cur_ptn_id,closest_beat,self.cur_snd_id)
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
          return 15*global_blink
        elseif self.sound[b][1].loaded then
          -- has sound
          return 4
        end
      elseif self.buttons[B_RECORD].pressed then
        if self.sound[b][1].loaded then
          return 10
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
          return 15*global_blink
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
