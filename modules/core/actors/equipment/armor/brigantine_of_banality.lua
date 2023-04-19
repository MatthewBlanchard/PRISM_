local Actor = require "core.actor"
local Tiles = require "display.tiles"

local BrigantineofBanality = Actor:extend()
BrigantineofBanality.char = Tiles["armor"]
BrigantineofBanality.name = "Brigantine of Banality"

BrigantineofBanality.components = {
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
}

return BrigantineofBanality
