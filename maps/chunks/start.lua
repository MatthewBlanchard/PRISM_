local Chunk = require 'maps.chunk'

local start = Chunk:extend()
function start:parameters()
  self.width, self.height = 3, 3
end
function start:shaper(chunk)
  local cx, cy = chunk:get_center()
  --chunk:clear_ellipse(cx, cy, 1, 1)
  chunk:clear_rect(0, 0, chunk.width, chunk.height)
end
function start:populater(chunk, clipping)
  local cx, cy = chunk:get_center()
  chunk:insert_entity('Player', cx, cy)
  -- chunk:insert_entity('Wand_of_blastin', cx, cy+1)
  -- chunk:insert_entity('Key_type', cx-1, cy)
  -- chunk:insert_entity('Key_id', cx, cy-1, nil, self.key_id)
  
  local callback = function(actor, actors_by_unique_id)
    local chest_inventory = actor:getComponent(components.Inventory)
    chest_inventory:addItem(actors.Potion())
    local chest_lock = actor:getComponent(components.Lock_type)
    chest_lock:setKey(actors.Key_type)
  end
  -- chunk:insert_entity('Chest_lock_type', cx+1, cy, callback)

  -- for x, y, cell in chunk:for_cells() do
  --   if cell == 1 then
  --     if love.math.random(0, 1) == 1 then
  --       chunk:insert_entity('Rocks_1', x, y)
  --     else
  --       chunk:insert_entity('Rocks_2', x, y)
  --     end
  --   end
  -- end
end

return start