function rerun()
  norns.script.load(norns.state.script)
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

function os.capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

