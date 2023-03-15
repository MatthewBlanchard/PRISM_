local Condition = require "condition"
local Invisibility = require "conditions.invisibility"

local MinorInvisibility = Invisibility:extend()
MinorInvisibility.name = "MinorInvisibility"

MinorInvisibility:onAction(actions.Attack, MinorInvisibility.breakInvisibility)
MinorInvisibility:onAction(actions.Zap, MinorInvisibility.breakInvisibility)

function MinorInvisibility:breakInvisibility(level, actor)
  actor:removeCondition(self)
end

return MinorInvisibility
