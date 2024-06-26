local Actor = require "core.actor"
local Tiles = require "display.tiles"
local Vector2 = require "math.vector"

local Box = Actor:extend()
Box.name = "box"
Box.speed = 0
Box.char = Tiles["box"]
Box.color = { 0.8, 0.5, 0.1, 1 }

Box.components = {
   components.Collideable_box(),
   components.Move { speed = 0 },
   components.Usable(),
   components.Pushable(),
   components.Stats {
      maxHP = 1,
      AC = 0,
   },
   components.Light_occluder(3),
}

return Box
