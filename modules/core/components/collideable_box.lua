local BoundingBox = require "math.collision_bounding_box"
local Collideable = require "modules.core.components.collideable"
local Vector2 = require "math.vector"

local CollideableBox = Collideable:extend()
CollideableBox.name = "CollideableBox"

function CollideableBox:__new(size)
    self.boundingBox = BoundingBox(size or 1)
    self.size = size or 1
end

function CollideableBox:eachCellGlobal(actor)
    return self.boundingBox:eachCell(actor.position)
end

function CollideableBox:eachCell()
    return self.boundingBox:eachCell(Vector2(0, 0))
end

-- given a direction return a list of cells we intend to occupy
function CollideableBox:moveCandidate(level, actor, direction)
    local list = {}

    for vec in self:eachCellGlobal(actor) do
        table.insert(list, vec + direction)
    end

    return function()
        return table.remove(list, 1)
    end
end

function CollideableBox:acceptedCandidate(level, actor, direction)
    -- we don't modify our occupied tiles so we can just return
    return
end

-- called if our moveCandidate is blocked by another actor
function CollideableBox:trySqueeze(level, actor, direction, rejected)
    return nil
end

return CollideableBox
