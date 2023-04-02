local Chunk = require 'maps.chunk'

local finish = Chunk:extend()
function finish:parameters()
  self.width, self.height = 3, 3
end
function finish:shaper(chunk)
  print(chunk.width)
  chunk:clear_rect(0,0, chunk.width, chunk.height)
end
function finish:populater(chunk, clipping)
  print(chunk.width)
  local cx, cy = chunk:get_center()
    
  chunk:insert_entity('Stairs', cx, cy)
end

return finish