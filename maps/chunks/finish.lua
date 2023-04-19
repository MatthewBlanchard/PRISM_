<<<<<<< HEAD
local Chunk = require "maps.chunk"

local finish = Chunk:extend()
function finish:parameters()
   self.width, self.height = 4, 4
=======
local Chunk = require("maps.chunk")

local finish = Chunk:extend()
function finish:parameters()
	self.width, self.height = 4, 4
end
function finish:shaper(chunk)
	chunk:clear_rect(1, 1, chunk.width - 1, chunk.height - 1)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end
function finish:shaper(chunk) chunk:clear_rect(1, 1, chunk.width - 1, chunk.height - 1) end
function finish:populater(chunk, clipping)
<<<<<<< HEAD
   local cx, cy = chunk:get_center()

   chunk:insert_actor("Stairs", cx, cy)
=======
	local cx, cy = chunk:get_center()

	chunk:insert_actor("Stairs", cx, cy)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return finish
