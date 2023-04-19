<<<<<<< HEAD
local Actor = require "core.actor"
local Tiles = require "display.tiles"
local Vector2 = require "math.vector"
=======
local Actor = require("core.actor")
local Tiles = require("display.tiles")
local Vector2 = require("math.vector")
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

local BreakableWall = Actor:extend()
BreakableWall.name = "wall"
BreakableWall.char = Tiles["wall_2"]
BreakableWall.color = { 0.8, 0.5, 0.1, 1 }
BreakableWall.remembered = true
BreakableWall.tileLighting = true

BreakableWall.components = {
<<<<<<< HEAD
   components.Opaque(),
   components.Collideable_box(),
   components.Stats {
      maxHP = 1,
      AC = 0,
   },
=======
	components.Opaque(),
	components.Collideable_box(),
	components.Stats({
		maxHP = 1,
		AC = 0,
	}),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return BreakableWall
