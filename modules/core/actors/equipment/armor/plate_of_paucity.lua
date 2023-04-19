local Actor = require("core.actor")
local Tiles = require("display.tiles")

local PlateofPaucity = Actor:extend()
PlateofPaucity.char = Tiles["armor"]
PlateofPaucity.name = "Plate of Paucity"

PlateofPaucity.components = {
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
}

return PlateofPaucity
