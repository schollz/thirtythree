--
-- Gridd keeps track of the grid
--

local Gridd={}

function Gridd:new(o)
  m=m or {}
  setmetatable(m,self)
  self.__index=self


  -- initiate the grid
  m.grid_on=true
  local grid = util.file_exists(_path.code.."midigrid") and include "midigrid/lib/mg_128" or grid
  m.g=grid.connect()
  m.g.key=function(x,y,z)
    if m.grid_on then
      m:grid_key(x,y,z)
    end
  end
  print("grid columns: "..m.g.cols)

  -- setup visual
  m.visual={}
  m.grid_width=16
  for i=1,8 do
    m.visual[i]={}
    for j=1,m.grid_width do
      m.visual[i][j]=0
    end
  end

  m.grid_blink=0

  print("loaded grid")
  return m
end

function Gridd:update()
  if self.grid_on then
    self.grid_blink = self.grid_blink + 1
    if self.grid_blink > 7 then 
      self.grid_blink=0
      global_blink = 1 - global_blink
    end
    self:grid_redraw()
  end
end


function Gridd:debug(s)
  if mode_debug then
    print("interface: "..s)
  end
end


function Gridd:grid_key(x,y,z)
  self:key_press(y,x,z==1)
  self:grid_redraw()
end

function Gridd:key_press(row,col,on)
  self:debug("row="..row.." col="..col)
  for _,op in pairs(ops) do
    for i=B_FIRST,B_LAST do
      local r,c=op.buttons[i].pos()
      if r==row and c==col then
        op.buttons[i].press(on)
        do return end
      end
    end
  end
end

function Gridd:get_visual()
  -- clear visual
  for row=1,8 do
    for col=1,self.grid_width do
      self.visual[row][col]=self.visual[row][col]-4
      if self.visual[row][col]<0 then
        self.visual[row][col]=0
      end
    end
  end


  for op_id,op in pairs(ops) do
    if op_id <= params:get("operators") then
      for i=B_FIRST,B_LAST do
        local r,c=op.buttons[i].pos()
        local l=op.buttons[i].light()
        if l~=nil then
          self.visual[r][c]=l
        end
      end
    end
  end

  return self.visual
end

function Gridd:grid_redraw()
  self.g:all(0)
  local gd=self:get_visual()
  local s=1
  local e=self.grid_width
  local adj=0
  for row=1,8 do
    for col=s,e do
      if gd[row][col]~=0 then
        self.g:led(col+adj,row,gd[row][col])
      end
    end
  end
  self.g:refresh()
end

return Gridd
