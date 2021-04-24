-- thirtythree
--
--


mode_debug=true


-- globals
include("lib/constants")
include("lib/utils")
-- global state
sel_operator=1
sel_filename=""
sel_looppoint=1
sel_adj=ADJ_NONE
ops={} -- operators

-- engine
engine.name="Thirtythree"

-- individual libraries
pitch=include("lib/pitch")
graphics_=include("lib/graphics")
graphics=graphics_:new()
renderer_=include("lib/renderer")
renderer=renderer_:new()
voices_=include("lib/voices")
voices=voices_:new()
wav_=include("lib/wav")
wav=wav_:new()
timekeeper_=include("lib/timekeeper")
timekeeper=timekeeper_:new()
gridd_=include("lib/gridd")
gridd=gridd_:new()
sound=include("lib/sound")
operator=include("lib/operator")

function init()
  -- TODO: initialize operators
  ops[1]=operator:new()
  ops[1]:init()

  -- start updater
  runner=metro.init()
  runner.time=1/15
  runner.count=-1
  runner.event=updater
  runner:start()

  dev_=include("lib/dev")
  dev=dev_:new()
end

function updater(c)
end

function enc(k,d)
  if ADJ_TRIM then
    if k==1 then
      ops[sel_operator]:trim_zoom(sel_looppoint,d)
    else
      sel_looppoint=k-1
      ops[sel_operator]:trim_jog(sel_looppoint,d)
    end
  end
  graphics:update()
end

function key(k,z)
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
  end
  graphics:update()
end

function redraw()
  screen.clear()

  if ADJ_TRIM then
    ops[sel_operator]:trim_draw()
  end

  -- metronome icon
  graphics:metro_icon(true,-2,3)

  -- show alert atop everything if needed
  graphics:show_alert_if_needed()
  screen.update()
end


function cleanup()
  softcut.reset()
end

