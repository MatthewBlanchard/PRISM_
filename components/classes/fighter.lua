local Component = require "component"
local Condition = require "condition"
local Action = require "action"

local SecondWindCondition = Condition:extend()
SecondWindCondition.name = "Second Wind"
SecondWindCondition.description = "You center yourself and gain health back over time."

SecondWindCondition:onTick(
  function(self, level, actor)
    local heal = self.owner:getReaction(reactions.Heal)
    level:performAction(heal(actor, {}, 2))
  end
)

local SecondWindTarget = targets.Actor:extend()

function SecondWindTarget:validate(owner, actor)
    return owner == actor
end

-- Action that applies the Second Wind condition to the actor.
local SecondWind = Action:extend()
SecondWind.name = "Second Wind"

function SecondWind:__new(owner, targets)
  Action.__new(self, owner, targets)
end

function SecondWind:perform(level)
  local customSecondWind = SecondWindCondition:extend()
  customSecondWind:setDuration(500)

  self.owner:applyCondition(customSecondWind)
end

-- This component provides the active ability of the Fighter class to the actor
-- it is attached to.
local Fighter = Component:extend()
Fighter.name = "Fighter"
Fighter.description = "A chunky fighter with an active heal."

Fighter.actions = {
    SecondWind
}

function Fighter:__new()
  self.duration = 500
end

function Fighter:initialize(actor)
  local progression_component = actor:getComponent(components.Progression)
  progression_component.classAbility = SecondWind

  actor.ATK = actor.ATK + 1
  actor:applyCondition(conditions.Tough())
end

return Fighter
