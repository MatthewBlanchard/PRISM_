local Cell = require "core.cell"
local Tiles = require "display.tiles"

local Dirt = Cell:extend()
Dirt.name = "Dirt"
Dirt.passable = true
Dirt.opaque = false
Dirt.tile = Tiles["grad2"]

return Dirt
