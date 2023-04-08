local Cell = require "cell"
local Tiles = require "tiles"

local Telepad = Cell:extend()
Telepad.name = "Telepad"
Telepad.passable = true
Telepad.opaque = false
Telepad.sightLimit = nil
Telepad.tile = Tiles["circle_1"]
--Telepad.teleport_destination = nil

function Telepad:onAction(level, actor)
  level:moveActor(actor, self.teleport_destination)
end

return Telepad