local Condition = require "condition"

local Tough = Condition:extend()
Tough.name = "Tough"
Tough.description = "You gain 2 additional max HP when you gaze upon a prism."

function Tough:getMaxHP()
  return self.owner.level * 2
end

return Tough
