local Chunk = require 'maps.chunk'

local shop = Chunk:extend()
function shop:parameters()
  self.width, self.height = 7, 7
end
function shop:shaper(chunk)
  chunk:clear_rect(0, 0, chunk.width, chunk.height)
end
function shop:populater(chunk, clipping)
  local cx, cy = chunk:get_center()
  
  local _, shopkeep_id = chunk:insert_actor('Shopkeep', cx, cy-1)
  chunk:insert_actor('Stationarytorch', cx-2, cy-1)
  chunk:insert_actor('Stationarytorch', cx+2, cy-1)

  local shopItems = {
    {
      components.Weapon,
      components.Wand
    },
    {
      components.Equipment
    },
    {
      components.Edible,
      components.Drinkable,
      components.Readable
    }
  }

  for i = 1, 3 do
    local itemTable = shopItems[i]
    local item = Loot.generateLoot(itemTable[love.math.random(1, #itemTable)])

    local callback = function(actor, actors_by_unique_id)
      local status = ''

      local sellable_component = actor:getComponent(components.Sellable)
      sellable_component:setItem(item)
      sellable_component:setPrice(actors.Shard, item:getComponent(components.Cost).cost)

      if actors_by_unique_id[shopkeep_id] then
        sellable_component:setShopkeep(actors_by_unique_id[shopkeep_id])
      else
        status = 'Delay'
      end

      return status
    end
    chunk:insert_actor('Product', cx-2+i, cy, callback)
  end
end

return shop