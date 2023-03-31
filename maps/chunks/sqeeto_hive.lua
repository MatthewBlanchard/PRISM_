local Chunk = require 'maps.chunk'
local Clipper = require('maps.clipper.clipper')

local sqeeto_hive = Chunk:new(20, 20)
function sqeeto_hive:parameters()
  self.width, self.height = 20, 20
end
function sqeeto_hive:shaper(chunk)
  chunk:clear_ellipse(chunk.width/2, chunk.height/2, 5, 5)
  for i = 1, 20 do
    chunk:DLAInOut()
  end
end
function sqeeto_hive:populater(chunk, clipping)
  local cx, cy = math.floor(chunk.width/2)+1, math.floor(chunk.height/2)+1
  
  for i = 1, 3 do
    local x, y
    repeat
      x, y = love.math.random(1, chunk.width-1)+1, love.math.random(1, chunk.height-1)+1
    until Clipper.PointInPolygon(Clipper.IntPoint(x, y), clipping) == 1
    chunk:insert_actor('Sqeeto', x, y)
  end
  
  chunk:insert_actor('Prism', cx, cy)
end

return sqeeto_hive