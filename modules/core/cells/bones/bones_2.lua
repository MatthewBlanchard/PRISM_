local Cell = require "core.cell"
local Tiles = require "display.tiles"

local Bones = Cell:extend()
Bones.name = "Bones"
Bones.passable = true
Bones.opaque = false
Bones.tile = Tiles["bones_2"]

return Bones
