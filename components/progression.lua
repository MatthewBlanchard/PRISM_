local Component = require "component"

local Progression = Component:extend()
Progression.name = "Progression"
Progression.requirements = {components.Stats}

Progression.actions = {actions.Level}

function Progression:initialize(actor)
  actor.level = 1
  actor.class = nil
  actor.feats = {}
end

function Progression:setClass(actor, class_enum)
  actor.class = class_enum
end

return Progression
