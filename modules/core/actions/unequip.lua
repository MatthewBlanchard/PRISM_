local Action = require("core.action")

local Unequip = Action:extend()
Unequip.name = "unequip"
Unequip.targets = { targets.Unequip }

function Unequip:perform(level)
<<<<<<< HEAD
   local equipment = self:getTarget(1):getComponent(components.Equipment)
   local equipper = self.owner:getComponent(components.Equipper)

   equipment.equipper = nil
   equipper.slots[equipment.slot] = false

   for k, effect in pairs(equipment.effects) do
      self.owner:removeCondition(effect)
   end
=======
	local equipment = self:getTarget(1):getComponent(components.Equipment)
	local equipper = self.owner:getComponent(components.Equipper)

	equipment.equipper = nil
	equipper.slots[equipment.slot] = false

	for k, effect in pairs(equipment.effects) do
		self.owner:removeCondition(effect)
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Unequip
