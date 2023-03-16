local Condition = require "condition"

local Sneaky = Condition:extend()
Sneaky.name = "Sneaky"
Sneaky.description = "You have better darkvision and move slightly faster."

function Sneaky:modifyDarkvision(level, actor, darkvision)
  return math.max(darkvision - 0.1, 0)
end

Sneaky:setTime(actions.Move,
  function(self, level, actor, action)
    print "SKEET YEET KREET"
    action.time = action.time - 10
  end
)

return Sneaky
