local Snapshot={}

function Snapshot:debug(s)
  if mode_debug then
    print("snapshot: "..s)
  end
end

function Snapshot:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  o:init()
  return o
end

function Snapshot:init()
  os.execute("mkdir -p ".._path.data.."thirtythree/backups/")

  params.action_write=function(filename,name)
    if name==nil then
      do return end
    end
    self:debug("writing "..filename.." also known as "..name)
    self:backup(_path.data.."thirtythree/backups/"..name..".json")
  end

  params.action_read=function(filename)
    file=io.open(filename,"r")
    io.input(file)
    local first_line=io.read()
    io.close(file)
    local name=string.sub(first_line,4)
    if string.sub(first_line,1,3)=="-- " then
      self:debug("loading "..filename)
      self:debug(first_line)
      self:debug("also known as '"..name.."'")
      self:restore(_path.data.."thirtythree/backups/"..name..".json")
      cloud:reset()
    end
  end
end


-- pset_next returns the name of the next pset
function Snapshot:pset_next()
  for i=1,99 do
    fname=_path.data..string.format("thirtythree/thirtythree-%02d.pset",i)
    if not util.file_exists(fname) then
      return fname
    end
  end
end

-- pset_from_name returns the name of the pset associated with its name
-- e.g. "AA" might return thirtythree-03.pset if that one has that name
function Snapshot:pset_from_name(name)
  -- look in all the files in the data folder
  fnames=os.list_files(_path.data.."thirtythree/",false)
  for _,fname in ipairs(fnames) do
    local found_name=self:pset_name(fname)
    if found_name==name then
      do return fname end
    end
  end
end

function Snapshot:pset_name(pset_filename)
  if not string.find(pset_filename,".pset") then
    do return end
  end
  file=io.open(pset_filename,"r")
  io.input(file)
  local first_line=io.read()
  io.close(file)
  if not string.find(first_line,"-- ") then
    do return end
  end
  if string.sub(first_line,1,3)=="-- " then
    local name=string.sub(first_line,4)
    return name
  end
end

function Snapshot:list_sounds(filename)
  if not util.file_exists(filename) then
    print("no save file to load")
    do return end
  end
  graphics:alert("loading")

  local f=io.open(filename,"rb")
  local content=f:read("*all")
  f:close()

  local data=json.decode(content)
  if data==nil then
    print("error loading data")
    do return end
  end
  if data.wav==nil then
    print("error loading wav")
    do return end
  end

  -- unmarshal wav data
  local wav_temp=wav_:new()
  wav_temp:unmarshal(data.wav)
  filenames=wav_temp:filenames()
  self:debug("found files in "..filename)
  for _,fname in ipairs(filenames) do
    self:debug(fname)
  end
  return filenames
end

function Snapshot:backup(filename)
  graphics:alert("saving")
  local t1=clock.get_beat_sec()*clock.get_beats()
  print("saving to "..filename)
  local data={}

  -- operator data
  data.ops={}
  for i,op in ipairs(ops) do
    if i<=params:get("operators") then
      data.ops[i]=op:marshal()
    end
  end
  local f=io.open(filename,"w+")

  -- wav files
  data.wav=wav:marshal()

  io.output(f)
  io.write(json.encode(data))
  io.close(f)
  local t2=math.floor((clock.get_beat_sec()*clock.get_beats()-t1)*100)/100
  graphics:alert("saved in "..t2.." s")
end

function Snapshot:restore(filename)
  local t1=clock.get_beat_sec()*clock.get_beats()
  if not util.file_exists(filename) then
    print("no save file to load")
    do return end
  end
  graphics:alert("loading")

  local f=io.open(filename,"rb")
  local content=f:read("*all")
  f:close()

  local data=json.decode(content)
  if data==nil then
    print("error loading data")
    do return end
  end
  if data.ops==nil then
    print("error loading ops")
    do return end
  end
  if data.wav==nil then
    print("error loading wav")
    do return end
  end

  -- unmarshal wav data
  wav=wav_:new()
  wav:unmarshal(data.wav)

  -- unmarshal each operator
  for i,_ in ipairs(data.ops) do
    if i<=params:get("operators") then
      ops[i]=operator:new()
      ops[i]:init()
      ops[i]:unmarshal(data.ops[i])
    end
  end

  local t2=math.floor((clock.get_beat_sec()*clock.get_beats()-t1)*100)/100
  graphics:alert("loaded in "..t2.." s")
end

return Snapshot
