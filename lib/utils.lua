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
