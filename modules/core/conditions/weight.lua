local ModifyStats = require("modules.core.conditions.modifystats")

local Weight = ModifyStats:extend()
Weight.name = "weight"
Weight:setDuration(1500)
Weight.stats = {
<<<<<<< HEAD
   AC = 3,
}

Weight:onAction(
   actions.Move,
   function(self, level, actor, action) action.time = action.time * 1.25 end
)
=======
	AC = 3,
}

Weight:onAction(actions.Move, function(self, level, actor, action)
	action.time = action.time * 1.25
end)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Weight
