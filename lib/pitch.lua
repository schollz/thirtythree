local Pitch={
  rates={1/1,16/15,9/8,6/5,5/4,4/3,45/32,3/2,8/5,5/3,16/9,15/8},
}

-- transpose_rate returns a transpostion to a rate
-- tranpose +i notes
-- https://github.com/monome/norns/blob/main/lua/lib/intonation.lua#L16
function Pitch.transpose_rate(i)
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
  return Pitch.rates[i]*math.pow(2,octave)
end

assert(Pitch.transpose_rate(0)==1)
assert(Pitch.transpose_rate(1)==16/15)
assert(Pitch.transpose_rate(12)==2)
assert(Pitch.transpose_rate(-12)==1/2)
assert(Pitch.transpose_rate(-1)==15/8/2)

return Pitc
