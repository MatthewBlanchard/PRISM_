local Actor = require("core.actor")
local Tiles = require("display.tiles")

local Shortsword = Actor:extend()
Shortsword.char = Tiles["shortsword"]
Shortsword.name = "shortsword"

Shortsword.components = {
<<<<<<< HEAD
   components.Item(),
   components.Weapon {
      stat = "ATK",
      name = "Shortsword",
      dice = "1d6",
      time = 75,
   },
   components.Cost {},
=======
	components.Item(),
	components.Weapon({
		stat = "ATK",
		name = "Shortsword",
		dice = "1d6",
		time = 75,
	}),
	components.Cost({}),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return Shortsword
