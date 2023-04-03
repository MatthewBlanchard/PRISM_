local Cell = require "cell"
local Tiles = require "tiles"

local Bridge = Cell:extend()
Bridge.name = "Bridge" -- displayed in the user interface
Bridge.passable = true -- defines whether a cell is passable
Bridge.opaque = false -- defines whether a cell can be seen through
Bridge.sightLimit = nil -- if set to an integer an actor standing on this tile's sight range will be limited to this number
Bridge.tile = Tiles["bridge_h"]

return Bridge