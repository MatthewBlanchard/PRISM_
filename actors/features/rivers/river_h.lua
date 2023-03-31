local Actor = require "actor"
local Tiles = require "tiles"

local River = Actor:extend()
River.char = Tiles["river_h_1"]
River.name = "river"
River.color = { 0.0, 0.0, 1.0, 1}
River.remembered = true

River.components = {
  components.Animated{
      sheet = {Tiles["river_h_1"], Tiles["river_h_2"]}
    },
}

return River