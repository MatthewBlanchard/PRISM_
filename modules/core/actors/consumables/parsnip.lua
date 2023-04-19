local Actor = require("core.actor")
local Tiles = require("display.tiles")

local Parsnip = Actor:extend()
Parsnip.name = "Parsnip"
Parsnip.description = "A bland root vegetable."
Parsnip.color = { 0.97, 0.93, 0.55, 1 }
Parsnip.char = Tiles["parsnip"]

Parsnip.components = {
<<<<<<< HEAD
   components.Item { stackable = true },
   components.Usable(),
   components.Edible { nutrition = 2 },
   components.Cost {},
=======
	components.Item({ stackable = true }),
	components.Usable(),
	components.Edible({ nutrition = 2 }),
	components.Cost({}),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return Parsnip
