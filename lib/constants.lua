-- button constants
B_FIRST=1
B_LAST=23
B_SOUND=1
B_PATTERN=2
B_BPM=3
B_BUTTON_FIRST=4
B_BUTTON_LAST=19
B_RECORD=20
B_FX=21
B_PLAY=22
B_WRITE=23

-- adjust constants
ADJ_FIRST=1
ADJ_LAST=4
ADJ_NONE=1
ADJ_TRIM=2
ADJ_TONE=3
ADJ_FILT=4

-- parms
PARM_NONE=1
PARM_VOLUME=2
PARM_PITCH=3
PARM_FILTER=4
PARM_RESONANCE=5

INVERTED_KEYBOARD={13,14,15,16,9,10,11,12,5,6,7,8,1,2,3,4}
INVERTED_KEYBOARD_MAP={}
for i=1,16 do 
  INVERTED_KEYBOARD_MAP[INVERTED_KEYBOARD[i]]=i
end

FX_LOOP16=1
FX_LOOP12=2
FX_LOOPSHORT=3
FX_LOOPSHORTER=4
FX_AUTOPAN=5
FX_BITCRUSH=6
FX_OCTAVEUP=7
FX_OCTAVEDOWN=8
FX_STUTTER4=9
FX_STUTTER3=10
FX_SCRATCH=11
FX_SCRATCHFAST=12
FX_68=13
FX_RETRIGGER=14
FX_REVERSE=15
FX_NONE=16

-- looping fx are special
FX_LOOPING={}
for i=1,16 do
  FX_LOOPING[i]=false
end
FX_LOOPING[FX_LOOP16]=true
FX_LOOPING[FX_LOOP12]=true
FX_LOOPING[FX_LOOPSHORT]=true
FX_LOOPING[FX_LOOPSHORTER]=true
FX_LOOPING[FX_SCRATCH]=true
FX_LOOPING[FX_SCRATCHFAST]=true


PO33_LAYOUT={}
-- classic ~5x5
PO33_LAYOUT[1]={
  {0,0},
  {0,1},
  {0,2},
  {1,0},
  {1,1},
  {1,2},
  {1,3},
  {2,0},
  {2,1},
  {2,2},
  {2,3},
  {3,0},
  {3,1},
  {3,2},
  {3,3},
  {4,0},
  {4,1},
  {4,2},
  {4,3},
  {1,4},
  {2,4},
  {3,4},
  {4,4},
  {4,5},-- start row, spacing
}
-- alt ~6x4
PO33_LAYOUT[2]={
  {0,0},
  {0,1},
  {0,2},
  {1,0},
  {1,1},
  {1,2},
  {1,3},
  {2,0},
  {2,1},
  {2,2},
  {2,3},
  {3,0},
  {3,1},
  {3,2},
  {3,3},
  {4,0},
  {4,1},
  {4,2},
  {4,3},
  {5,3},
  {5,2},
  {5,1},
  {5,0},
  {3,4},-- start row, spacing
}
