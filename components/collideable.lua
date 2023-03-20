local Component = require "component"

local Collideable = Component:extend()
Collideable.name = "Collideable"

-- when moving should we check for collisions with ourselves?
-- A snake-like collideable might want to block itself, but a cube-like
-- collideable might not.
Collideable.blockSelf = false

function Collideable:__new()
    error("Collideable is an abstract class. Use a subclass like CollideableBox instead.")
end

-- Gets the tiles that can be used to take actions from this actor
-- An ooze might be able to see and attack from all tiles, but a snake
-- might only be able to see from the head. 
function Collideable:getActionTiles(actor)
end

function Collideable:eachCell(actor)
end

-- given a direction return a list of cells we intend to occupy
function Collideable:moveCandidate(actor, direction)
end

-- called if our moveCandidate is accepted so we can update our state
function Collideable:acceptedCandidate(actor, direction)
end

-- called if our moveCandidate is blocked by another actor
function Collideable:trySqueeze(actor, direction, rejected)
end

function Collideable:acceptedSqueeze(actor, direction, rejected)
end

return Collideable
