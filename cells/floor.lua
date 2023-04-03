local Cell = require "cell"
local Tiles = require "tiles"

local Floor = Cell:extend()
Floor.name = "Floor" -- displayed in the user interface
Floor.passable = true -- defines whether a cell is passable
Floor.opaque = false -- defines whether a cell can be seen through
Floor.sightLimit = nil -- if set to an integer an actor standing on this tile's sight range will be limited to this number
Floor.tile = Tiles["floor"]

return Floor