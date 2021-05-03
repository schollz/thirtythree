local Recorder={}


function Recorder:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self

  -- make the directory for audio
  -- if doesn't exist
  os.execute("mkdir -p ".._path.audio.."thirtythree")
  o.file=nil
  o.is_recording=false
  o.time_left=0
  o.level=0
  return o
end

function Recorder:draw()
  if not self.is_recording then
    do return end
  end
  print(self.level)
  graphics:show_level(self.level,self.time_left)
end

function Recorder:recorded_file()
  local fname=self.file
  self.file=nil
  return fname
end

function Recorder:record_start()
  if self.is_recording then
    do return end
  end
  self.is_recording=true
  _norns.vu=function(in1,in2,out,out2)
    self.level=util.linlin(0,127,0,1,in1+in2)
    graphics:update()
  end
  -- determine the new file name
  local current_max,num_files=self:files()
  fname="sample"..current_max..".wav"
  self.file=_path.audio.."thirtythree/"..fname
  audio.tape_record_open(self.file)
  audio.tape_record_start()

  -- automatically stop after 60 seconds
  clock.run(function()
    self.time_left=61
    for i=1,60 do
      self.time_left=self.time_left-1
      clock.sleep(1)
      if not self.is_recording then
        break
      end
    end
    self:record_stop()
  end)
end

function Recorder:record_stop()
  if not self.is_recording then
    do return end
  end
  _norns.vu=norns.none
  self.is_recording=false
  audio.tape_record_stop()
end

function Recorder:files()
  local current_max=0
  local num_files=0
  for _,fname in ipairs(os.list_files(_path.audio.."thirtythree")) do
    num_files=num_files+1
    local loop_num=tonumber(string.match(fname,'sample(%d*)'))
    if loop_num~=nil and loop_num>current_max then
      current_max=loop_num
    end
  end
  current_max=current_max+1
  return current_max,num_files
end


return Recorder
