local Cell = require "core.cell"
local Tiles = require "display.tiles"

local Bridge = Cell:extend()
Bridge.name = "Bridge"
Bridge.passable = true
Bridge.opaque = false
Bridge.tile = Tiles["bridge_h"]

return Bridge