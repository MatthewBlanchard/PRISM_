local Condition = require "core.condition"

local Finesse = Condition:extend()
Finesse.name = "Fast Hands"
Finesse.description = "Your hands are dangerously fast. The faster your attack the more damage!"

Finesse:onAction(
	actions.Attack,
	function(self, level, actor, action)
		action.bonusDamage = math.min(5, math.max(0, 25 / action.speed) * 5)
	end
)

return Finesse
