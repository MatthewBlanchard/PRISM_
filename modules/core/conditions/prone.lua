local Condition = require "core.condition"

local Prone = Condition:extend()
Prone.duration = 150
Prone.name = "prone"

Prone:onAction(
    actions.Move,
    function(self, level, actor, action)
        action.time = action.time + 150
        actor:removeCondition(self)
    end
)

return Prone
