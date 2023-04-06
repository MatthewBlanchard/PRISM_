local Collideable = require "modules.core.components.collideable"
local Vector2 = require "math.vector"

local CollideableSnake = Collideable:extend()
CollideableSnake.name = "CollideableSnake"
CollideableSnake.blockSelf = false

function CollideableSnake:__new(length)
    assert(length > 1, "Snake must be at least 2 tiles long, use CollideableBox for 1 tile")

    self.occupiedTile = {}

    for i = 0, length - 1 do
        local u = length - i - 1
        table.push(self.occupiedTile, Vector2(0, u))
    end
end

function CollideableSnake.newFromTiles(tiles)
    local self = CollideableSnake(#tiles)
    self.occupiedTile = tiles

    return self
end

function CollideableSnake:eachCellGlobal(actor)
    local i = 0
    return function()
        i = i + 1
        if i > #self.occupiedTile then
            return nil
        end

        return self.occupiedTile[i] + actor.position
    end
end

function CollideableSnake:eachCell()
    local i = 0
    return function()
        i = i + 1
        if i > #self.occupiedTile then
            return nil
        end

        return self.occupiedTile[i]
    end
end

-- given a direction return a list of cells we intend to occupy
function CollideableSnake:moveCandidate(level, actor, direction)
    local list = {}

    for i = 2, #self.occupiedTile do
        table.push(list, self.occupiedTile[i] + actor.position)
    end

    -- the snakes head should always be at 0,0 in local space
    table.push(list, Vector2(0, 0) + actor.position + direction)

    return function()
        return table.remove(list, 1)
    end
end

function CollideableSnake:acceptedCandidate(level, actor, direction)
    local list = {}

    for i = 2, #self.occupiedTile do
        table.push(list, self.occupiedTile[i] - direction)
    end
    
    -- the snakes head should always be at 0,0 in local space
    table.push(list, Vector2(0, 0))

    self.occupiedTile = list
end

-- called if our moveCandidate is blocked, we can see exactly which tiles
-- are blocked and make an attempt to squeeze through
function CollideableSnake:trySqueeze(level, actor, direction, rejected)
    return nil
end

return CollideableSnake
