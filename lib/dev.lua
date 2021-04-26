local Dev={}



function Dev:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self


  -- sel_filename="/home/we/dust/audio/jams/jam1_amin_70bpm/bass_bpm70_amin.wav"
  -- ops[1]:sound_load(9,sel_filename)
  -- sel_filename="/home/we/dust/audio/jams/jam1_amin_70bpm/drums_bpm70.wav"
  -- ops[1]:sound_load(10,sel_filename)
  -- sel_filename="/home/we/dust/audio/jams/jam1_amin_70bpm/rhodes_bpm70_amin.wav"
  -- ops[1]:sound_load(11,sel_filename)

  sel_filename="/home/we/dust/audio/jams/jam1_amin_70bpm/voice_bpm70_amin.wav"
  ops[1]:sound_load(12,sel_filename)
  ops[1].cur_snd_id=12
  sel_adj=4
  -- snapshot:backup()
  return o
end

return Dev
