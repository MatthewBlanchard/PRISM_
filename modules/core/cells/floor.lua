local Cell = require "core.cell"
local Tiles = require "display.tiles"

local Floor = Cell:extend()
Floor.name = "Floor"
Floor.passable = true
Floor.opaque = false
Floor.tile = Tiles["floor"]

return Floor