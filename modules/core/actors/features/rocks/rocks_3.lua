local Actor = require "core.actor"
local Tiles = require "display.tiles"
local Vector2 = require "math.vector"

local actor = Actor:extend()
actor.name = "rock"
actor.char = Tiles["rocks_3"]
actor.color = { 0.8, 0.5, 0.1, 0 }
actor.remembered = true

actor.components = {
   components.Opaque(),
   components.Collideable_box(),
}

return actor
