local Condition = require("core.condition")

local OnAttack = Condition:extend()
OnAttack.name = "OnAttack"

function OnAttack:onAttack(level, attacker, defender, action) end

OnAttack:afterAction(actions.Attack, function(self, level, actor, action)
<<<<<<< HEAD
   local defender = action:getTarget(1)
   if defender ~= actor then self:onAttack(level, actor, defender, action) end
=======
	local defender = action:getTarget(1)
	if defender ~= actor then
		self:onAttack(level, actor, defender, action)
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end)

return OnAttack
