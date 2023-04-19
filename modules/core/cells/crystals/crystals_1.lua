local Cell = require "core.cell"
local Tiles = require "display.tiles"

local Crystals = Cell:extend()
Crystals.name = "Crystals"
Crystals.passable = false
Crystals.opaque = true
Crystals.tile = Tiles["crystal_1"]

return Crystals
