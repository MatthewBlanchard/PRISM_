local Actor = require "core.actor"
local Tiles = require "display.tiles"
local Vector2 = require "math.vector"

local actor = Actor:extend()
actor.name = "wall"
actor.char = Tiles["wall_1"]
actor.color = {0.8, 0.5, 0.1, 0}
actor.opaque = true
actor.remembered = true

actor.components = {
  components.Collideable_box(),
}

return actor
