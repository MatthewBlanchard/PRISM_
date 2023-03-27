local Actor = require "actor"
local Tiles = require "tiles"

local actor = Actor:extend()
actor.char = Tiles["bridge_h"]
actor.name = "bridge"
actor.color = { 128/255, 64/255, 0/255, 1}

actor.components = {}

return actor