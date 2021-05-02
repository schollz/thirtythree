function register_parameters()
  params:add_number("snapshot","snapshot #",1,99)
  params:add_option("layout","layout",{"5x5","6x4"},1)
  params:add_option("load sounds","rec + <1-16>",{"record input","load file"},1)
  params:add_option("fx global","fx global",{"no","yes"},1)
  params:read(_path.data.."thirtythree/defaults")
  for _, p in ipairs({"snapshot","layout","load sounds","fx global"}) do 
    params:set_action(p,function()
      params:write(_path.data.."thirtythree/defaults")
    end)
  end
end
