local Graphics={}


local FilterGraph=require "filtergraph"


function Graphics:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self

  o.alert_msg=""
  o.dirty=false
  o.fps=15
  clock.run(function()
    while true do
      if o.dirty then
        o.dirty=false
        redraw()
      end
      clock.sleep(1/o.fps)
    end
  end)
  return o
end

function Graphics:update()
  self.dirty=true
end

-- alert shows an alert for 2 seconds
function Graphics:alert(msg)
  clock.run(function()
    self.alert_msg=message
    self.dirty=true
    clock.sleep(2)
    self.alert_msg=nil
    self.dirty=true
  end)
end

function Graphics:show_alert_if_needed()
  if self.alert_msg==nil or self.alert_msg=="" then
    do return end
  end
  screen.level(0)
  local x=64
  local y=28
  local w=string.len(self.alert_msg)*6
  screen.rect(x-w/2,y,w,10)
  screen.fill()
  screen.level(15)
  screen.rect(x-w/2,y,w,10)
  screen.stroke()
  screen.move(x,y+7)
  screen.text_center(self.alert_msg)
end

function Graphics:box_text(x,y,s,invert)
  screen.level(0)
  if invert==true then
    screen.level(15)
  end
  w=screen.text_extents(s)+7
  if s=="start" then
    w=w+1
  end
  screen.rect(x-w/2,y,w,10)
  screen.fill()
  screen.level(5)
  if invert==true then
    screen.level(0)
  end
  screen.rect(x-w/2,y,w,10)
  screen.stroke()
  screen.move(x,y+6)
  screen.text_center(s)
  if invert==true then
    screen.level(15)
  end
  return x-w/2,y,w
end

function Graphics:metro_icon(tick,x,y)
  screen.move(x+2,y+5)
  screen.line(x+7,y)
  screen.line(x+12,y+5)
  screen.line(x+3,y+5)
  screen.stroke()
  screen.move(x+7,y+3)
  screen.line(tick and (x+4) or (x+10),y)
  screen.stroke()
end

function Graphics:lpf()
  local filter_graph=FilterGraph.new(20,20000,-60,30,"lowpass",12,2000,0)
  filter_graph:set_position_and_size(4,22,56,38)
end

return Graphics
