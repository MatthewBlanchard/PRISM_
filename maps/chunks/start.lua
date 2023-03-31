local Chunk = require 'maps.chunk'

local start = Chunk:extend()
function start:parameters()
  self.width, self.height = 4, 4
end
function start:shaper(chunk)
  local cx, cy = chunk:get_center()
  chunk:clear_ellipse(cx, cy, 1, 1)
end
function start:populater(chunk, clipping)
  local cx, cy = chunk:get_center()
  chunk:insert_actor('Player', cx, cy)
  chunk:insert_actor('Wand_of_blastin', cx, cy+1)
  chunk:insert_actor('Key_type', cx-1, cy)
  chunk:insert_actor('Key_id', cx, cy-1, nil, self.key_id)
  
  local callback = function(actor, actors_by_unique_id)
    local chest_inventory = actor:getComponent(components.Inventory)
    chest_inventory:addItem(actors.Potion())
    local chest_lock = actor:getComponent(components.Lock_type)
    chest_lock:setKey(actors.Key_type)
  end
  chunk:insert_actor('Chest_lock_type', cx+1, cy, callback)
end

return start