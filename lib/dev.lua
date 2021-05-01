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

  -- sel_filename="/home/we/dust/audio/jams/jam3_gmin/chords_gmin.wav"
  -- ops[1]:sound_load(9,sel_filename)
  -- sel_filename="/home/we/dust/audio/jams/jam3_gmin/vocals_gmin.wav"
  -- ops[1]:sound_load(10,sel_filename)
  -- sel_filename="/home/we/dust/audio/breakbeat/bpm120/beats8_bpm120_adt_120_drum_break_vinylised.wav"
  -- ops[1]:sound_load(11,sel_filename)

  for i=1,4 do
    sel_filename="/home/we/dust/code/thirtythree/defaults/yelidek_kit.wav"
    ops[i]:sound_load(16,sel_filename)
    sel_filename="/home/we/dust/code/thirtythree/defaults/steinway_c.wav"
    ops[i]:sound_load(1,sel_filename)
  end

  ops[1].cur_snd_id=1
  sel_adj=ADJ_TONE
  -- -- snapshot:backup()
  -- snapshot:restore()
  return o
end

return Dev
