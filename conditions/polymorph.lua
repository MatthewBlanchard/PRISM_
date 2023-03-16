local Condition = require "condition"
local Vector2 = require "vector"

local Polymorph = Condition:extend()
Polymorph.name = "mind control"

function Polymorph:__new(actor)
    self.untransform_target = actor
end

function Polymorph:overrideController(level, actor)
    return components.Controller
end

function Polymorph:onDurationEnd(level, actor)
    local owner_pos = self.owner.position

    level:removeActor(self.owner)
    level:addActor(self.untransform_target)
    level:moveActor(self.untransform_target, Vector2(owner_pos.x, owner_pos.y))
end

return Polymorph
