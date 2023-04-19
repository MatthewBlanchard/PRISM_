local Chunk = require "maps.chunk"

local filler = Chunk:extend()
function filler:parameters()
	self.width = love.math.random(4, 10)
	self.height = love.math.random(4, 10)
end
function filler:shaper(chunk) chunk:clear_rect(1, 1, chunk.width - 1, chunk.height - 1) end
function filler:populater(chunk, clipping)
	local cx, cy = chunk:get_center()
	--chunk:insert_actor('Sqeeto', cx, cy)
end

return filler
