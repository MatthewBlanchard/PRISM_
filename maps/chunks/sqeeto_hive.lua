local Chunk = require 'maps.chunk'
local Clipper = require('maps.clipper.clipper')

local sqeeto_hive = Chunk:extend()

function sqeeto_hive:populater(chunk, clipping)
  local cx, cy = chunk:get_center()
  
  for i = 1, 3 do
    local x, y
    repeat
      x, y = love.math.random(1, chunk.width-1)+1, love.math.random(1, chunk.height-1)+1
    until Clipper.PointInPolygon(Clipper.IntPoint(x, y), clipping) == 1
    chunk:insert_entity('Sqeeto', x, y)
  end
  
  chunk:insert_entity('Prism', cx, cy)
end

return sqeeto_hive