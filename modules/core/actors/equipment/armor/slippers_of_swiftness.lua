local Actor = require("core.actor")
local Tiles = require("display.tiles")

local SlippersOfSwiftness = Actor:extend()
SlippersOfSwiftness.char = Tiles["shoes"]
SlippersOfSwiftness.name = "Slippers of Swiftness"

SlippersOfSwiftness.components = {
<<<<<<< HEAD
   components.Item(),
   components.Equipment {
      slot = "feet",
      effects = {
         conditions.Swiftness,
      },
   },
   components.Cost { rarity = "rare" },
=======
	components.Item(),
	components.Equipment({
		slot = "feet",
		effects = {
			conditions.Swiftness,
		},
	}),
	components.Cost({ rarity = "rare" }),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return SlippersOfSwiftness
