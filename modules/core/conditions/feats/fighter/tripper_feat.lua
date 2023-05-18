--TODO: remove this, make level up action be capable of adding components as feats

local Condition = require "core.condition"

local TripFeatCondition = Condition:extend()

function TripFeatCondition:onApply()
    self.owner:addComponent(components.Tripper)
end

function TripFeatCondition:onRemove()
    self.owner:removeCondition(components.Tripper)
end

return TripFeatCondition
