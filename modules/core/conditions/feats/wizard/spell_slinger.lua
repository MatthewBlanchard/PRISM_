local Condition = require("core.condition")

local ChemicalCuriosity = Condition:extend()
ChemicalCuriosity.name = "Spell Slinger"
ChemicalCuriosity.description = "You zap faster and your magic attacks are more likely to hit!"

<<<<<<< HEAD
ChemicalCuriosity:onAction(
   actions.Zap,
   function(self, level, actor, action) action.time = action.time - 25 end
)

ChemicalCuriosity:onAction(actions.Attack, function(self, level, actor, action)
   if action.weapon.stat ~= "MGK" then return end

   action.attackBonus = action.attackBonus + 2
=======
ChemicalCuriosity:onAction(actions.Zap, function(self, level, actor, action)
	action.time = action.time - 25
end)

ChemicalCuriosity:onAction(actions.Attack, function(self, level, actor, action)
	if action.weapon.stat ~= "MGK" then
		return
	end

	action.attackBonus = action.attackBonus + 2
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end)

return ChemicalCuriosity
