local Action = require("core.action")

local Equip = Action:extend()
Equip.name = "equip"
Equip.targets = { targets.Equipment }

function Equip:perform(level)
<<<<<<< HEAD
   local equipper_component = self.owner:getComponent(components.Equipper)
   local equipment_component = self:getTarget(1):getComponent(components.Equipment)

   equipment_component.equipper = self.owner
   equipper_component:setSlot(equipment_component.slot, self:getTarget(1))

   for k, effect in pairs(equipment_component.effects) do
      self.owner:applyCondition(effect)
   end
=======
	local equipper_component = self.owner:getComponent(components.Equipper)
	local equipment_component = self:getTarget(1):getComponent(components.Equipment)

	equipment_component.equipper = self.owner
	equipper_component:setSlot(equipment_component.slot, self:getTarget(1))

	for k, effect in pairs(equipment_component.effects) do
		self.owner:applyCondition(effect)
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Equip
