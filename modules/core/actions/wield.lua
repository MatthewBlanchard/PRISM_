local Action = require("core.action")

local Wield = Action:extend()
Wield.name = "wield"
Wield.targets = { targets.Weapon }

function Wield:perform(level)
<<<<<<< HEAD
   local weapon = self:getTarget(1)

   self.owner:getComponent(components.Attacker).wielded = weapon

   for k, effect in pairs(weapon.effects) do
      self.owner:applyCondition(effect)
   end
=======
	local weapon = self:getTarget(1)

	self.owner:getComponent(components.Attacker).wielded = weapon

	for k, effect in pairs(weapon.effects) do
		self.owner:applyCondition(effect)
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Wield
