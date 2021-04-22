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
  o.file_loaded=""
  o.rendered={} -- map from filename to renders
  return o
end

function Renderer:render(filename,s,e)
  if self.rendered[filename]~=nil then
    for i,r in ipairs(self.rendered[filename].renders) do
      if r.s==s and r.e==e then
        return r.channel_l,r.channel_r
      end
    end
  else
    self.rendered[filename]={
      filename=filename,
      renders={},
      sample_rate=0,
      duration=0,
      samples=0,
    }
  end


  if self.rendered[filename].samples==0 then
    self.rendered[filename].ch,self.rendered[filename].samples,self.rendered[filename].sample_rate=audio.file_info(filename)
    self.rendered[filename].duration=self.rendered[filename].samples/48000.0
  end

  if self.file_loaded~=filename then
    -- load file
    softcut.load() -- TODO fix this
    self.file_loaded=filename
  end

  sp=util.linlin(0,1,0,self.rendered[filename].duration,s)
  ep=util.linlin(0,1,0,self.rendered[filename].duration,e)
  -- TODO ask to render it

  return o.zeros,o.zeros
end


return Renderer
