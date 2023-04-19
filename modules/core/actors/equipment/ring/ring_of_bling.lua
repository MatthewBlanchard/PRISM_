local Actor = require("core.actor")
local Tiles = require("display.tiles")

local RingOfBling = Actor:extend()
RingOfBling.char = Tiles["ring"]
RingOfBling.name = "Ring of Bling"
RingOfBling.description =
<<<<<<< HEAD
   "Wandering monster stop and stare at this extravagant ring! When you pick up shards sometimes you'll find an extra!"

RingOfBling.components = {
   components.Item(),
   components.Equipment {
      slot = "ring",
      effects = {
         conditions.Additionalshards {
            chance = 0.25,
         },
      },
   },
   components.Cost { rarity = "rare" },
=======
	"Wandering monster stop and stare at this extravagant ring! When you pick up shards sometimes you'll find an extra!"

RingOfBling.components = {
	components.Item(),
	components.Equipment({
		slot = "ring",
		effects = {
			conditions.Additionalshards({
				chance = 0.25,
			}),
		},
	}),
	components.Cost({ rarity = "rare" }),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return RingOfBling
