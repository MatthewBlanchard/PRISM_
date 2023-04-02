local Actor = require "core.actor"
local Tiles = require "display.tiles"

local Bones = Actor:extend()
Bones.char = Tiles["bones_2"]
Bones.name = "bones"
Bones.color = { 1.0, 1.0, 1.0, 1}
Bones.remembered = true

Bones.components = {}

return Bones