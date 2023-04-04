local Chunk = require 'maps.chunk'

local finish = Chunk:extend()
function finish:parameters()
  self.width, self.height = 3, 3
end
function finish:shaper(chunk)
  chunk:clear_rect(0,0, chunk.width, chunk.height)
end
function finish:populater(chunk, clipping)
  local cx, cy = chunk:get_center()
    
  chunk:insert_entity('Stairs', cx, cy)
end

return finish