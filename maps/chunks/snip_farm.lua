local Chunk = require 'maps.chunk'

local snip_farm = Chunk:extend()
function snip_farm:parameters()
  self.width, self.height = 9, 9
end
function snip_farm:shaper(chunk)
  chunk:clear_rect(0,0, chunk.width, chunk.height)
end
function snip_farm:populater(chunk)
  local cx, cy = chunk:get_center()
  
  chunk:target_perimeter(cx-2, cy-2, cx+2, cy+2, function(x, y)
    chunk:insert_entity('Fence', x, y)
  end)
  chunk:remove_entities(x, y)
  
  local _, shopkeep_id = chunk:insert_entity('Shopkeep', cx, cy+2)
  
  chunk:target_rect(cx-1, cy-1, cx+1, cy+1, function(x, y)
    chunk:insert_entity('Snip', x, y)
  end)
end

return snip_farm