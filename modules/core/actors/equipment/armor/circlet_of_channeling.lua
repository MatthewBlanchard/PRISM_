local Actor = require "core.actor"
local Tiles = require "display.tiles"

local BandOfChanneling = Actor:extend()
BandOfChanneling.char = Tiles["tiara"]
BandOfChanneling.name = "Circlet of Channeling"
BandOfChanneling.description =
	"When you cast a spell magic courses through this ring. It damages everything around you."
BandOfChanneling.components = {
	components.Item(),
	components.Equipment {
		slot = "head",
		effects = {
			conditions.Modifystats {
				MGK = 1,
			},
			conditions.Channel(),
		},
	},
	components.Cost { rarity = "uncommon" },
}

return BandOfChanneling
