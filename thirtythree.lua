-- thirtythree
--
--


include("lib/utils") -- global utility functoins
graphics_=include("lib/graphics")
graphics=graphics_:new()
renderer_=include("lib/renderer")
renderer=renderer_:new()
dev_=include("lib/dev")
dev=dev_:new()

function init()
end

function updater(c)
  redraw()
end

function enc(k,d)

end


function key(k,z)

end

function redraw()
  screen.clear()
  -- metronome icon
  graphics:metro_icon(true,-2,3)

  -- show alert atop everything if needed
  graphics:show_alert_if_needed()
  screen.update()
end


function cleanup()
  softcut.reset()
end

