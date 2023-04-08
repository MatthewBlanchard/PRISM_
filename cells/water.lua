local Cell = require "cell"
local Tiles = require "tiles"

local Water = Cell:extend()
Water.name = "Water" -- displayed in the user interface
Water.passable = false -- defines whether a cell is passable
Water.opaque = false -- defines whether a cell can be seen through
Water.sightLimit = nil -- if set to an integer an actor standing on this tile's sight range will be limited to this number
Water.tile = Tiles["water"]

return Water