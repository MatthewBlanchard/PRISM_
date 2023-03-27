local Actor = require "actor"
local Tiles = require "tiles"

local actor = Actor:extend()
actor.char = Tiles["river_v_1"]
actor.name = "river"
actor.color = { 0.0, 0.0, 1.0, 1}

actor.components = {
  components.Animated{
      sheet = {Tiles["river_v_1"], Tiles["river_v_2"]}
    },
}

return actor