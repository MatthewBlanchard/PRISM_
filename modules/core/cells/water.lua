local Cell = require "core.cell"
local Tiles = require "display.tiles"

local Water = Cell:extend()
Water.name = "Water"
Water.passable = true
Water.opaque = false
Water.tile = Tiles["water"]

return Water
