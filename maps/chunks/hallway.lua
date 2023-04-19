<<<<<<< HEAD
local Chunk = require "maps.chunk"
=======
local Chunk = require("maps.chunk")
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

local Hallway = Chunk:extend()

function Hallway:parameters()
<<<<<<< HEAD
   self.width = 40
   self.height = 40
end

function Hallway:shaper(chunk) chunk:tunneler(1, 1, 3, 0.1, 30) end
=======
	self.width = 40
	self.height = 40
end

function Hallway:shaper(chunk)
	chunk:tunneler(1, 1, 3, 0.1, 30)
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

function Hallway:populater(chunk, clipping) end

return Hallway
