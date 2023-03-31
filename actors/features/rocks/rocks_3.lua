local Actor = require "actor"
local Tiles = require "tiles"
local Vector2 = require "vector"

local actor = Actor:extend()
actor.name = "rock"
actor.char = Tiles["rocks_3"]
actor.color = {0.8, 0.5, 0.1, 0}
actor.opaque = true
actor.remembered = true

actor.components = {
  components.Collideable_box(),
}

return actor
