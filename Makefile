format: lua-format.py
	python3 lua-format.py thirtythree.lua
	python3 lua-format.py lib/utils.lua
	python3 lua-format.py lib/graphics.lua
	python3 lua-format.py lib/dev.lua
	python3 lua-format.py lib/graphics.lua
	python3 lua-format.py lib/sound.lua
	python3 lua-format.py lib/operator.lua
	python3 lua-format.py lib/renderer.lua

lua-format.py:
	wget https://raw.githubusercontent.com/schollz/LuaFormat/master/lua-format.py