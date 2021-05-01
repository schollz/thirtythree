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
    os.execute("sudo chmod +x ".._path.code.."thirtythree/aubio/aubioonset")
    os.execute("sudo cp ".._path.code.."thirtythree/aubio/aubioonset /usr/bin/aubioonset")
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
