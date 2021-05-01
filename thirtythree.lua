-- thirtythree
--
--


mode_debug=true

--json
print(_VERSION)
print(package.cpath)
if not string.find(package.cpath,"/home/we/dust/code/thirtythree/lib/") then
  package.cpath=package.cpath..";/home/we/dust/code/thirtythree/lib/?.so"
end
json=require("cjson")

-- globals
include("lib/parameters")
include("lib/constants")
include("lib/utils")
-- global state
sel_operator=1
sel_filename=""
sel_looppoint=1
sel_adj=ADJ_NONE
sel_parm=PARM_NONE
sel_files=false
global_blink=1
ops={} -- operators

-- engine
engine.name="Thirtythree"

-- individual libraries
lattice=include("thirtythree/lib/lattice")
fileselect=require "fileselect"
lock=include("lib/lock")
graphics_=include("lib/graphics")
graphics=graphics_:new()
ngen_=include("lib/ngen")
ngen=ngen_:new()
voices_=include("lib/voices")
voices=voices_:new()
renderer_=include("lib/renderer")
renderer=renderer_:new()
wav_=include("lib/wav")
wav=wav_:new()
timekeeper_=include("lib/timekeeper")
timekeeper=timekeeper_:new()
recorder_=include("lib/recorder")
recorder=recorder_:new()
gridd_=include("lib/gridd")
gridd=gridd_:new()
sound=include("lib/sound")
operator=include("lib/operator")
snapshot_=include("lib/snapshot")
snapshot=snapshot_:new()

function init()
  -- start updater
  runner=metro.init()
  runner.time=1/15
  runner.count=-1
  runner.event=updater
  runner:start()
  startup_done=false
  startup_initiated=false
end

function startup()
  startup_initiated=true
  graphics:alert("loading")
  check_and_install_aubioonset()

  -- TODO: initialize operators
  ops[1]=operator:new({id=1})
  ops[1]:init()
  ops[2]=operator:new({id=2})
  ops[2]:init()

  -- after initializing operators, intialize time keeper
  timekeeper:init()

  -- register parameters
  register_parameters()

  dev_=include("lib/dev")
  dev=dev_:new()
  startup_done=true
end

function updater(c)
  if not startup_initiated then
    print("starting up")
    clock.run(startup)
  end
end

function enc(k,d)
  for i,op in ipairs(ops) do
    if op.buttons[B_BPM].pressed and k==2 then
      -- change tempo
      params:delta("clock_tempo",d)
      graphics:update()
      do return end
    elseif op.buttons[B_BPM].pressed and k==3 then
      timekeeper:adjust_swing(sel_operator,d)
      graphics:update()
      do return end
    end
  end
  sel_parm=PARM_NONE
  if sel_adj==ADJ_TRIM then
    if k==1 then
      ops[sel_operator]:trim_zoom(sel_looppoint,d)
    else
      sel_looppoint=k-1
      ops[sel_operator]:trim_jog(sel_looppoint,d)
    end
  elseif sel_adj==ADJ_FILT then
    sel_parm=PARM_FILTER
    if k==2 then
      ops[sel_operator]:filter_set(d)
    elseif k==3 then
      ops[sel_operator]:resonance_set(-d)
    end
  elseif sel_adj==ADJ_TONE then
    if k==2 then
      ops[sel_operator]:volume_set(d)
      sel_parm=PARM_VOLUME
    elseif k==3 then
      ops[sel_operator]:pitch_set(d)
      sel_parm=PARM_PITCH
    end
  end
  graphics:update()
end

function key(k,z)
  sel_parm=PARM_NONE
  if k>1 and z==1 then
    local v=k*2-5
    sel_adj=sel_adj+v
    if sel_adj<ADJ_FIRST then
      sel_adj=ADJ_LAST
    elseif sel_adj>ADJ_LAST then
      sel_adj=ADJ_FIRST
    end
    if sel_adj==ADJ_TRIM then
      ops[sel_operator]:trim_select()
    end
    print("adj_mode: "..sel_adj)
  end
  graphics:update()
end

local ani1=1

function redraw()
  if sel_files then
    -- don't interupt file selection
    do return end
  end
  screen.clear()

  if sel_adj==ADJ_TRIM then
    ops[sel_operator]:trim_draw()
  elseif sel_adj==ADJ_FILT then
    ops[sel_operator]:filter_draw()
  elseif sel_adj==ADJ_TONE then
    ops[sel_operator]:volume_draw()
    ops[sel_operator]:pitch_draw()
  else
    -- screen.display_png(_path.code.."thirtythree/img/oh.png",4,20)
  end

  -- metronome icon
  graphics:metro_icon(timekeeper:tick(),-2,3)

  -- show record level if recording
  recorder:draw()

  -- show alert atop everything if needed
  graphics:show_alert_if_needed()

  screen.update()
end


function cleanup()
  softcut.reset()
end

