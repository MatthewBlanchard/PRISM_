local Condition = require("core.condition")

local GoodLooking = Condition:extend()
GoodLooking.name = "Good Lookin'"
<<<<<<< HEAD
GoodLooking.description =
   "You got such a pretty face your opponents wouldn't want to ruin it. You get +2 AC."

function GoodLooking:getAC() return 2 end
=======
GoodLooking.description = "You got such a pretty face your opponents wouldn't want to ruin it. You get +2 AC."

function GoodLooking:getAC()
	return 2
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return GoodLooking
