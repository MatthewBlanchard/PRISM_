local Actor = require "core.actor"
local Tiles = require "display.tiles"
local LightColor = require "lighting.lightcolor"

local Torch = Actor:extend()
Torch.char = Tiles["torch"]
Torch.name = "torch"
Torch.color = { 0.8666, 0.4509, 0.0862, 1 }

Torch.components = {
    components.Light{
        color = LightColor(28, 16, 1),
        effect = {components.Light.effects.flicker, {0.15, 0.3}},
    },
    components.Item(),
    components.Equipment{
        slot = "offhand",
    },
}

return Torch
