local Chunk = require 'maps.chunk'

local finish = Chunk:extend()
function finish:parameters()
  self.width, self.height = 4, 4
end
function finish:shaper(chunk)
  chunk:clear_rect(1,1, chunk.width-1, chunk.height-1)
end
function finish:populater(chunk, clipping)
  local cx, cy = chunk:get_center()
    
  chunk:insert_actor('Stairs', cx, cy)
end

return finish