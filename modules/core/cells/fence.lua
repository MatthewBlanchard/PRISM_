local Cell = require "core.cell"
local Tiles = require "display.tiles"

local Fence = Cell:extend()
Fence.name = "Fence"
Fence.passable = false
Fence.opaque = false
Fence.tile = Tiles["fence"]

return Fence