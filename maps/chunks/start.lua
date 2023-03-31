local Chunk = require 'maps.chunk'

local start = Chunk:new()
function start:parameters()
  self.width, self.height = 4, 4
end
function start:shaper(map)
  local cx, cy = map:get_center()
  map:clear_ellipse(cx, cy, 1, 1)
end
function start:populater(map, clipping)
  local cx, cy = map:get_center()
  map:insert_actor('Player', cx, cy)
  map:insert_actor('Wand_of_blastin', cx, cy+1)
  map:insert_actor('Key_type', cx-1, cy)
  map:insert_actor('Key_id', cx, cy-1, nil, self.key_id)
  
  local callback = function(actor, actors_by_unique_id)
    local chest_inventory = actor:getComponent(components.Inventory)
    chest_inventory:addItem(actors.Potion())
    local chest_lock = actor:getComponent(components.Lock_type)
    chest_lock:setKey(actors.Key_type)
  end
  map:insert_actor('Chest_lock_type', cx+1, cy, callback)
end

return start