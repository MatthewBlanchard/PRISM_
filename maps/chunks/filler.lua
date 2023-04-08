local Chunk = require 'maps.chunk'

local filler = Chunk:extend()
function filler:parameters()
  self.width = love.math.random(3, 5)
  self.height = love.math.random(3, 5)
end
function filler:shaper(chunk)
  chunk:clear_rect(0,0, chunk.width, chunk.height)
end
function filler:populater(info)
  local chunk, map, offset, polygon = info.chunk, info.map, info.offset, info.polygon
  local center = vec2(chunk:get_center()) + offset
  map:insert_entity('Glowshroom_1', center.x, center.y)
end

return filler