local BoundingBox = require "box"
local Collideable = require "components.collideable"
local CollideableBox = require "components.collideable_box"
local CollideableSnake = require "components.collideable_snake"

local CollideableDynamic = Collideable:extend()
CollideableDynamic.name = "CollideableDynamic"

function CollideableDynamic:__new(size)
    assert(size and size > 1, "Dynamic collideable must be at least 2 tiles long, use CollideableBox for 1 tile")
    self.internalCollideable = CollideableBox(size)
    self.boxColiideable = self.internalCollideable
end

function CollideableDynamic:eachCell(actor)
    return self.boxColiideable:eachCell(actor.position)
end

-- given a direction return a list of cells we intend to occupy
function CollideableDynamic:moveCandidate(actor, direction)
    return self.boxColiideable:moveCandidate(actor.position, direction)
end

function CollideableDynamic:acceptedCandidate(actor, direction)
    -- we're not blocked so we can just move
    self.internalCollideable = self.boxColiideable
    self.internalCollideable:acceptedCandidate(actor.position, direction)
end

-- called if our moveCandidate is blocked by another actor or cell
function CollideableDynamic:trySqueeze(actor, direction, rejected)
    -- see if all of our cells were rejected or if there's a gap we can
    -- snake through
    if #rejected > size - 1 then
        -- we can't squeeze, we're blocked
        return nil
    end

    -- we found a gap we can squeeze through so now it's time to create a snake
    -- collideable with the head at the gap and the tail should pull from the 
    -- farthest tile from the gap as if 'pulling a thread' based on the direction
    if math.abs(direction.x) > 0 then
        -- pull the thread in the x direction
        local x = direction.x > 0 and 1 or -1
    elseif math.abs(direction.y) > 0 then
        -- pull the thread in the y direction
        local y = direction.y > 0 and 1 or -1
    end
    
end

return CollideableDynamic
