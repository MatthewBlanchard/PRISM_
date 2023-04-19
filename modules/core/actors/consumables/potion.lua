local Actor = require("core.actor")
local Action = require("core.action")
local Condition = require("core.condition")
local Tiles = require("display.tiles")
local LightColor = require("structures.lighting.lightcolor")

local Drink = actions.Drink:extend()
Drink.name = "drink"
Drink.targets = { targets.Item }

function Drink:perform(level)
<<<<<<< HEAD
   actions.Drink.perform(self, level)

   local heal = self.owner:getReaction(reactions.Heal)
   level:performAction(heal(self.owner, {}, 5))
=======
	actions.Drink.perform(self, level)

	local heal = self.owner:getReaction(reactions.Heal)
	level:performAction(heal(self.owner, {}, 5))
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

local Potion = Actor:extend()
Potion.name = "Potion of Healing"
Potion.description = "Heals you for 5 HP."
Potion.color = { 1, 0, 0, 1 }
Potion.emissive = true
Potion.char = Tiles["potion"]
--Potion.lightEffect = components.Light.effects.pulse({ 0.3, 0.0, 0.0, 1 }, 3, .5)

Potion.components = {
<<<<<<< HEAD
   components.Light {
      color = LightColor(16, 0, 0),
      effect = Potion.lightEffect,
   },
   components.Item { stackable = true },
   components.Usable(),
   components.Drinkable { drink = Drink },
   components.Cost(),
=======
	components.Light({
		color = LightColor(16, 0, 0),
		effect = Potion.lightEffect,
	}),
	components.Item({ stackable = true }),
	components.Usable(),
	components.Drinkable({ drink = Drink }),
	components.Cost(),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return Potion
