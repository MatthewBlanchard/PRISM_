local Actor = require("core.actor")
local Tiles = require("display.tiles")

local Longsword = Actor:extend()
Longsword.char = Tiles["shortsword"]
Longsword.name = "longsword"

Longsword.components = {
<<<<<<< HEAD
   components.Item(),
   components.Weapon {
      stat = "ATK",
      name = "Longsword",
      dice = "1d8",
      time = 100,
   },
   components.Cost {},
=======
	components.Item(),
	components.Weapon({
		stat = "ATK",
		name = "Longsword",
		dice = "1d8",
		time = 100,
	}),
	components.Cost({}),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return Longsword
