local Actor = require("core.actor")
local Tiles = require("display.tiles")
local Colors = require("math.colors")

local Shard = Actor:extend()
Shard.name = "shard"
Shard.char = Tiles["shard"]
Shard.color = Colors.BLUE

Shard.components = {
<<<<<<< HEAD
   components.Item(),
   components.Currency { worth = 1 },
=======
	components.Item(),
	components.Currency({ worth = 1 }),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return Shard
