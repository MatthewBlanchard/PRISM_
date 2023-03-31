local Condition = require "condition"

local OnCrit = Condition:extend()
OnCrit.name = "Oncrit"

function OnCrit:OnCrit(level, attacker, defender, action)
end

OnCrit:afterAction(actions.Attack,
  function(self, level, actor, action)
    local defender = action:getTarget(1)
    if action.crit and defender ~= actor then
      self:OnCrit(level, actor, defender, action)
    end
  end
)

return OnCrit
