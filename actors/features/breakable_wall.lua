local Actor = require "actor"
local Tiles = require "tiles"
local Vector2 = require "vector"


local actor = Actor:extend()
actor.name = "wall"
actor.char = Tiles["wall_2"]
actor.color = {0.8, 0.5, 0.1, 1}
actor.opaque = true

actor.components = {
  components.Collideable_box(),
  components.Stats{
    maxHP = 1,
    AC = 0
  }
}

return actor
