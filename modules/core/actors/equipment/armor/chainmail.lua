local Actor = require("core.actor")
local Tiles = require("display.tiles")

local JerkinOfGrease = Actor:extend()
JerkinOfGrease.char = Tiles["armor"]
JerkinOfGrease.name = "Mantle of Broken Chains"
JerkinOfGrease.description =
   "Nothing can slow you down with this armor on. You also move a bit faster."

JerkinOfGrease.components = {
<<<<<<< HEAD
   components.Item(),
   components.Equipment {
      slot = "body",
      effects = {
         conditions.Modifystats {
            AC = 2,
            PR = 1,
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
				AC = 2,
				PR = 1,
			}),
		},
	}),
	components.Cost({ rarity = "rare" }),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return JerkinOfGrease
