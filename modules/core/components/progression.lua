local Component = require "core.component"

local Progression = Component:extend()
Progression.name = "Progression"
Progression.requirements = { components.Stats }

Progression.actions = { actions.Level }

function Progression:initialize(actor)
   self.level = 0
   self.classAbility = nil
end

return Progression
