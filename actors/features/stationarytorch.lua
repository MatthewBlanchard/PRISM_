local Actor = require "actor"
local Tiles = require "tiles"
local LightColor = require "lighting.lightcolor"

local StationaryTorch = Actor:extend()
StationaryTorch.char = Tiles["stationarytorch"]
StationaryTorch.name = "StationaryTorch"
StationaryTorch.color = {0.5, 0.5, 0.8}

StationaryTorch.components = {
  components.Light{
    color = LightColor(14, 14, 24),
  }
}

return StationaryTorch
