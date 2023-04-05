local Actor = require "core.actor"
local Tiles = require "display.tiles"

local Key = Actor:extend()
Key.name = "Key"
Key.char = Tiles["key_1"]
Key.color = {0.8, 0.8, 0.1, 1}
Key.description = "A simple key. You wonder what it unlocks."

Key.components = {
	components.Item()
}

return Key