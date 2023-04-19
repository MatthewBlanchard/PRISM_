local Actor = require("core.actor")
local Tiles = require("display.tiles")

local RingOfRegeneration = Actor:extend()
RingOfRegeneration.char = Tiles["ring"]
RingOfRegeneration.name = "Ring of Vitality"

RingOfRegeneration.components = {
<<<<<<< HEAD
   components.Item(),
   components.Equipment {
      slot = "ring",
      effects = {
         conditions.Modifystats {
            maxHP = 3,
         },
      },
   },
   components.Cost { rarity = "common" },
=======
	components.Item(),
	components.Equipment({
		slot = "ring",
		effects = {
			conditions.Modifystats({
				maxHP = 3,
			}),
		},
	}),
	components.Cost({ rarity = "common" }),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return RingOfRegeneration
