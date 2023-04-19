local Actor = require("core.actor")
local Tiles = require("display.tiles")

local PlateofPaucity = Actor:extend()
PlateofPaucity.char = Tiles["armor"]
PlateofPaucity.name = "Plate of Paucity"

PlateofPaucity.components = {
<<<<<<< HEAD
   components.Item(),
   components.Equipment {
      slot = "body",
      effects = {
         conditions.Modifystats {
            AC = 3,
            PR = 1,
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
				AC = 3,
				PR = 1,
			}),
		},
	}),
	components.Cost({ rarity = "common" }),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return PlateofPaucity
