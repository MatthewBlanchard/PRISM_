local ModifyStats = require("modules.core.conditions.modifystats")

local Focus = ModifyStats:extend()
Focus.name = "focus"
Focus:setDuration(1500)
Focus.stats = {
<<<<<<< HEAD
   AC = -1,
}

Focus:onAction(
   actions.Attack,
   function(self, level, actor, action) action.criticalOn = action.criticalOn - 4 end
)
=======
	AC = -1,
}

Focus:onAction(actions.Attack, function(self, level, actor, action)
	action.criticalOn = action.criticalOn - 4
end)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Focus
