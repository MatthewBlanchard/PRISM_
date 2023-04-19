local Action = require("core.action")

local Unwield = Action:extend()
Unwield.name = "unwield"
Unwield.targets = { targets.Unwield }

function Unwield:perform(level)
<<<<<<< HEAD
   local weapon = self:getTarget(1)

   local attacker = self.owner:getComponent(components.Attacker)
   attacker.wielded = attacker.defaultAttack

   for k, effect in pairs(weapon.effects) do
      self.owner:removeCondition(effect)
   end
=======
	local weapon = self:getTarget(1)

	local attacker = self.owner:getComponent(components.Attacker)
	attacker.wielded = attacker.defaultAttack

	for k, effect in pairs(weapon.effects) do
		self.owner:removeCondition(effect)
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Unwield
