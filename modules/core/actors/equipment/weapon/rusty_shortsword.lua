local Actor = require("core.actor")
local Tiles = require("display.tiles")

local RustyShortsword = Actor:extend()
RustyShortsword.char = Tiles["shortsword"]
RustyShortsword.name = "rusty_shortsword"
RustyShortsword.color = { 0.68, 0.26, 0.06, 1 }

RustyShortsword.components = {
	components.Item(),
	components.Weapon({
		stat = "ATK",
		name = "Rusty Shortsword",
		dice = "1d2",
		time = 100,
	}),
}

return RustyShortsword
