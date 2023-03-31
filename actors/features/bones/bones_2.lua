local Actor = require "actor"
local Tiles = require "tiles"

local Bones = Actor:extend()
Bones.char = Tiles["bones_2"]
Bones.name = "bones"
Bones.color = { 1.0, 1.0, 1.0, 1}
Bones.remembered = true

Bones.components = {}

return Bones