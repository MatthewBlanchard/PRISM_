local Actor = require("core.actor")
local Tiles = require("display.tiles")
local LightColor = require("structures.lighting.lightcolor")

local StationaryTorch = Actor:extend()
StationaryTorch.char = Tiles["stationarytorch"]
StationaryTorch.name = "StationaryTorch"
StationaryTorch.color = { 0.5, 0.5, 0.8 }

StationaryTorch.components = {
<<<<<<< HEAD
   components.Light {
      color = LightColor(14, 14, 24),
   },
=======
	components.Light({
		color = LightColor(14, 14, 24),
	}),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return StationaryTorch
