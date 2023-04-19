local Cell = require("core.cell")
local Tiles = require("display.tiles")

local River = Cell:extend()
River.name = "River"
River.passable = true
River.opaque = false
River.tile = Tiles["river_h_1"]

return River
