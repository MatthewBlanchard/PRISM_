local Cell = require "cell"
local Tiles = require "tiles"

local Fence = Cell:extend()
Fence.name = "Fence" -- displayed in the user interface
Fence.passable = false -- defines whether a cell is passable
Fence.opaque = false -- defines whether a cell can be seen through
Fence.sightLimit = nil -- if set to an integer an actor standing on this tile's sight range will be limited to this number
Fence.tile = Tiles["fence"]

return Fence