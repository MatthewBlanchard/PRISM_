local Actor = require("core.actor")
local Tiles = require("display.tiles")

local Greatsword = Actor:extend()
Greatsword.char = Tiles["shortsword"]
Greatsword.name = "greatsword"

Greatsword.components = {
<<<<<<< HEAD
   components.Item(),
   components.Weapon {
      stat = "ATK",
      name = "Greatsword",
      dice = "2d6",
      time = 150,
   },
   components.Cost {},
=======
	components.Item(),
	components.Weapon({
		stat = "ATK",
		name = "Greatsword",
		dice = "2d6",
		time = 150,
	}),
	components.Cost({}),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return Greatsword
