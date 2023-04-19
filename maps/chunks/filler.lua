<<<<<<< HEAD
local Chunk = require "maps.chunk"

local filler = Chunk:extend()
function filler:parameters()
   self.width = love.math.random(4, 10)
   self.height = love.math.random(4, 10)
=======
local Chunk = require("maps.chunk")

local filler = Chunk:extend()
function filler:parameters()
	self.width = love.math.random(4, 10)
	self.height = love.math.random(4, 10)
end
function filler:shaper(chunk)
	chunk:clear_rect(1, 1, chunk.width - 1, chunk.height - 1)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end
function filler:shaper(chunk) chunk:clear_rect(1, 1, chunk.width - 1, chunk.height - 1) end
function filler:populater(chunk, clipping)
<<<<<<< HEAD
   local cx, cy = chunk:get_center()
   --chunk:insert_actor('Sqeeto', cx, cy)
=======
	local cx, cy = chunk:get_center()
	--chunk:insert_actor('Sqeeto', cx, cy)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return filler
