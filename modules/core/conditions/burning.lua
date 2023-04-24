local Condition = require "core.condition"
local Tiles = require "display.tiles"

local Burning = Condition:extend()
Burning.name = "burning"
Burning.damage = 1

Burning:setDuration(1000)

Burning:onTick(function(self, level, actor)
   local damage = actor:getReaction(reactions.Damage)(actor, { self.owner }, self.damage)
   level:performAction(damage)
end)

Burning:afterAction(actions.Move, function(self, level, actor, action)
  local position = actor:getPosition()
  local cell = level:getCell(position.x, position.y)

  if cell:is(cells.Water) then
    actor:removeCondition(self)
    level:getSystem("Effects"):addEffect(
       level,
       effects.Character(position.x, position.y, Tiles["poof"], { 0.8, 0.8, 0.8 }, 0.5)
    )
  end
end)

return Burning
