local Actor = require "actor"
local Tiles = require "tiles"
local Vector2 = require "vector"


local BreakableWall = Actor:extend()
BreakableWall.name = "wall"
BreakableWall.char = Tiles["wall_2"]
BreakableWall.color = {0.8, 0.5, 0.1, 1}
BreakableWall.opaque = true
BreakableWall.remembered = true

BreakableWall.components = {
  components.Collideable_box(),
  components.Stats{
    maxHP = 1,
    AC = 0
  }
}

return BreakableWall
