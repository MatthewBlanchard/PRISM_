local Cell = require "cell"
local Tiles = require "tiles"

local Wall = Cell:extend()
Wall.name = "Wall" -- displayed in the user interface
Wall.passable = true -- defines whether a cell is passable
Wall.opaque = false -- defines whether a cell can be seen through
Wall.sightLimit = nil -- if set to an integer an actor standing on this tile's sight range will be limited to this number
Wall.tile = Tiles["wall_1"]

return Wall