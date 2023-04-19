local Condition = require("core.condition")

local FullBellyStats = Condition:extend()
FullBellyStats:setDuration(1000)

<<<<<<< HEAD
function FullBellyStats:getATK() return 2 end
=======
function FullBellyStats:getATK()
	return 2
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

local FullBelly = Condition:extend()
FullBelly.name = "Mid-fight Snack"
FullBelly.description = "Take a quick bite to gain +2 ATK for 10 seconds. You eat a little faster."

FullBelly:onAction(actions.Eat, function(self, level, actor, action)
<<<<<<< HEAD
   action.time = action.time - 25
   action.owner:applyCondition(FullBellyStats())
=======
	action.time = action.time - 25
	action.owner:applyCondition(FullBellyStats())
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end)

return FullBelly
