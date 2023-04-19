local Actor = require("core.actor")
local Tiles = require("display.tiles")

local Steak = Actor:extend()
Steak.name = "Steak"
Steak.description =
<<<<<<< HEAD
   "This steak looks like it's been marinated in mystery and seared with intrigue. Eat at your own risk, and prepare for a flavor adventure."
=======
	"This steak looks like it's been marinated in mystery and seared with intrigue. Eat at your own risk, and prepare for a flavor adventure."
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
Steak.color = { 0.97, 0.33, 0.35, 1 }
Steak.char = Tiles["steak"]

Steak.components = {
<<<<<<< HEAD
   components.Item { stackable = true },
   components.Usable(),
   components.Edible { nutrition = 10 },
   components.Cost { rarity = "rare" },
=======
	components.Item({ stackable = true }),
	components.Usable(),
	components.Edible({ nutrition = 10 }),
	components.Cost({ rarity = "rare" }),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return Steak
