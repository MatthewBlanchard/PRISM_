local Actor = require "actor"
local Tiles = require "tiles"

local actor = Actor:extend()
actor.char = Tiles["web"]
actor.name = "Web"
actor.color = { 1.0, 1.0, 1.0, 1}

actor.components = {}

return actor