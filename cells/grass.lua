local Cell = require "cell"
local Tiles = require "tiles"

local Grass = Cell:extend()
Grass.name = "Grass" -- displayed in the user interface
Grass.passable = true -- defines whether a cell is passable
Grass.opaque = false -- defines whether a cell can be seen through
Grass.tile = Tiles["grass"]
Grass.sightLimit = 3 -- when standing on this tile does it interfere with sight?

return Grass