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
  -- sel_filename="/home/we/dust/audio/jams/jam1_amin_70bpm/voice_bpm70_amin.wav"
  -- ops[1]:sound_load(12,sel_filename)

  -- sel_filename="/home/we/dust/audio/jams/jam2_amin/bass_amin.wav"
  -- ops[1]:sound_load(13,sel_filename)
  -- sel_filename="/home/we/dust/audio/jams/jam2_amin/guitar_amin.wav"
  -- ops[1]:sound_load(14,sel_filename)
  -- sel_filename="/home/we/dust/audio/jams/jam2_amin/strings_amin.wav"
  -- ops[1]:sound_load(15,sel_filename)
  -- sel_filename="/home/we/dust/audio/jams/jam2_amin/vocals_amin.wav"
  -- ops[1]:sound_load(16,sel_filename)


  ops[1].cur_snd_id=16
  sel_adj=ADJ_TRIM
  -- snapshot:backup()
  snapshot:restore()
  return o
end

return Dev
