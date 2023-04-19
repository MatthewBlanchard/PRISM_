local Actor = require("core.actor")
local Tiles = require("display.tiles")

local River = Actor:extend()
River.char = Tiles["river_h_1"]
River.name = "river"
River.color = { 0.0, 0.0, 1.0, 1 }
River.remembered = true

River.components = {
<<<<<<< HEAD
   components.Animated {
      sheet = { Tiles["river_h_1"], Tiles["river_h_2"] },
   },
=======
	components.Animated({
		sheet = { Tiles["river_h_1"], Tiles["river_h_2"] },
	}),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return River
