local Condition = require "condition"
local Invisibility = require "conditions.invisibility"
local Tiles = require "tiles"

local MinorInvisibility = Invisibility:extend()
MinorInvisibility.name = "MinorInvisibility"

MinorInvisibility:onAction(actions.Attack,
  function (self, level, actor, action)
    self.damageBonus = "1d6"
  end
)

MinorInvisibility:afterAction(actions.Attack,
  function (self, level, actor, action)
    if action.hit then
      self:breakInvisibility(level, actor)
    end
  end
)

MinorInvisibility:onAction(actions.Zap, MinorInvisibility.breakInvisibility)

function MinorInvisibility:breakInvisibility(level, actor)
  actor:removeCondition(self)
end

function MinorInvisibility:onApply()
  print "WOWEE"
  self.storedChar = self.owner.char
  self.owner.char = Tiles["inivs_player"]
end

function MinorInvisibility:onRemove()
  self.owner.char = self.storedChar
end

return MinorInvisibility
