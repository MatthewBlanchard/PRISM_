local Cell = require "core.cell"
local Tiles = require "display.tiles"

local Water = Cell:extend()
Water.name = "Water"
Water.passable = false
Water.opaque = false
Water.tile = Tiles["water"]

return Water