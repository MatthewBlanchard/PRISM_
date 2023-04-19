local Component = require("core.component")
local SparseGrid = require("structures.sparsegrid")

local Sight = Component:extend()
Sight.name = "Sight"

function Sight:__new(options)
	self.range = options.range
	self.fov = options.fov

	-- explored tracks tiles that have been seen by the player
	self.explored = options.explored

	-- remembered actors that have been seen by the player
	self.rememberedActors = SparseGrid()

	if options.darkvision and math.floor(options.darkvision) ~= options.darkvision then
		error("Darkvision must be an integer")
	end

	self.darkvision = options.darkvision or 8
end

function Sight:initialize(actor)
	self.seenActors = {}
	self.scryActors = {}

	if self.fov then
		self.fov = SparseGrid()
		self.raw_fov = SparseGrid()
		if self.explored then
			self.explored = SparseGrid()
		end
	end
end

function Sight:getRevealedActors()
	return self.seenActors
end

function Sight:setCellExplored(x, y, explored)
	self.explored:set(x, y, explored)
end

function Sight:getFOVCell(x, y)
	return self.fov:get(x, y)
end

function Sight:setFOVCell(x, y, value)
	self.fov:set(x, y, value)
end

function Sight:getRawFOVCell(x, y)
	return self.raw_fov:get(x, y)
end

function Sight:setRawFOVCell(x, y, value)
	self.raw_fov:set(x, y, value)
end

return Sight
