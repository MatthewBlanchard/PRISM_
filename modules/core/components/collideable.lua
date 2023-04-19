local Component = require("core.component")

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
function Collideable:getActionTiles(actor) end

function Collideable:eachCellGlobal(actor)
	error("eachCellGlobal must be implemented by a subclass")
end

function Collideable:eachCell()
	error("eachCell must be implemented by a subclass")
end

function Collideable:localToGlobal(actor, localPos)
	return actor.position + localPos
end

function Collideable:globalToLocal(actor, globalPos)
	return globalPos - actor.position
end

function Collideable:hasCell(cell)
	for vec in self:eachCell() do
		if vec == cell then
			return true
		end
	end

	return false
end

function Collideable:hasGlobalCell(actor, cell)
	return self:hasCell(actor, cell)
end

-- given a direction return a list of cells we intend to occupy
function Collideable:moveCandidate(level, actor, direction)
	error("moveCandidate must be implemented by a subclass")
end

-- called if our moveCandidate is accepted so we can update our state
function Collideable:acceptedCandidate(level, actor, direction)
	error("acceptedCandidate must be implemented by a subclass")
end

-- called if our moveCandidate is blocked by another actor
function Collideable:trySqueeze(level, actor, direction, rejected, accepted) end

function Collideable:acceptedSqueeze(level, actor, direction, rejected, accepted) end

return Collideable
