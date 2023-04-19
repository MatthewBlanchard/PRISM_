local Condition = require("core.condition")

local MindControl = Condition:extend()
MindControl.name = "mind control"

MindControl:setDuration(1000)

function MindControl:overrideController(level, actor)
	return components.Controller
end

return MindControl
