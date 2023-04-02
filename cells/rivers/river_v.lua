local Cell = require "cell"
local Tiles = require "tiles"

local River = Cell:extend()
River.name = "River" -- displayed in the user interface
River.passable = true -- defines whether a cell is passable
River.opaque = true -- defines whether a cell can be seen through
River.sightLimit = nil -- if set to an integer an actor standing on this tile's sight range will be limited to this number
River.tile = Tiles["river_v_1"]

return River