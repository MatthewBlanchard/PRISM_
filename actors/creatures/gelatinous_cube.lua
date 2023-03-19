local Actor = require "actor"
local Tiles = require "tiles"
local Box = require "box"

local Cube = Actor:extend()
Cube.name = "Cube"
Cube.char = "B"
Cube.color = {0.5, 0.5, 0.8}

Cube.components = {
    components.Collideable_box(2),
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
function Cube:act(level)
    return actUtil.moveTowardLight(level, self)
end

return Cube
