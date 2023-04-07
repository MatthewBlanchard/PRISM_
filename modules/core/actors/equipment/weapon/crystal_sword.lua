local Actor = require "core.actor"
local Tiles = require "display.tiles"
local LightColor = require "structures.lighting.lightcolor"

local CrystalSword = Actor:extend()
CrystalSword.char = Tiles["shortsword"]
CrystalSword.name = "Crystal Sword"
CrystalSword.color = { 0.498, 1.00, 0.831, 1}

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
        color = LightColor(15, 31, 25),
        effect = {components.Light.effects.pulse, {0.2, 0.2}},
    },
    components.Cost{rarity = "uncommon"}
}

return CrystalSword