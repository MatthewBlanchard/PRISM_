local Actor = require "core.actor"
local Vector2 = require "math.vector"
local Tiles = require "display.tiles"

local Gazer = Actor:extend()

Gazer.char = Tiles["gazer"]
Gazer.name = "gazer"
Gazer.color = { 0.8, 0.8, 0.8 }

Gazer.components = {
   components.Collideable_box(),
   components.Sight { range = 8, fov = true, explored = false },
   components.Move { speed = 115 },
   components.Stats {
      ATK = 0,
      MGK = 3,
      PR = 0,
      MR = 0,
      maxHP = 7,
      AC = 3,
   },
   components.Aicontroller(),
   components.Realitydistortion(),
   components.Animated(),
}

local actUtil = components.Aicontroller
function Gazer:act(level) return actUtil.randomMove(level, self) end

return Gazer
