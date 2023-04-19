local System = require("core.system")

local LoseCondition = System:extend()
LoseCondition.name = "LoseCondition"

function LoseCondition:afterAction(level, actor, action)
<<<<<<< HEAD
   if action:is(reactions.Die) and actor:is(actors.Player) then level:quit() end
=======
	if action:is(reactions.Die) and actor:is(actors.Player) then
		level:quit()
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return LoseCondition
