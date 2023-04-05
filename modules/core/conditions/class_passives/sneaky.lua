local Condition = require "core.condition"

local Sneaky = Condition:extend()
Sneaky.name = "Sneaky"
Sneaky.description = "You have better darkvision and move slightly faster."

function Sneaky:modifyDarkvision(level, actor, darkvision)
  return math.max(darkvision - 2, 0)
end

Sneaky:setTime(actions.Move,
  function(self, level, actor, action)
    action.time = action.time - 10
  end
)

return Sneaky
