local Cell = require "cell"
local Tiles = require "tiles"

local Rocks = Cell:extend()
Rocks.name = "Rocks" -- displayed in the user interface
Rocks.passable = true -- defines whether a cell is passable
Rocks.opaque = true -- defines whether a cell can be seen through
Rocks.sightLimit = nil -- if set to an integer an actor standing on this tile's sight range will be limited to this number
Rocks.tile = Tiles["rocks_2"]

return Rocks