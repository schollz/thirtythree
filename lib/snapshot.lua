local Snapshot={}

function Snapshot:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  return o
end


function Snapshot:backup()
  graphics:alert("saving")
  local t1=clock.get_beat_sec()*clock.get_beats()
  -- TODO: automatically generate the save name
  local filename=_path.data.."thirtythree/save.json"
  print("saving to ")
  local data={}

  -- operator data
  data.ops={}
  for i,op in ipairs(ops) do
    data.ops[i]=op:marshal()
  end
  local f=io.open(filename,"w+")

  -- wav files
  data.wav=wav:marshal()

  io.output(f)
  io.write(json.encode(data))
  io.close(f)
  local t2 = math.floor((clock.get_beat_sec()*clock.get_beats()-t1)*100)/100
  graphics:alert("saved in "..t2.." s")
end

function Snapshot:restore()
  graphics:alert("loading")
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
    ops[i]=operator:new()
    ops[i]:init()
    ops[i]:unmarshal(data.ops[i])
  end

  local t2 = math.floor((clock.get_beat_sec()*clock.get_beats()-t1)*100)/100
  graphics:alert("loaded in "..t2.." s")
end

return Snapshot
