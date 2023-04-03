local Cell = require "cell"
local Tiles = require "tiles"

local Web = Cell:extend()
Web.name = "Web" -- displayed in the user interface
Web.passable = true -- defines whether a cell is passable
Web.opaque = false -- defines whether a cell can be seen through
Web.sightLimit = nil -- if set to an integer an actor standing on this tile's sight range will be limited to this number
Web.tile = Tiles["web"]

return Web