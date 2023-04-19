local Condition = require("core.condition")

local Webbed = Condition:extend()
Webbed.name = "Webbed"
Webbed.description = "Your movement is 50 slower. Your attacks are 25 slower."

Webbed:onAction(actions.Move, function(self, level, actor, action)
<<<<<<< HEAD
   if actor:rollCheck "PR" >= 13 then
      actor:removeCondition(self)
   else
      action.time = action.time + 50
   end
end)

Webbed:onAction(
   actions.Attack,
   function(self, level, actor, action) action.time = action.time + 25 end
)
=======
	if actor:rollCheck("PR") >= 13 then
		actor:removeCondition(self)
	else
		action.time = action.time + 50
	end
end)

Webbed:onAction(actions.Attack, function(self, level, actor, action)
	action.time = action.time + 25
end)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Webbed
