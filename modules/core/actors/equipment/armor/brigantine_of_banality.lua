local Actor = require("core.actor")
local Tiles = require("display.tiles")

local BrigantineofBanality = Actor:extend()
BrigantineofBanality.char = Tiles["armor"]
BrigantineofBanality.name = "Brigantine of Banality"

BrigantineofBanality.components = {
<<<<<<< HEAD
   components.Item(),
   components.Equipment {
      slot = "body",
      effects = {
         conditions.Modifystats {
            AC = 2,
            ATK = 1,
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
				AC = 2,
				ATK = 1,
			}),
		},
	}),
	components.Cost({ rarity = "common" }),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return BrigantineofBanality
