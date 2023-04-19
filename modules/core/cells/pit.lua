local Cell = require("core.cell")
local Tiles = require("display.tiles")

local Pit = Cell:extend()
Pit.name = "Pit"
Pit.passable = false
Pit.opaque = false
Pit.tile = Tiles["empty"]

return Pit
