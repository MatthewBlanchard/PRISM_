local Actor = require "actor"
local Tiles = require "tiles"

local LightningBlade = Actor:extend()
LightningBlade.char = Tiles["shortsword"]
LightningBlade.name = "Lightning Blade"
LightningBlade.color = { 1.0, 0.0141, 0.0, 1}

local lightEffect = components.Light.effects.colorSwap({ 1.0, 0.0141, 0.0, 1}, { 0.198, 0.60, 0.831, 1}, 1.0, 0.3)

LightningBlade.components = {
    components.Item(),
    components.Weapon{
        stat = "ATK",
        name = "LightningBlade",
        dice = "1d8",
        bonus = 1,
        time = 75
    },
    components.Light{
        color = { 1.0, 0.0141, 0.0, 1},
        intensity = 3,
        effect = lightEffect
    },
    components.Cost{rarity = "uncommon"}
}

return LightningBlade