local Actor = require "actor"
local Tiles = require "tiles"
local LightColor = require "lighting.lightcolor"

local Torch = Actor:extend()
Torch.char = Tiles["torch"]
Torch.name = "torch"
Torch.color = { 0.8666, 0.4509, 0.0862, 1 }

local lightEffect = components.Light.effects.flicker({ 0.8666, 0.4509, 0.0862, 1 }, 0.2, 0.07)

Torch.components = {
    components.Light{
        color = LightColor(28, 16, 1),
        effect = lightEffect
    },
    components.Item(),
    components.Equipment{
        slot = "offhand",
    },
}

return Torch
