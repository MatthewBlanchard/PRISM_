local Actor = require "core.actor"
local Tiles = require "display.tiles"
local Vector2 = require "math.vector"


local BreakableWall = Actor:extend()
BreakableWall.name = "wall"
BreakableWall.char = Tiles["wall_2"]
BreakableWall.color = {0.8, 0.5, 0.1, 1}
BreakableWall.remembered = true
BreakableWall.tileLighting = true

BreakableWall.components = {
  components.Opaque(),
  components.Collideable_box(),
  components.Stats{
    maxHP = 1,
    AC = 0
  }
}

return BreakableWall
