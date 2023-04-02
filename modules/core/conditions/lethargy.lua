local Condition = require "core.condition"

local Lethargy = Condition:extend()
Lethargy.duration = 1000
Lethargy.name = "lethargy"

Lethargy:onAction(actions.Move,
  function(self, level, actor, action)
    action.time = action.time * 4
  end
)

return Lethargy
