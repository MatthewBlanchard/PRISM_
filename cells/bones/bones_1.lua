local Cell = require "cell"
local Tiles = require "tiles"

local Bones = Cell:extend()
Bones.name = "Bones" -- displayed in the user interface
Bones.passable = true -- defines whether a cell is passable
Bones.opaque = true -- defines whether a cell can be seen through
Bones.sightLimit = nil -- if set to an integer an actor standing on this tile's sight range will be limited to this number
Bones.tile = Tiles["bones_1"]

return Bones