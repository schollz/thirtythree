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
ops={} -- operators

-- engine
engine.name="Thirtythree"

-- individual libraries
graphics_=include("lib/graphics")
graphics=graphics_:new()
renderer_=include("lib/renderer")
renderer=renderer_:new()
voices_=include("lib/voices")
voices=voices_:new()
wav_=include("lib/wav")
wav=wav_:new()
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
  graphics:update()
end

function enc(k,d)
  if k==1 then
    renderer:zoom(sel_filename,sel_looppoint,d)
  else
    sel_looppoint=k-1
    renderer:jog(sel_filename,sel_looppoint,d)
  end

end

function key(k,z)

end

function redraw()
  screen.clear()

  -- draw current file if its there
  renderer:draw(sel_filename)

  -- metronome icon
  graphics:metro_icon(true,-2,3)

  -- show alert atop everything if needed
  graphics:show_alert_if_needed()
  screen.update()
end


function cleanup()
  softcut.reset()
end

