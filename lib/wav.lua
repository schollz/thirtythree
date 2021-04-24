--
-- wav keeps track of filename info
-- and keeps track of the buffer id in supercollider
--

local Wav={}

function Wav:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  o.sc_index=1
  o.files={}
  return o
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

    -- load it into supercollider
    engine.tt_load(self.index_sc,filename)

    if mode_debug then
      print("loaded "..filename.." into with sc index "..self.sc_index)
    end

    -- increase the index
    self.sc_index = self.sc_index + 1
  end

  -- return the wav
  return {
    filename=filename,
    ch=self.files[filename].ch,
    samples=self.files[filename].samples,
    sample_rate=self.files[filename].sample_rate,
    duration=self.files[filename].duration,
    sc_index=self.files[filename].sc_index,
  }
end

return Wav
