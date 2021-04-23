--
-- Operator class
-- contains information for each operator
--

Operator={}

B_SOUND=1
B_PATTERN=2
B_BPM=3
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

  -- defaults
  o.sound={}
  o.sound_current=1
  for i=1,16 do
    o.sound[i]=sound_:new({
      id=(o.id-1)*16+i,
      melodic=i<9,
    })
  end

  -- patterns
  o.pattern={}
  o.pattern_step=1
  o.pattern_current=1
  o.pattern_chain={}
  for i=1,16 do
    o.pattern[i]={}
    -- pattern is a map of sounds that maps to samples
    -- pattern[ptn_id][snd_id][smpl_id]=true
  end

  return o
end

function Operator:to_string()
  return self.filename
end

function Operator:debug(s)
  if mode_debug then 
    print("operator"..self.id..": "..s)
  end
end

function Operator:sound_load(i,filename)
  self.sound[i]:load(filename)
end

function Operator:pattern_has_sample(ptn_id,snd_id,smpl_id)
  if self.pattern[ptn_id][snd_id]~=nil then
    return self.pattern[ptn_id][snd_id][smpl_id] ~= nil
  end
  return false
end

function Operator:pattern_toggle_sample(ptn_id,snd_id,smpl_id)
  if self:pattern_has_sample(ptn_id,snd_id,smpl_id) then
    self.pattern_current[ptn_id][snd_id][smpl_id]==nil
    if #self.pattern_current[ptn_id][snd_id]==0 then
      self.pattern_current[ptn_id][snd_id]=nil
    end
  else
    if self.pattern_current[ptn_id][snd_id]== nil then
      self.pattern_current[ptn_id][snd_id]={}
    end
    self.pattern_current[ptn_id][snd_id][smpl_id]=true
  end
end

function Operator:buttons_register()
  self.mode_play=false
  self.mode_write=false
  self.mode_switchpattern=false
  self.buttons={}
  for i=1,23 do
    self.buttons[i]={pressed=false,time_press=0}
    self.buttons[i].press=function(on)
      self.buttons[i].pressed=on
      if on then 
        self:debug("button "..i.." pressed on")
        self.buttons[i].time_press=os.clock()
        if self.buttons[i].on_press~=nil then
          self.buttons[i].on_press()
        end
      else
        self:debug("button "..i.." pressed off")
        local cur_time = os.clock()
        if cur_time-self.buttons[i].time_press < 0.04 and self.buttons[i].on_short_press~=nil then
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
      self:debug("write mode")
    else
      self:debug("performance mode")
    end
  end
  self.buttons[B_PLAY].on_press=function()
    self.mode_play=not self.mode_play
    if self.mode_play then 
      self:debug("play activated")
    else
      self:debug("play stopped")
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

  -- steps "1" to "16"
  for i=B_BPM+1,B_WRITE-1 do
    b=i-B_BPM -- the button number [1,16]
    self.buttons[i].off_press=function()
      if self.mode_write then
        -- TODO: toggle a step here for the current sound
        self:pattern_toggle_sample(self.pattern_current,self.sound_current,b)
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
        -- TODO: change sound
      elseif self.buttons[B_FX].pressed then
        if self.mode_play then
          -- TODO: activate effect 
          if self.mode_write then 
            -- TODO: save effect
          end
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
        if self:pattern_has_sample(self.pattern_current,self.sound_current,b) then 
          return 14
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
