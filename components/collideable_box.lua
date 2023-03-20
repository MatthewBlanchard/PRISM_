local BoundingBox = require "box"
local Collideable = require "components.collideable"

local CollideableBox = Collideable:extend()
CollideableBox.name = "CollideableBox"

function CollideableBox:__new(size)
    self.boundingBox = BoundingBox(size or 1)
end

function CollideableBox:eachCell(actor)
    return self.boundingBox:eachCell(actor.position)
end

-- given a direction return a list of cells we intend to occupy
function CollideableBox:moveCandidate(actor, direction)
    local list = {}

    for vec in self:eachCell(actor) do
        table.insert(list, vec + direction)
    end

    return function()
        return table.remove(list, 1)
    end
end

-- called if our moveCandidate is blocked by another actor
function CollideableBox:trySqueeze(actor, direction, rejected)
    return nil
end

return CollideableBox
