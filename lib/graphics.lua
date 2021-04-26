local Graphics={}


local FilterGraph=require "filtergraph"
local UI=require "ui"

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

function Graphics:text_center(s)
  screen.font_size(8)
  screen.level(15)
  screen.move(64,35)
  screen.text_center(s)
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
  screen.level(15)
  screen.move(x+2,y+5)
  screen.line(x+7,y)
  screen.line(x+12,y+5)
  screen.line(x+3,y+5)
  screen.stroke()
  screen.move(x+7,y+3)
  screen.line(tick and (x+4) or (x+10),y)
  screen.stroke()
  screen.move(x+16,y+4)
  screen.text(params:get("clock_tempo"))
end

function Graphics:filter(filter_type,freq,resonance)
  screen.level(15)
  local filter_graph=FilterGraph.new(20,20000,-60,30,filter_type,12,freq,resonance)
  filter_graph:set_position_and_size(4,22,120,38)
  filter_graph:redraw()
end

function Graphics:volume(vol)
  screen.font_size(12)
  screen.level(15)
  screen.move(4,33)
  screen.text("Vol")
  local slider=UI.Slider.new(28,24,90,10,vol,0,1,{0,0.5,1},'right')
  slider:redraw()
end

function Graphics:pitch(pitch)
  screen.font_size(12)
  screen.level(15)
  screen.move(4,55)
  screen.text("Ptc")
  -- pitch=-12
  local slider=UI.Slider.new(28,55-9,90,10,0,0,1,{0,0.5,1},'right')
  slider:redraw()
  if pitch>0 then
    local slider2=UI.Slider.new(74,55-9,44,10,pitch,0,12,{},'right')
    slider2:redraw()
  elseif pitch<0 then
    local slider2=UI.Slider.new(74-45-1,55-9,45,10,math.abs(pitch),0,12,{},'left')
    slider2:redraw()
  end
end

function Graphics:box(x,y,w,h,c)
  screen.level(0)
  screen.rect(x,y,w,h)
  screen.fill()
  screen.level(c or 15)
  screen.rect(x,y,w,h)
  screen.stroke()
end

function Graphics:show_level(level)
  self:box(3,45,120,14,0)
  screen.font_size(12)
  screen.level(15)
  screen.move(4,55)
  screen.text("Rec")
  -- pitch=-12
  local slider=UI.Slider.new(28,55-9,92,10,level,0,1,{},'right')
  slider:redraw()
end

return Graphics
