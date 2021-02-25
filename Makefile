LUA = build/wasm
SRC = wasm
LUAFILES:=$(patsubst %.tl, $(LUA)/%.lua, $(shell find $(SRC) -name '*.tl' -type f -printf "%f "))

module: $(LUAFILES)

$(LUA)/%.lua: $(SRC)/%.tl
	tl gen -o $@ $< > /dev/null

clean:
	rm $(LUAFILES)
