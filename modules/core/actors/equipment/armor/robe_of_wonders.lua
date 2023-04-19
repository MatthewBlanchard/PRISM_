local Actor = require("core.actor")
local Tiles = require("display.tiles")

local RobeOfWonders = Actor:extend()
RobeOfWonders.char = Tiles["cloak"]
RobeOfWonders.name = "Robe of Wonders"

RobeOfWonders.components = {
<<<<<<< HEAD
   components.Item(),
   components.Equipment {
      slot = "body",
      effects = {
         conditions.Modifystats {
            MGK = 2,
            MR = 1,
            AC = 1,
         },
         conditions.Refundcharge {
            chance = 0.50,
         },
      },
   },
   components.Cost { rarity = "rare" },
=======
	components.Item(),
	components.Equipment({
		slot = "body",
		effects = {
			conditions.Modifystats({
				MGK = 2,
				MR = 1,
				AC = 1,
			}),
			conditions.Refundcharge({
				chance = 0.50,
			}),
		},
	}),
	components.Cost({ rarity = "rare" }),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return RobeOfWonders
