local Actor = require("core.actor")
local Action = require("core.action")
local Condition = require("core.condition")
local Tiles = require("display.tiles")

local Drink = actions.Drink:extend()
Drink.name = "drink"
Drink.targets = { targets.Item }

function Drink:perform(level)
<<<<<<< HEAD
   actions.Drink.perform(self, level)
   self.owner:applyCondition(conditions.Focus())
=======
	actions.Drink.perform(self, level)
	self.owner:applyCondition(conditions.Focus())
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

local Potion = Actor:extend()
Potion.name = "Risky Ristretto"
Potion.description =
<<<<<<< HEAD
   "Risky Ristretto, the bold and daring potion that raises the stakes. Savor the rich blend and seize the moment with every critical strike."
=======
	"Risky Ristretto, the bold and daring potion that raises the stakes. Savor the rich blend and seize the moment with every critical strike."
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
Potion.color = { 0.5, 0.5, 0.5, 1 }
Potion.char = Tiles["potion"]

Potion.components = {
<<<<<<< HEAD
   components.Item { stackable = true },
   components.Usable(),
   components.Drinkable { drink = Drink },
   components.Cost(),
=======
	components.Item({ stackable = true }),
	components.Usable(),
	components.Drinkable({ drink = Drink }),
	components.Cost(),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return Potion
