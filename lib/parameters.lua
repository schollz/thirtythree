function register_parameters()
  params:add_option("layout","layout",{"5x5","4x6"},1)
  params:add_option("load sounds","load sounds",{"files","recording"},1)
  params:add_option("po-33 sound","po-33 sound",{"off","on"},1)
  params:set_action("po-33 sound",function(v)
    if v==1 then
      engine.tt_bitcrush_all(0,24,44100)
    else
      engine.tt_bitcrush_all(1,8,23000)
    end
  end)
end
