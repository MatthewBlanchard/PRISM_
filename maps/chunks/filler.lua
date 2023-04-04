local Chunk = require 'maps.chunk'

local filler = Chunk:extend()
function filler:parameters()
  self.width = love.math.random(3, 3)
  self.height = love.math.random(3, 3)
end
function filler:shaper(chunk)
  chunk:clear_rect(0,0, chunk.width, chunk.height)
end
function filler:populater(chunk, clipping)
  local cx, cy = chunk:get_center()
  chunk:insert_entity('Glowshroom_1', cx, cy)
end

return filler