local Actor = require("core.actor")
local Tiles = require("display.tiles")

local Shopkeep = Actor:extend()
Shopkeep.name = "Shopkeep"
Shopkeep.char = Tiles["shop_1"]
Shopkeep.color = { 0.5, 0.5, 0.8 }

Shopkeep.components = {
<<<<<<< HEAD
   components.Collideable_box(),
=======
	components.Collideable_box(),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return Shopkeep
