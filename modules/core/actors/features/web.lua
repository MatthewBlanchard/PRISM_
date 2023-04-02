local Actor = require "core.actor"
local Tiles = require "display.tiles"

local actor = Actor:extend()
actor.char = Tiles["web"]
actor.name = "Web"
actor.color = { 1.0, 1.0, 1.0, 1}

actor.components = {}

return actor