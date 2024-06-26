local Actor = require "core.actor"
local Action = require "core.action"
local Condition = require "core.condition"
local Tiles = require "display.tiles"

local Drink = actions.Drink:extend()
Drink.name = "drink"
Drink.targets = { targets.Item }

function Drink:perform(level)
   actions.Drink.perform(self, level)
   self.owner:applyCondition(conditions.Focus())
end

local Potion = Actor:extend()
Potion.name = "Risky Ristretto"
Potion.description =
   "Risky Ristretto, the bold and daring potion that raises the stakes. Savor the rich blend and seize the moment with every critical strike."
Potion.color = { 0.5, 0.5, 0.5, 1 }
Potion.char = Tiles["potion"]

Potion.components = {
   components.Item { stackable = true },
   components.Usable(),
   components.Drinkable { drink = Drink },
   components.Cost(),
}

return Potion
