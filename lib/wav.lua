--
-- wav keeps track of filename info
-- and keeps track of the buffer id in supercollider
--

local Wav={}

function Wav:debug(s)
  if mode_debug then
    print("wav: "..s)
  end
end

function Wav:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  o.sc_index=1
  o.files={}
  return o
end

function Wav:marshal()
  local data = {}
  for k,v in pairs(self) do
    data[k]=json.encode(v)
  end
  return json.encode(data)
end

function Wav:unmarshal(content)
  local data=json.decode(content)
  if data==nil then
    print("no data found in save file")
    do return end
  end
  for k,v in pairs(data) do
    self[k]=json.decode(v)
  end

  -- reload the files into supercollider
  for filename,_ in pairs(self.files) do
    self:load(filename)
  end
end

function Wav:filenames()
  local fnames={}
  for fname,_ in pairs(self.files) do 
    table.insert(fnames,fname)
  end
  return fnames
end

function Wav:load(filename)
  if self.files[filename] ~= nil then
    engine.tt_load(self.files[filename].sc_index,filename)
  end
end


-- get returns the best voice for id
function Wav:get(filename)
  if self.files[filename] == nil then
    -- loads sample
    self.files[filename]={}
    self.files[filename].name=filename:match("^.+/(.+).wav$")
    self.files[filename].ch, self.files[filename].samples, self.files[filename].sample_rate=audio.file_info(filename)
    self.files[filename].duration=self.files[filename].samples/48000.0
    self.files[filename].filename=filename
    self.files[filename].sc_index=self.sc_index

    -- onset detection
    local onset_string = ""
    if util.file_exists(filename..".onsets") then 
      self:debug("reading file: "..filename..".onsets")
      onset_string = os.read_file(filename..".onsets")
    else
      cmd="aubioonset -i "..filename.." -B 4096 -H 2048 -t 0.3 -M 0.3"
      self:debug("using aubioonset: "..cmd)
      onset_string = os.capture(cmd)
    end
    onsets = {0}
    for substring in onset_string:gmatch("%S+") do
      local onset=tonumber(substring)/self.files[filename].duration
      if onset ~= 0 then
        if onset==nil then
          print("error with onset")
        end
        -- self:debug(tonumber(substring),self.files[filename].duration,onset)
        table.insert(onsets, onset)
      end
    end
    if #onsets==1 then
      onsets={}
      for i=1,16 do
        table.insert(onsets,(i-1)/16.0)
      end
    end
    table.insert(onsets,1.0)
    self.files[filename].onsets={}
    for i,_ in ipairs(onsets) do
      if i>1 then
        self.files[filename].onsets[i-1]={onsets[i-1],onsets[i]}
        -- print(i-1,onsets[i-1],onsets[i])
      end
    end

    self:load(filename)

    if mode_debug then
      print("loaded "..filename.." into with sc index "..self.sc_index)
    end

    -- increase the index
    self.sc_index = self.sc_index + 1
  end

  -- return the wav
  return {
    name=self.files[filename].name,
    filename=filename,
    ch=self.files[filename].ch,
    samples=self.files[filename].samples,
    sample_rate=self.files[filename].sample_rate,
    duration=self.files[filename].duration,
    sc_index=self.files[filename].sc_index,
    onsets=self.files[filename].onsets,
  }
end

return Wav
