local Chunk = require "maps.chunk"

local SmallRoom = Chunk:extend()

function SmallRoom:parameters()
	self.width = love.math.random(4, 7)
	self.height = love.math.random(4, 7)
end

function SmallRoom:shaper(chunk) chunk:clear_rect(1, 1, chunk.width - 1, chunk.height - 1) end

function SmallRoom:populater(chunk, clipping)
	local cx, cy = chunk:get_center()
	--chunk:insert_actor('Sqeeto', cx, cy)
end

return SmallRoom
