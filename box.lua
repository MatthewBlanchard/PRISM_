local Object = require "Object"

local BoundingBox = Object:extend()

function BoundingBox:__new(size)
    self.size = size
end

-- This is an iterator that returns all tiles that are occupied by this
-- bounding box. The cells are in local space (relative to the actor's
-- position). The iterator returns the x and y coordinates of the cell.
-- The first return should be 0, 0.
function BoundingBox:eachCell(position)
    local x, y = 0, 0

    return function()
        for x = 0, self.size - 1 do
            for y = 0, self.size - 1 do
                return Vector2(x, y) + position
            end
        end
    end
end

return BoundingBox