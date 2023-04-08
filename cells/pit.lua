local Cell = require "cell"
local Tiles = require "tiles"

local Pit = Cell:extend()
Pit.name = "Pit" -- displayed in the user interface
Pit.passable = false -- defines whether a cell is passable
Pit.opaque = false -- defines whether a cell can be seen through
Pit.sightLimit = nil -- if set to an integer an actor standing on this tile's sight range will be limited to this number
Pit.tile = Tiles["empty"]

return Pit