local BoundingBox = require "box"
local Component = require "component"

local Collideable = Component:extend()
Collideable.name = "Collideable"

function Collideable:__new(boundingBox)
    if not boundingBox then
        boundingBox = BoundingBox(1)
    end

    -- Stores a list of offsets from the actor's position that are occupied
    -- by this actor. This is used to check for collisions.
    self.boundingBox = boundingBox
end

return Collideable
