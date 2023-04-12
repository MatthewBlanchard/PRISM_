local Cell = require "core.cell"
local Tiles = require "display.tiles"

local Floor = Cell:extend()
Floor.name = "Floor"
Floor.passable = false
Floor.opaque = true
Floor.tile = Tiles["floor"]

return Floor