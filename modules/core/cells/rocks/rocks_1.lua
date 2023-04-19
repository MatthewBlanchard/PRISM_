local Cell = require("core.cell")
local Tiles = require("display.tiles")

local Rocks = Cell:extend()
Rocks.name = "Rocks"
Rocks.passable = false
Rocks.opaque = true
Rocks.tile = Tiles["rocks_1"]

return Rocks
