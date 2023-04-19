local Action = require "core.action"
local Consume = Action:extend()
Consume.name = "eat"
Consume.targets = { targets.Item }

function Consume:perform(level)
	local consumable = self:getTarget(1)
	level:removeActor(consumable)
end

return Consume
