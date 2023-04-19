local Action = require("core.action")
local Consume = require("modules.core.actions.consume")

local Eat = Consume:extend()
Eat.name = "eat"
Eat.targets = { targets.Item }

function Eat:perform(level)
<<<<<<< HEAD
   Consume.perform(self, level)

   local eater = self.owner
   local food = self:getTarget(1):getComponent(components.Edible)
   local heal = self.owner:getReaction(reactions.Heal)
   level:performAction(heal(eater, {}, food.nutrition))
=======
	Consume.perform(self, level)

	local eater = self.owner
	local food = self:getTarget(1):getComponent(components.Edible)
	local heal = self.owner:getReaction(reactions.Heal)
	level:performAction(heal(eater, {}, food.nutrition))
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Eat
