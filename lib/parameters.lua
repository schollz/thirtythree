function register_parameters()
  params:add_number("snapshot","snapshot #",1,99)
  params:add_option("layout","layout",{"5x5","4x6"},1)
  params:add_option("load sounds","rec + <1-16>",{"record input","load file"},2)
end
