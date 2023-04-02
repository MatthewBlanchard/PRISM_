local BoundingBox = require "math.bounding_box"
local Collideable = require "modules.core.components.collideable"
local CollideableBox = require "modules.core.components.collideable_box"
local CollideableSnake = require "modules.core.components.collideable_snake"
local Vector2 = require "math.vector"

local CollideableDynamic = Collideable:extend()
CollideableDynamic.name = "CollideableDynamic"

function CollideableDynamic:__new(size)
    assert(size and size >= 2, "Dynamic collideable must be at least 2 tiles long, use CollideableBox for 1 tile")
    self.size = size
    self.internalCollideable = CollideableBox(size)
    self.boxCollideable = self.internalCollideable
end

function CollideableDynamic:eachCellGlobal(actor)
    return self.internalCollideable:eachCellGlobal(actor)
end

function CollideableDynamic:eachCell()
    return self.internalCollideable:eachCell()
end

function CollideableDynamic:moveCandidate(level, actor, direction)
    -- we always try to fit the box first, if we can't then we try to
    -- squeeze into a snake
    return self.boxCollideable:moveCandidate(level, actor, direction)
end

function CollideableDynamic:acceptedCandidate(level, actor, direction)
    -- we're not blocked so we can just move
    self.internalCollideable = self.boxCollideable
    self.internalCollideable:acceptedCandidate(level, actor, direction)
end

function CollideableDynamic:createSnakeSpiral(actor, direction, rejected, accepted)
    -- the first thing we have to do is find the closest cell in our
    -- bounding box to an accepted cell
    local head = nil

    local closest_accepted = nil
    local distant_direction = direction * 1000
    local closestDistance = math.huge
    for _, vec in ipairs(accepted) do
        local distance = vec:getRange("box", distant_direction)
        if distance < closestDistance then
            closest_accepted = vec
            closestDistance = distance
        end
    end

    local closest = nil
    local closestDistance = math.huge
    for vec in self.internalCollideable:eachCellGlobal(actor) do
        local distance = vec:getRange(nil, closest_accepted)
        if distance < closestDistance then
            closest = vec
            closestDistance = distance
        end
    end

    -- now we have to generate a list of tiles that includes each tile in
    -- our bounding box starting at the head and spiraling inward until
    -- all tiles in the bounding box have been included
    local snakeTiles = {}
    local head = self.internalCollideable:globalToLocal(actor, closest)

    local function checkVisited(vec)
        for _, v in ipairs(snakeTiles) do
            if v == vec then
                return true
            end
        end
        return false
    end

    local direction = Vector2(0, 1)
    local curCell = head
    for i = 1, self.size ^ 2 - 1 do
        local cell = curCell + direction
        local hasCell = self.internalCollideable:hasCell(cell)
        local visited = checkVisited(curCell + direction)

        -- if we're at the edge of the box we need to rotate clockwise
        -- until we find a cell that hasn't been visited yet
        while not hasCell or visited do
            direction = direction:rotateClockwise()
            cell = curCell + direction
            hasCell = self.internalCollideable:hasCell(cell)
            visited = checkVisited(curCell + direction)
        end

        print(cell)
        table.push(snakeTiles, cell)
        curCell = cell
    end

    print(head)
    
    local snakeTiles = table.reverse(snakeTiles)
    table.push(snakeTiles, head)

    local found = ROT.Type.Grid:new()
    for _, vec in ipairs(snakeTiles) do
        if found:getCell(vec.x, vec.y) then
            print("DUPLICATE", vec)
        end
        found:setCell(vec.x, vec.y, true)
    end

    local snake_collideable = CollideableSnake.newFromTiles(snakeTiles)
    assert(#snake_collideable.occupiedTile == self.size ^ 2)
    return snake_collideable, self.internalCollideable:localToGlobal(actor, head)
end

-- called if our moveCandidate is blocked by another actor or cell
function CollideableDynamic:trySqueeze(level, actor, direction, rejected, accepted)
    assert(rejected and accepted, "Must provide rejected and accepted cells")
    -- see if all of our cells were rejected or if there's a gap we can
    -- snake through
    if #rejected > self.size - 1 then
        -- we can't squeeze, we're blocked
        return nil
    end

    -- if we're already a snake we can just try to move
    if self.internalCollideable:is(CollideableSnake) then
        print "SKABEET"
        return self.internalCollideable:moveCandidate(level, actor, direction), actor.position + direction
    end

    local snake_collideable, new_origin = self:createSnakeSpiral(actor, direction, rejected, accepted)
    return snake_collideable:moveCandidate(level, {position = new_origin}, direction), new_origin + direction
end

function CollideableDynamic:acceptedSqueeze(level, actor, direction, rejected, accepted)
    print "YEET"
    if not self.internalCollideable:is(CollideableSnake) then
        self.internalCollideable = self:createSnakeSpiral(actor, direction, rejected, accepted)
    end

    local snake_collideable, new_origin = self:trySqueeze(level, actor, direction, rejected, accepted)
    self.internalCollideable:acceptedCandidate(level, {position = new_origin}, direction)
end

return CollideableDynamic
