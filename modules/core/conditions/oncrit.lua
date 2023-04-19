local Condition = require("core.condition")

local OnCrit = Condition:extend()
OnCrit.name = "Oncrit"

function OnCrit:OnCrit(level, attacker, defender, action) end

OnCrit:afterAction(actions.Attack, function(self, level, actor, action)
<<<<<<< HEAD
   local defender = action:getTarget(1)
   if action.crit and defender ~= actor then self:OnCrit(level, actor, defender, action) end
=======
	local defender = action:getTarget(1)
	if action.crit and defender ~= actor then
		self:OnCrit(level, actor, defender, action)
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end)

return OnCrit
