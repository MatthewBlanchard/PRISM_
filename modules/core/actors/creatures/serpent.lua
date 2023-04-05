local Actor = require "core.actor"
local Tiles = require "display.tiles"

local Serpent = Actor:extend()
Serpent.name = "Serpent"
Serpent.char = "S"
Serpent.color = {0.5, 0.5, 0.8}

Serpent.components = {
    components.Collideable_snake(3),
    components.Move{speed = 100},
    components.Sight{range = 5, fov = true, explored = false},
    components.Stats {
        ATK = 0,
        MGK = 3,
        PR = 0,
        MR = 0,
        maxHP = 10,
        AC = 0
    },
    components.Aicontroller(),
}

local actUtil = components.Aicontroller
function Serpent:act(level)
    local target = actUtil.closestSeenActorByFaction(self, "player")

    if target then
        return actUtil.moveToward(self, target)
    end
    
    return actUtil.moveTowardLight(level, self)
end

return Serpent
