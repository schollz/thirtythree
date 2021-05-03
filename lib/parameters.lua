function register_parameters()
  params:add_number("operators","operators",1,4,1)
  params:add_option("layout","layout",{"5x5","6x4"},1)
  params:add_option("load sounds","rec + <1-16>",{"record input","load file"},1)
  params:add_option("fx global","fx global",{"no","yes"},1)
  params:read(_path.data.."thirtythree/defaults")
  params:set_action("operators",function(v)
    params:write(_path.data.."thirtythree/defaults")
  end)
  -- for _, p in ipairs({"snapshot","layout","load sounds","fx global","operators"}) do 
  --   params:set_action(p,function()
  --     print("parameter action!")
  --     params:write(_path.data.."thirtythree/defaults")
  --   end)
  -- end
end
