local Actor = require("core.actor")
local Tiles = require("display.tiles")
local Vector2 = require("math.vector")

local actor = Actor:extend()
actor.name = "rock"
actor.char = Tiles["rocks_1"]
actor.color = { 0.8, 0.5, 0.1, 0 }
actor.remembered = true

actor.components = {
<<<<<<< HEAD
   components.Opaque(),
   components.Collideable_box(),
=======
	components.Opaque(),
	components.Collideable_box(),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return actor
