local Actor = require "core.actor"
local Tiles = require "display.tiles"
local LightColor = require "structures.lighting.lightcolor"

local LightningBlade = Actor:extend()
LightningBlade.char = Tiles["shortsword"]
LightningBlade.name = "Lightning Blade"
LightningBlade.color = { 1.0, 0.0141, 0.0, 1 }

LightningBlade.components = {
	components.Item(),
	components.Weapon {
		stat = "ATK",
		name = "LightningBlade",
		dice = "1d8",
		bonus = 1,
		time = 75,
	},
	components.Light {
		color = LightColor(31, 10, 5),
		effect = { components.Light.effects.colorSwap, { LightColor(6, 17, 26), 1.0, 0.5 } },
	},
	components.Cost { rarity = "uncommon" },
}

return LightningBlade
