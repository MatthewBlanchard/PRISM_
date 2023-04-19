local Condition = require("core.condition")

local ChemicalCuriosity = Condition:extend()
ChemicalCuriosity.name = "Chemical Curiosity"
ChemicalCuriosity.description = "When you drink a potion each of your wands gains a charge."

ChemicalCuriosity:onAction(actions.Drink, function(self, level, actor, action)
<<<<<<< HEAD
   local inventory_component = actor:getComponent(components.Inventory)
   for k, v in pairs(inventory_component.inventory) do
      if v:hasComponent(components.Wand) then v:modifyCharges(1) end
   end
=======
	local inventory_component = actor:getComponent(components.Inventory)
	for k, v in pairs(inventory_component.inventory) do
		if v:hasComponent(components.Wand) then
			v:modifyCharges(1)
		end
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end)

return ChemicalCuriosity
