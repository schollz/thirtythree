-- thirtythree
--
--


mode_debug=true


-- global functoins
include("lib/utils")
-- global state
sel_operator=1
sel_filename=""
ops={} -- operators

-- individiaul libraries
graphics_=include("lib/graphics")
graphics=graphics_:new()
renderer_=include("lib/renderer")
renderer=renderer_:new()
dev_=include("lib/dev")
dev=dev_:new()
-- sound_=include("lib/sound")
-- operator_=include("lib/operator")

function init()
  -- TODO: initialize operators

  -- start updater
  runner=metro.init()
  runner.time=1/15
  runner.count=-1
  runner.event=updater
  runner:start()
end

function updater(c)
  graphics:update()
end

function enc(k,d)

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

