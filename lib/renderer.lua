local Renderer={}

function Renderer:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  self.__tostring=function(t) return t:to_string() end

  o.zeros={}
  for i=1,128 do
    o.zeros[i]=0
  end
  o.in_render_function=false
  o.file_loaded=""
  o.current_render={}
  o.rendered={} -- map from filename to renders
  o:register_renderer()
  return o
end

function Renderer:register_renderer()
  softcut.event_render(function(ch,start,i,s)
    if self.current_render.filename==nil or self.rendered[self.current_render.filename]==nil then
      print("asked for render with nothing ready?")
      do return end
    end
    local maxval=0
    for _,v in ipairs(s) do
      if v>maxval then
        maxval=math.abs(v)
      end
    end
    local j=0
    for k,r in pairs(self.rendered[self.current_render.filename].renders) do
      if r.s==self.current_render.s and r.e==self.current_render.e then
        j=k
        break
      end
    end

    for k,v in ipairs(s) do
      self.rendered[self.current_render.filename].renders[j].ch[ch]=s[k]/maxval
    end
  end)
end

-- fit the waveform to the set points
function Renderer:fit(filename,s,e)
  if filename=="" then
    do return end
  end
  if self.rendered[filename]~=nil then
    self.rendered[filename].window={s,e}
    self.rendered[filename].loop_points={s,e}
  end
  self:render(filename,s,e)
end

-- zoom in/out of a rendered waveform
function Renderer:zoom(filename,zoom,i)
  if filename=="" then
    do return end
  end
  local window=self.rendered[filename].window
  local loop_points=self.rendered[filename].loop_points
  local di=zoom*math.abs(loop_points[i]-window[1])
  local di2=zoom*math.abs(loop_points[i]-window[2])
  if di2>di then
    di=di2
  end
  window[1]=loop_points[i]-di
  if window[1]<0 then
    window[1]=0
  end
  window[2]=loop_points[i]+di
  self.rendered[filename].window=window
  self:render(filename,window[1],window[2])
end

-- jog back/forth translates the loop points
-- window zooms to fix if you jog one side
function Renderer:jog(filename,i,d)
  if filename=="" then
    do return end
  end
  local p=self.rendered[filename].loop_points[i]
  local window=self.rendered[filename].window
  -- if point is out of window, stretch window
  if p>window[2] then
    window[2]=math.min(p,1)
  end
  if p<window[1] then
    window[1]=math.max(p,0)
  end
  -- convert to pixels
  p=util.linlin(window[1],window[2],1,128,p)
  -- increase by amount d
  p=p+d
  -- convert back to the window
  p=util.linlin(1,128,window[1],window[2],p)
  self.rendered[filename].window=window
  self.rendered[filename].loop_points[i]=p
  self:render(filename,window[1],window[2])
end

-- draw a waveform
function Renderer:draw(filename)
  if filename=="" then
    do return end
  end
  if self.rendered[filename]==nil then
    self:render(filename,0,1)
    do return end
  end
  local window=self.rendered[filename].window
  local loop_points=self.rendered[filename].loop_points
  local waveform_height=40
  local waveform_center=38
  local lp={}
  lp[1]=util.round(util.linlin(window[1],window[2],1,128,loop_points[1]))
  lp[2]=util.round(util.linlin(window[1],window[2],1,128,loop_points[2]))
  if loop_points[2]>window[2] then
    lp[2]=129
  end
  local wf=self:render(filename,window[1],window[2])
  if wf[1]~=nil and wf[2]~=nil then
    for j=1,2 do
      for i,s in ipairs(wf[j]) do
        local height=util.clamp(0,waveform_height,util.round(math.abs(s)*waveform_height))
        screen.level(13)
        if i<lp[1] or i>lp[2] then
          screen.level(4)
        end
        if math.abs(pos-i)<2 then
          if j==1 then
            screen.level(5)
            screen.move(i,14)
            screen.line(i,59)
            screen.stroke()
          end
          screen.level(15)
        end
        screen.move(i,waveform_center)
        screen.line_rel(0,(j*2-3)*height/2)
        screen.stroke()
      end
    end
  end
end

function Renderer:render(filename,s,e)
  if filename=="" then
    do return end
  end
  if self.in_render_function then
    do return end
  end
  self.in_render_function=true
  if self.rendered[filename]~=nil then
    for i,r in ipairs(self.rendered[filename].renders) do
      if r.s==s and r.e==e then
        self.in_render_function=false
        return r.ch
      end
    end
  else
    -- register a new file
    self.rendered[filename]={
      filename=filename,
      renders={},
      sample_rate=0,
      duration=0,
      samples=0,
    }
    self.rendered[filename].ch,self.rendered[filename].samples,self.rendered[filename].sample_rate=audio.file_info(filename)
    self.rendered[filename].duration=self.rendered[filename].samples/48000.0
    self.rendered[filename].window={0,self.rendered[filename].duration}
    self.rendered[filename].loop_points={0,self.rendered[filename].duration}
  end

  if self.file_loaded~=filename then
    -- load file
    softcut.buffer_read_stereo(filename,0,0,-1)
    self.file_loaded=filename
  end

  -- do a new render
  sp=util.linlin(0,1,0,self.rendered[filename].duration,s)
  ep=util.linlin(0,1,0,self.rendered[filename].duration,e)
  self.current_render={
    filename=filename,
    s=s,
    e=e,
  }
  for i=1,2 do
    softcut.render_buffer(i,sp,ep-sp,128)
  end

  -- register the new render (full of zeros)
  table.insert(self.rendered[filename].renders,{s=s,e=e,ch={self.zeros,self.zeros}})
  self.in_render_function=false
  return {self.zeros,self.zeros}
end


return Renderer
