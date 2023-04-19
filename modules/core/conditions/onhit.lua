local Condition = require("core.condition")

local OnHit = Condition:extend()
OnHit.name = "OnHit"

function OnHit:onHit(level, attacker, defender, action) end

OnHit:afterAction(actions.Attack, function(self, level, actor, action)
<<<<<<< HEAD
   local defender = action:getTarget(1)
   if action.hit and defender ~= actor then self:onHit(level, actor, defender, action) end
=======
	local defender = action:getTarget(1)
	if action.hit and defender ~= actor then
		self:onHit(level, actor, defender, action)
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end)

return OnHit
