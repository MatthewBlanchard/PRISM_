local Actor = require("core.actor")
local Tiles = require("display.tiles")
local LightColor = require("structures.lighting.lightcolor")

local Glowshroom = Actor:extend()
Glowshroom.char = Tiles["mushroom_1"]
Glowshroom.name = "Glowshroom"
Glowshroom.color = { 0.5, 0.9, 0.5, 1 }

Glowshroom.components = {
<<<<<<< HEAD
   components.Light {
      color = LightColor(8, 22, 10),
      falloff = 0.7,
   },
=======
	components.Light({
		color = LightColor(8, 22, 10),
		falloff = 0.7,
	}),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return Glowshroom
