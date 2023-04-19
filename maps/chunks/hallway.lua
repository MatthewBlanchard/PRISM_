local Chunk = require("maps.chunk")

local Hallway = Chunk:extend()

function Hallway:parameters()
	self.width = 40
	self.height = 40
end

function Hallway:shaper(chunk)
	chunk:tunneler(1, 1, 3, 0.1, 30)
end

function Hallway:populater(chunk, clipping) end

return Hallway
