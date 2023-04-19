local Actor = require("core.actor")
local Action = require("core.action")
local Tiles = require("display.tiles")

local Arrow = Actor:extend()
Arrow.name = "arrow"
Arrow.char = Tiles["arrow"]
Arrow.color = { 0.8, 0.5, 0.1, 1 }

Arrow.components = {
<<<<<<< HEAD
   components.Item { stackable = true },
=======
	components.Item({ stackable = true }),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return Arrow
