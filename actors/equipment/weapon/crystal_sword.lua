local Actor = require "actor"
local Tiles = require "tiles"

local CrystalSword = Actor:extend()
CrystalSword.char = Tiles["shortsword"]
CrystalSword.name = "Crystal Sword"
CrystalSword.color = { 0.498, 1.00, 0.831, 1}

local lightEffect = components.Light.effects.pulse({ 0.498, 1.00, 0.831, 1}, 0.2, 0.2)

CrystalSword.components = {
    components.Item(),
    components.Weapon{
        stat = "MGK",
        name = "CrystalSword",
        dice = "1d2",
        bonus = 1,
        time = 100
    },
    components.Light{
        color = { 0.498, 1.00, 0.831, 1},
        intensity = 3,
        effect = lightEffect
    },
    components.Cost{rarity = "uncommon"}
}

return CrystalSword