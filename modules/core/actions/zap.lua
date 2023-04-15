local Action = require "core.action"

local Zap = Action:extend()
Zap.name = "zap"
Zap.targets = {targets.Item}

function Zap:perform(level, suppressEffects)
  local wand = self.targetActors[1]
  wand:modifyCharges(-1)

  if self:getTarget(2) and not suppressEffects then
    local effectPos = self:getTarget(2).position or self:getTarget(2)
    level:getSystem("Effects"):addEffect(level, effects.Zap(wand, self.owner, effectPos))
  end
end

return Zap
