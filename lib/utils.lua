function rerun()
  norns.script.load(norns.state.script)
end

function table.isempty(t)
  if t==nil then
    do return true end
  end
  for k,_ in pairs(t) do
    do return false end
  end
  return true
end

function math.sign(number)
  if number>0 then
    return 1
  elseif number<0 then
    return-1
  else
    return 0
  end
end

function check_and_install_aubioonset()
  if not util.file_exists("/usr/bin/aubioonset") then
    print("installing aubio-tools")
    os.execute("sudo apt install -y aubio-tools")
    os.execute("sudo chmod +x ".._path.code.."thirtythree/defaults/aubio/aubioonset")
    os.execute("sudo cp ".._path.code.."thirtythree/defaults/aubio/aubioonset /usr/bin/aubioonset")
  else
    print("aubio tools installed")
  end
end

function os.capture(cmd,raw)
  local f=assert(io.popen(cmd,'r'))
  local s=assert(f:read('*a'))
  f:close()
  if raw then return s end
  s=string.gsub(s,'^%s+','')
  s=string.gsub(s,'%s+$','')
  s=string.gsub(s,'[\n\r]+',' ')
  return s
end

function os.time2()
  return clock.get_beats()*clock.get_beat_sec()
end

function _list_files(d,files,recursive)
  -- list files in a flat table
  if d=="." or d=="./" then
    d=""
  end
  if d~="" and string.sub(d,-1)~="/" then
    d=d.."/"
  end
  folders={}
  if recursive then
    local cmd="ls -ad "..d.."*/ 2>/dev/null"
    local f=assert(io.popen(cmd,'r'))
    local out=assert(f:read('*a'))
    f:close()
    for s in out:gmatch("%S+") do
      if not (string.match(s,"ls: ") or s=="../" or s=="./") then
        files=_list_files(s,files,recursive)
      end
    end
  end
  do
    local cmd="ls -p "..d
    local f=assert(io.popen(cmd,'r'))
    local out=assert(f:read('*a'))
    f:close()
    for s in out:gmatch("%S+") do
      table.insert(files,d..s)
    end
  end
  return files
end

function list_files(d,recurisve)
  if recursive==nil then
    recursive=false
  end
  return _list_files(d,{},recursive)
end

function os.read_file(filename)
  if not util.file_exists(filename) then
    do return end
  end

  local f=io.open(filename,"rb")
  local content=f:read("*all")
  f:close()
  return content
end


-- transpose_rate returns a transpostion to a rate
-- tranpose +i notes
-- https://github.com/monome/norns/blob/main/lua/lib/intonation.lua#L16
local rates_12note={1/1,16/15,9/8,6/5,5/4,4/3,45/32,3/2,8/5,5/3,16/9,15/8}
function pitch_to_rate(i)
  i=i+1
  octave=0
  while i<1 do
    octave=octave-1
    i=i+12
  end
  while i>12 do
    octave=octave+1
    i=i-12
  end
  return rates_12note[i]*math.pow(2,octave)
end

assert(pitch_to_rate(0)==1)
assert(pitch_to_rate(1)==16/15)
assert(pitch_to_rate(12)==2)
assert(pitch_to_rate(-12)==1/2)
assert(pitch_to_rate(-1)==15/8/2)


local all_scale_names={}
for i=1,#MusicUtil.SCALES do
  table.insert(all_scale_names,string.lower(MusicUtil.SCALES[i].name))
end

function scale_names()
  return all_scale_names
end




 
