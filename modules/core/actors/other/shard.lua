local Actor = require "core.actor"
local Tiles = require "display.tiles"
local Colors = require "math.colors"

local Shard = Actor:extend()
Shard.name = "shard"
Shard.char = Tiles["shard"]
Shard.color = Colors.BLUE

Shard.components = {
	components.Item(),
	components.Currency{worth = 1}
}

return Shard
