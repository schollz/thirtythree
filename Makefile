format: lua-format.py
	python3 lua-format.py thirtythree.lua
	python3 lua-format.py lib/utils.lua
	python3 lua-format.py lib/graphics.lua
	python3 lua-format.py lib/dev.lua
	python3 lua-format.py lib/graphics.lua
	python3 lua-format.py lib/sound.lua
	python3 lua-format.py lib/operator.lua
	python3 lua-format.py lib/renderer.lua
	python3 lua-format.py lib/gridd.lua
	python3 lua-format.py lib/constants.lua
	python3 lua-format.py lib/voices.lua
	python3 lua-format.py lib/pitch.lua
	python3 lua-format.py lib/timekeeper.lua
	python3 lua-format.py lib/recorder.lua
	python3 lua-format.py lib/lock.lua
	python3 lua-format.py lib/snapshot.lua
	python3 lua-format.py lib/parameters.lua
	python3 lua-format.py lib/ngen.lua

todo:
	rg TODO -g '*.lua'

test:
	rg TEST -g '*.lua'

lua-format.py:
	wget https://raw.githubusercontent.com/schollz/LuaFormat/master/lua-format.py
