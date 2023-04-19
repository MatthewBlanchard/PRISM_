local Condition = require("core.condition")

local MindControl = Condition:extend()
MindControl.name = "mind control"

MindControl:setDuration(1000)

<<<<<<< HEAD
function MindControl:overrideController(level, actor) return components.Controller end
=======
function MindControl:overrideController(level, actor)
	return components.Controller
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return MindControl
