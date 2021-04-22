format: lua-format.py
	python3 lua-format.py lib/Sound.lua
	python3 lua-format.py lib/Operator.lua
	python3 lua-format.py lib/includes.lua
# 	git commit -am "formatted"
# 	git diff HEAD^

lua-format.py:
	wget https://raw.githubusercontent.com/schollz/LuaFormat/master/lua-format.py
