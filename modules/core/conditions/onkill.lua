local Condition = require("core.condition")

local OnKill = Condition:extend()
OnKill.name = "OnKill"

function OnKill:onKill(level, killer, killed, action) end

OnKill:afterAction(reactions.Die, function(self, level, actor, action)
<<<<<<< HEAD
   local killer = action:getTarget(1)
   self:onKill(level, killer, action.owner, action)
=======
	local killer = action:getTarget(1)
	self:onKill(level, killer, action.owner, action)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end):where(Condition.ownerIsTarget)

return OnKill
