local Actor = require "core.actor"
local Tiles = require "display.tiles"

local actor = Actor:extend()
actor.char = Tiles["water"]
actor.name = "Water"
actor.color = { 0.0, 0.0, 1.0, 1 }

actor.components = {}

return actor
