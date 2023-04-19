local Actor = require("core.actor")
local Tiles = require("display.tiles")

local Dagger = Actor:extend()
Dagger.char = Tiles["shortsword"]
Dagger.name = "dagger"

Dagger.components = {
<<<<<<< HEAD
   components.Item(),
   components.Weapon {
      stat = "ATK",
      name = "Dagger",
      dice = "1d4",
      time = 50,
   },
   components.Cost {},
=======
	components.Item(),
	components.Weapon({
		stat = "ATK",
		name = "Dagger",
		dice = "1d4",
		time = 50,
	}),
	components.Cost({}),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return Dagger
