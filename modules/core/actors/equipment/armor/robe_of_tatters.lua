local Actor = require("core.actor")
local Tiles = require("display.tiles")

local RobeOfTatters = Actor:extend()
RobeOfTatters.char = Tiles["armor"]
RobeOfTatters.name = "Robe of Rags"

RobeOfTatters.components = {
<<<<<<< HEAD
   components.Item(),
   components.Equipment {
      slot = "body",
      effects = {
         conditions.Modifystats {
            AC = 1,
            MGK = 1,
         },
      },
   },
   components.Cost { rarity = "common" },
=======
	components.Item(),
	components.Equipment({
		slot = "body",
		effects = {
			conditions.Modifystats({
				AC = 1,
				MGK = 1,
			}),
		},
	}),
	components.Cost({ rarity = "common" }),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return RobeOfTatters
