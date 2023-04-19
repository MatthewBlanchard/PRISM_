local Chunk = require "maps.chunk"
local Clipper = require "maps.clipper.clipper"

local tunnel = Chunk:extend()
function tunnel:parameters()
	self.width, self.height = 15, 15
end
function tunnel:shaper(chunk)
	local cx, cy = chunk:get_center()

	local path = chunk:drunkWalk(
		cx,
		cy,
		function(x, y, i, chunk)
			return (i > 10) or (x < 1 or x > chunk.width - 1 or y < 1 or y > chunk.height - 1)
		end
	)

	chunk:clear_path(path)
end
function tunnel:populater(chunk, clipping)
	for i = 1, 1 do
		local x, y
		repeat
			x, y = love.math.random(1, chunk.width - 1) + 1, love.math.random(1, chunk.height - 1) + 1
		until Clipper.PointInPolygon(Clipper.IntPoint(x, y), clipping) == 1
		if love.math.random(0, 1) == 1 then
			chunk:insert_actor("Glowshroom_1", x, y)
		else
			chunk:insert_actor("Glowshroom_2", x, y)
		end
	end
end

return tunnel
