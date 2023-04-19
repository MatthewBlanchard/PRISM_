local Actor = require("core.actor")
local Tiles = require("display.tiles")

local RobeOfTatters = Actor:extend()
RobeOfTatters.char = Tiles["armor"]
RobeOfTatters.name = "Robe of Rags"

RobeOfTatters.components = {
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
}

return RobeOfTatters
