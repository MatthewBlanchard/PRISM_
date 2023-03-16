local Component = require "component"
local Action = require "action"
local MinorInvisibility = require "conditions.minor_invisibility"

-- Action that applies the Second Wind condition to the actor.
local BecomeInvisible = Action:extend()
BecomeInvisible.name = "Second Wind"

function BecomeInvisible:__new(owner, targets)
  Action.__new(self, owner, targets)
end

function BecomeInvisible:perform(level)
  local customMinorInvisibility = MinorInvisibility:extend()
  customMinorInvisibility:setDuration(500)

  self.owner:applyCondition(customMinorInvisibility)
end

-- This component provides the active ability of the Rogue class to the actor
-- it is attached to.
local Rogue = Component:extend()
Rogue.name = "Rogue"
Rogue.description = "A sneaky guy who moves fast and can turn invisible."

Rogue.actions = {
    BecomeInvisible
}

function Rogue:initialize(actor)
  local progression_component = actor:getComponent(components.Progression)
  progression_component.classAbility = BecomeInvisible

  actor.ATK = actor.ATK + 1
  actor:applyCondition(conditions.Sneaky())
end

return Rogue
