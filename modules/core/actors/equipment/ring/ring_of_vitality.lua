local Actor = require("core.actor")
local Tiles = require("display.tiles")

local RingOfRegeneration = Actor:extend()
RingOfRegeneration.char = Tiles["ring"]
RingOfRegeneration.name = "Ring of Vitality"

RingOfRegeneration.components = {
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
}

return RingOfRegeneration
