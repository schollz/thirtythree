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
  {5,0},
  {5,1},
  {5,2},
  {5,3},
  {5,4},-- start row, spacing
}
