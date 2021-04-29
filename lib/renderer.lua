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
  o.in_render_function=0
  o.file_loaded=""
  o.current_render={}
  o.rendered={} -- map from filename to renders
  o.wf_last=nil
  o:register_renderer()
  return o
end

function Renderer:register_renderer()
  if mode_debug then
    print("register_renderer")
  end
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

    for k,r in ipairs(self.rendered[self.current_render.filename].renders) do
      if r.s==self.current_render.s and r.e==self.current_render.e then
        print("loading into "..k)
        if self.rendered[self.current_render.filename].renders[k].rendered[ch]==false then
          self.rendered[self.current_render.filename].renders[k].rendered[ch]=true
          for ii,v in ipairs(s) do
            self.rendered[self.current_render.filename].renders[k].ch[ch][ii]=s[ii]/maxval
          end
        end
        break
      end
    end

    if self.in_render_function>0 then
      self.in_render_function=self.in_render_function-1
    end
    graphics:update()
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
  graphics:update()
end

-- expand the waveform to the set points
function Renderer:expand(filename,s,e)
  if filename=="" then
    do return end
  end
  if self.rendered[filename]~=nil then
    self.rendered[filename].window={0,1}
    self.rendered[filename].loop_points={s,e}
  end
  graphics:update()
end

-- zoom in/out of a rendered waveform
function Renderer:zoom(filename,i,zoom)
  if filename=="" then
    do return end
  end
  local window={self.rendered[filename].window[1],self.rendered[filename].window[2]}
  local p=self.rendered[filename].loop_points[i]
  local di=math.max(p-window[1],window[2]-p)
  if zoom>=0 and self.rendered[filename].zoom<16 then
    print("Renderer:zoom zooming in")
    self.rendered[filename].zoom=self.rendered[filename].zoom+1
    window={p-di/1.5,p+di/1.5}
  elseif self.rendered[filename].zoom>0 and zoom<0 then
    print("Renderer:zoom zooming out")
    self.rendered[filename].zoom=self.rendered[filename].zoom-1
    window={p-di*2,p+di*2}
    if self.rendered[filename].zoom==0 then
      window={0,1}
    end
  end
  if window[1]<0 then
    window[1]=0
  end
  if window[2]>1 then
    window[2]=1
  end
  self.rendered[filename].window={window[1],window[2]}
  graphics:update()
end

-- jog back/forth translates the loop points
-- window zooms to fix if you jog one side
function Renderer:jog(filename,i,d)
  if filename=="" then
    do return end
  end
  local p=self.rendered[filename].loop_points[i]
  local window={self.rendered[filename].window[1],self.rendered[filename].window[2]}
  -- convert d to [0,1] duration
  p=p+(window[2]-window[1])/128*d
  -- if point is out of window, stretch window
  if i==2 and p>window[2] then
    window[2]=p
    if window[2]>1 then
      window[2]=1
      p=1
    end
  end
  if i==1 and p<window[1] then
    window[1]=p
    if window[1]<0 then
      window[1]=0
      p=0
    end
  end
  self.rendered[filename].window={window[1],window[2]}
  self.rendered[filename].loop_points[i]=p
  graphics:update()
  return p
end

-- draw a waveform
function Renderer:draw(filename)
  if filename=="" then
    print("Renderer: no filename")
    do return end
  end
  if self.rendered[filename]==nil then
    print("Renderer: rendering for first time")
    self:render(filename,0,1)
    do return end
  end
  local window={self.rendered[filename].window[1],self.rendered[filename].window[2]}
  local loop_points={self.rendered[filename].loop_points[1],self.rendered[filename].loop_points[2]}
  local waveform_height=40
  local waveform_center=38
  local lp={}
  -- local pos=util.round(util.linlin(window[1],window[2],1,128,voices.pos))
  lp[1]=util.round(util.linlin(window[1],window[2],1,128,loop_points[1]))
  lp[2]=util.round(util.linlin(window[1],window[2],1,128,loop_points[2]))
  if loop_points[2]>window[2] then
    lp[2]=129
  end
  local wf=self:render(filename,window[1],window[2])
  if wf==nil then
    print("Renderer:draw no data")
    do return end
  end
  if wf[1]~=nil and wf[2]~=nil then
    self.wf_last={}
    for j=1,2 do
      self.wf_last[j]={}
      for i,s in ipairs(wf[j]) do
        self.wf_last[j][i]=s
        local height=util.clamp(0,waveform_height,util.round(math.abs(s)*waveform_height))
        screen.level(13)
        if i<lp[1] or i>lp[2] then
          screen.level(4)
        end
        -- if math.abs(pos-i)<2 then
        --   if j==1 then
        --     screen.level(5)
        --     screen.move(i,14)
        --     screen.line(i,59)
        --     screen.stroke()
        --   end
        --   screen.level(15)
        -- end
        screen.move(i,waveform_center)
        screen.line_rel(0,(j*2-3)*height/2)
        screen.stroke()
      end
    end
  else
    print("Renderer: no wf[1] or wf[2]")
  end
end

function Renderer:render(filename,s,e)
  if filename=="" then
    print("render: no file name")
    do return nil end
  end
  if self.in_render_function>0 then
    -- print("in render function")
    do return nil end
  end
  s=math.floor(s*1000)/1000
  e=math.floor(e*1000)/1000
  if self.rendered[filename]~=nil then
    for i,r in ipairs(self.rendered[filename].renders) do
      if self.rendered[filename].renders[i].s==s and self.rendered[filename].renders[i].e==e then
        -- print("rendered "..s.." "..e.." "..i)
        do return self.rendered[filename].renders[i].ch end
      end
    end
  else
    print("render: registering new file")
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
    self.rendered[filename].window={s,e}
    self.rendered[filename].loop_points={s,e}
    self.rendered[filename].zoom=0
  end
  self.in_render_function=2

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
  print("registering new render at ("..s..","..e..")")
  table.insert(self.rendered[filename].renders,{s=s,e=e,ch={{},{}},rendered={false,false}})
  return self.wf_last
end


return Renderer
