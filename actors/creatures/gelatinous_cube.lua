local Actor = require "actor"
local Tiles = require "tiles"
local Box = require "box"

local Cube = Actor:extend()
Cube.name = "Cube"
Cube.char = Tiles["player"]
Cube.color = {0.5, 0.5, 0.8}

Cube.components = {
    components.Collideable_dynamic(2),
    components.Move{speed = 100},
    components.Sight{range = 5, fov = true, explored = false},
    components.Stats {
        ATK = 0,
        MGK = 0,
        PR = 0,
        MR = 0,
        maxHP = 10,
        AC = 0
    },
    components.Aicontroller(),
}

local actUtil = components.Aicontroller
function Cube:act(level)
    local target = actUtil.closestSeenActorByFaction(self, "player")

    if target then
        return actUtil.moveTowardSimple(self, target)
    end

    return self:getAction(actions.Wait)(self)
end

return Cube
