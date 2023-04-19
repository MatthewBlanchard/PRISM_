<<<<<<< HEAD
local Actor = require "core.actor"
local Tiles = require "display.tiles"
local Vector2 = require "math.vector"
local LightColor = require "structures.lighting.lightcolor"
=======
local Actor = require("core.actor")
local Tiles = require("display.tiles")
local Vector2 = require("math.vector")
local LightColor = require("structures.lighting.lightcolor")
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

local Crystal = Actor:extend()
Crystal.name = "crystal"
Crystal.char = Tiles["crystal_1"]
Crystal.color = { 1, 1, 1, 1 }

Crystal.components = {
<<<<<<< HEAD
   --components.Opaque(),
   components.Collideable_box(),
   components.Stats {
      maxHP = 10,
      AC = 0,
   },
   components.Light {
      color = LightColor(31, 31, 31),
      falloff = 0.7,
   },
=======
	--components.Opaque(),
	components.Collideable_box(),
	components.Stats({
		maxHP = 10,
		AC = 0,
	}),
	components.Light({
		color = LightColor(31, 31, 31),
		falloff = 0.7,
	}),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return Crystal
