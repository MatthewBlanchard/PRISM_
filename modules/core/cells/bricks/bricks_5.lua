local Cell = require("core.cell")
local Tiles = require("display.tiles")

local Bricks = Cell:extend()
Bricks.name = "Bricks"
Bricks.passable = false
Bricks.opaque = true
Bricks.tile = Tiles["wall_5"]

return Bricks
