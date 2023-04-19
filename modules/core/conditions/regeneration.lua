local Condition = require("core.condition")

local Regeneration = Condition:extend()
Regeneration.name = "regeneration"

Regeneration:onTick(function(self, level, actor)
<<<<<<< HEAD
   local heal = self.owner:getReaction(reactions.Heal)
   level:performAction(heal(actor, { actor }, 1))
=======
	local heal = self.owner:getReaction(reactions.Heal)
	level:performAction(heal(actor, { actor }, 1))
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end)

return Regeneration
