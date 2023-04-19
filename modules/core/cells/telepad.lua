local Cell = require "core.cell"
local Tiles = require "display.tiles"

local Telepad = Cell:extend()
Telepad.name = "Telepad"
Telepad.passable = true
Telepad.opaque = false
Telepad.tile = Tiles["circle_1"]
--Telepad.teleport_destination = nil

function Telepad:onAction(level, actor) level:moveActor(actor, self.teleport_destination) end

return Telepad
