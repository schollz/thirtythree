--
-- Sample class
-- contains information for sample
--

Sample = {}

function Sample:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.__tostring = function(t) return t:to_string() end
  o.loaded = false
  o.index_sc = o.index_sc or 1
  return o
end

function Sample:to_string()
  return self:get_filename()
end

function Sample:get_filename()
  return self.filename
end

function Sample:load(filename)
  -- loads sample
  self.name = filename:match("^.+/(.+).wav$")
  self.ch, self.samples, self.sample_rate = audio.file_info(filename)
  self.duration = samples / 48000.0
  self.filename = filename
  self.rate_compensation = sample_rate / 48000.0 -- compensate for files that aren't 48Khz
  -- TODO: load it into supercollider
end
