local Condition = require("core.condition")

local Poison = Condition:extend()
Poison.name = "poisoned"
Poison.damage = 1

Poison:setDuration(1000)

Poison:onTick(function(self, level, actor)
<<<<<<< HEAD
   local damage = actor:getReaction(reactions.Damage)(actor, { self.owner }, self.damage)
   level:performAction(damage)
   --level:addEffect(level, effects.PoisonEffect(actor, self.damage))
=======
	local damage = actor:getReaction(reactions.Damage)(actor, { self.owner }, self.damage)
	level:performAction(damage)
	--level:addEffect(level, effects.PoisonEffect(actor, self.damage))
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end)

return Poison
