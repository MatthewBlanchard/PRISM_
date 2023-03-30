--love.math.setRandomSeed(1)
love.audio.setVolume(0)

local Map = require "maps.map"
local Object = require "object"
local vec2 = require "vector"
local Clipper = require('maps.clipper.clipper')

local Level = Object:extend()

function Level:__new()
  self._width = 600
  self._height = 600
  self._map = Map:new(600, 600, 0)
end

function Level:create(callback)
  local map = self._map
  
  local graph = {
    nodes = {}
  }
  graph.new_node = function (self, parameters)
    local node = {
      parameters = parameters,
      room = nil,
      edges = {}
    }
    
    return node
  end
  graph.add_node = function (self, node)
    table.insert(self.nodes, node)
    self.nodes[node] = #self.nodes
    
    return node
  end
  local edge_type = {"Join", "Overlay", "Weak"}
  -- path qualites
  -- Join offset, "Butt", join qualities
  -- Join preferences
  graph.connect_nodes = function (self, meta, ...)
    local nodes = {...}
    for i = 1, #nodes-1 do
      table.insert(nodes[i].edges, {meta = meta, node = nodes[i+1]})
      table.insert(nodes[i+1].edges, {meta = meta, node = nodes[i]})
    end
  end
  
  local prototype = graph:new_node{
    width = 4, height = 4,
    shaper = function(params, chunk)
      chunk:clear_rect(1,1, chunk.width-1, chunk.height-1)
    end,
    populater = function(params, chunk)
    end,
  }

  local _, boss_key_uuid
  
  local start = graph:new_node{
    width = 4, height = 4,
    shaper = function(params, chunk)
      local cx, cy = chunk:get_center()
      chunk:clear_ellipse(cx, cy, 1, 1)
    end,
    populater = function(params, chunk)
      local cx, cy = chunk:get_center()
      chunk:insert_actor('Player', cx, cy)
      chunk:insert_actor('Wand_of_blastin', cx, cy+1)
      --chunk:insert_actor('Shortsword', cx, cy+1)
      chunk:insert_actor('Key_type', cx-1, cy)
      _, boss_key_uuid = chunk:insert_actor('Key_id', cx, cy-1)
      
      local callback = function(actor, actors_by_unique_id)
        local chest_inventory = actor:getComponent(components.Inventory)
        chest_inventory:addItem(actors.Potion())
        local chest_lock = actor:getComponent(components.Lock_type)
        chest_lock:setKey(actors.Key_type)
      end
      chunk:insert_actor('Chest_lock_type', cx+1, cy, callback)
    end,
  }
  graph:add_node(start)
  
  local finish = graph:new_node{
    width = 4, height = 4,
    shaper = function(params, chunk)
      chunk:clear_rect(1,1, chunk.width-1, chunk.height-1)
    end,
    populater = function(params, chunk)
      local cx, cy = chunk:get_center()
      
      chunk:insert_actor('Stairs', cx, cy)
    end,
  }
  graph:add_node(finish)
  
  local sqeeto_hive = graph:new_node{
    width = 20, height = 20,
    shaper = function(params, chunk)
      chunk:clear_ellipse(chunk.width/2, chunk.height/2, 5, 5)
      for i = 1, 20 do
        chunk:DLAInOut()
      end
    end,
    populater = function(params, chunk, clipping)
      local cx, cy = math.floor(chunk.width/2)+1, math.floor(chunk.height/2)+1
      
      for i = 1, 3 do
        local x, y
        repeat
          x, y = love.math.random(1, chunk.width-1)+1, love.math.random(1, chunk.height-1)+1
        until Clipper.PointInPolygon(Clipper.IntPoint(x, y), clipping) == 1
        chunk:insert_actor('Sqeeto', x, y)
      end
      
      chunk:insert_actor('Prism', cx, cy)
    end,
    
  }
  graph:add_node(sqeeto_hive)
  
  local spider_nest = graph:new_node{
    width = 20, height = 20,
    shaper = function(params, chunk)
      local cx, cy = chunk:get_center()
      for i = 1, 2 do
        local path = chunk:drunkWalk(cx, cy,
          function(x, y, i, chunk)  
            return (i > 10) or (x < 5 or x > chunk.width-5 or y < 5 or y > chunk.height-5)
          end
        )
      
        chunk:clear_path(path)
      end
  
      for i = 1, 20 do
        chunk:DLA()
      end
    end,
    populater = function(params, chunk, clipping)
      local cx, cy = chunk:get_center()
  
      for i = 1, 1 do
        local x, y
        repeat
          x, y = love.math.random(1, chunk.width-1)+1, love.math.random(1, chunk.height-1)+1
        until Clipper.PointInPolygon(Clipper.IntPoint(x, y), clipping) == 1
        --chunk:insert_actor('Webweaver', x, y)
      end
  
      for i = 1, 2 do
        local x, y
        repeat
          x, y = love.math.random(1, chunk.width-1)+1, love.math.random(1, chunk.height-1)+1
        until Clipper.PointInPolygon(Clipper.IntPoint(x, y), clipping) == 1
        chunk:insert_actor('Web', x, y)
      end

      for i = 1, 2 do
        local x, y
        repeat
          x, y = love.math.random(1, chunk.width-1)+1, love.math.random(1, chunk.height-1)+1
        until Clipper.PointInPolygon(Clipper.IntPoint(x, y), clipping) == 1
        if love.math.random(0, 1) == 1 then
          chunk:insert_actor('Bones_1', x, y)
        else
          chunk:insert_actor('Bones_2', x, y)
        end
      end

      for x, y, cell in chunk:for_cells() do
        print(x, y)
        -- if cell == 1 then
        --   if love.math.random(0, 1) == 1 then
        --     chunk:insert_actor('Rocks_1', x, y)
        --   else
        --     chunk:insert_actor('Rocks_2', x, y)
        --   end
        -- end
      end
  
    end,
  
  }
  graph:add_node(spider_nest)
  
  -- local shop = graph:new_node{
  --   width = 8, height = 8,
  --   shaper = function(params, chunk)
  --     chunk:clear_rect(1,1, chunk.width-1, chunk.height-1)
  --   end,
  --   populater = function(params, chunk)
  --     local cx, cy = math.floor(chunk.width/2)+1, math.floor(chunk.height/2)+1
  
  --     local _, shopkeep_id = chunk:insert_actor('Shopkeep', cx, cy-1)
  --     chunk:insert_actor('Stationarytorch', cx-2, cy-1)
  --     chunk:insert_actor('Stationarytorch', cx+2, cy-1)
  
  --     local shopItems = {
  --       {
  --         components.Weapon,
  --         components.Wand
  --       },
  --       {
  --         components.Equipment
  --       },
  --       {
  --         components.Edible,
  --         components.Drinkable,
  --         components.Readable
  --       }
  --     }
  
  --     for i = 1, 3 do
  --       local itemTable = shopItems[i]
  --       local item = Loot.generateLoot(itemTable[love.math.random(1, #itemTable)])
  
  --       local callback = function(actor, actors_by_unique_id)
  --         local status = ''
  
  --         local sellable_component = actor:getComponent(components.Sellable)
  --         sellable_component:setItem(item)
  --         sellable_component:setPrice(actors.Shard, item:getComponent(components.Cost).cost)
  
  --         if actors_by_unique_id[shopkeep_id] then
  --           sellable_component:setShopkeep(actors_by_unique_id[shopkeep_id])
  --         else
  --           status = 'Delay'
  --         end
  
  --         return status
  --       end
  --       chunk:insert_actor('Product', cx-2+i, cy, callback)
  --     end
  --   end,
  -- }
  -- graph:add_node(shop)
  
  -- local snip_farm = graph:new_node{
  --   width = 10, height = 10,
  --   shaper = function(params, chunk)
  --     chunk:clear_rect(1,1, chunk.width-1, chunk.height-1)
  --   end,
  --   populater = function(params, chunk)
  --     local cx, cy = math.floor(chunk.width/2)+1, math.floor(chunk.height/2)+1
  
  --     chunk:fill_perimeter(cx-2, cy-2, cx+2, cy+2)
  --     chunk:clear_cell(cx, cy+2)
  
  --     local _, shopkeep_id = chunk:insert_actor('Shopkeep', cx, cy+2)
  
  --     chunk:target_rect(cx-1, cy-1, cx+1, cy+1, function(x, y)
  --         chunk:insert_actor('Snip', x, y)
  --       end
  --     )
  --   end,
  -- }
  -- graph:add_node(snip_farm)
  
  -- local tunnel = graph:new_node{
  --   width = 10, height = 10,
  --   shaper = function(params, chunk)
  --     local cx, cy = chunk:get_center()
  
  --     chunk:drunkWalk(cx, cy,
  --       function(x, y, i, chunk)  
  --         return (i > 10) or (x < 1 or x > chunk.width-1 or y < 1 or y > chunk.height-1)
  --       end
  --     )
  
  --   end,
  --   populater = function(params, chunk)
  --   end,
  -- }
  -- graph:add_node(tunnel)
  
  -- local lake = graph:new_node{
  --   width = 10, height = 10,
  --   shaper = function(params, chunk)
  --     local cx, cy = chunk:get_center()
  --     chunk:clear_rect(1, 1, chunk.width-1, chunk.height-1)
  --   end,
  --   populater = function(params, chunk)
  --     local cx, cy = chunk:get_center()
  --     chunk:target_ellipse(cx, cy, 3, 3, function(x, y)
  --       chunk:insert_actor('Water', x, y)
  --     end
  --   )
  --   end,
  -- }
  -- graph:add_node(lake)
  
  -- local path_test = graph:new_node{
  --   width = 20, height = 20,
  --   shaper = function(params, chunk)
  --     local cx, cy = chunk:get_center()
  --     for i = 1, 2 do
  --       local path = chunk:drunkWalk(cx, cy,
  --         function(x, y, i, chunk)  
  --           return (i > 10) or (x < 5 or x > chunk.width-5 or y < 5 or y > chunk.height-5)
  --         end
  --       )
  --       chunk:clear_path(path)
  --     end
  
  --     for i = 1, 50 do
  --       chunk:DLA()
  --     end
  --   end,
  --   populater = function(params, chunk, clipping)
  --     local cx, cy = math.floor(chunk.width/2)+1, math.floor(chunk.height/2)+1
  --   end,
  -- }
  -- graph:add_node(path_test)
  
  -- local lake = graph:new_node{
  --   width = 10, height = 10,
  --   shaper = function(params, chunk)
  --     local cx, cy = chunk:get_center()
  --     chunk:clear_rect(1, 1, chunk.width-1, chunk.height-1)
  --   end,
  --   populater = function(params, chunk)
  --     local cx, cy = chunk:get_center()
  --     local path = chunk:new_path()
  --     for i = 0, 3 do
  --       path:add_point(vec2(cx+i, cy+i))
  --     end
  
  --     chunk:target_path(path, function(x, y)
  --       chunk:insert_actor('Water', x, y)
  --     end)
  --   end,
  -- }
  -- graph:add_node(lake)
  
  --graph:connect_nodes({type = 'Join'}, start, path_test, finish)
  
  
  
  local encounters = {
    {cr = 1, actors = {"sqeeto"}},
    {cr = 2, actors = {"lizbop"}},
    {cr = 3, actors = {"Webweaver"}},
  }

  local edge_join_door = {
    type = 'Join', 
    callback = function(chunk, info)
      local connection_point = vec2(info.match_point_2.x, info.match_point_2.y) + info.offset + info.clip_dimension_sum
      local x, y = connection_point.x, connection_point.y

      chunk:clear_cell(x, y)
      :clear_cell(x+info.vec[2], y+info.vec[1])
      :clear_cell(x-info.vec[2], y-info.vec[1])
      :insert_actor('Door', x, y)
    end,
  }

  local edge_join_breakable_wall = {
    type = 'Join', 
    callback = function(chunk, info)
      local connection_point = vec2(info.match_point_2.x, info.match_point_2.y) + info.offset + info.clip_dimension_sum
      local x, y = connection_point.x, connection_point.y

      chunk:clear_cell(x, y)
      :clear_cell(x+info.vec[2], y+info.vec[1])
      :clear_cell(x-info.vec[2], y-info.vec[1])
      :insert_actor('Breakable_wall', x, y)
    end,
  }

  local edge_join_river = {
    type = 'Join', 
    callback = function(chunk, info)
      local connection_point = vec2(info.match_point_2.x, info.match_point_2.y) + info.offset + info.clip_dimension_sum
      local x, y = connection_point.x, connection_point.y
      local bridge_dir_type = info.vec[1] == 1 and '_v' or '_h'
      local river_dir_type = info.vec[1] == 0 and '_v' or '_h'

      local segment_index = info.segment_index_2
      local point = vec2(info.segment_2[segment_index].x, info.segment_2[segment_index].y)
      point = point + info.offset + info.clip_dimension_sum
      chunk:clear_cell(point.x, point.y)
      :clear_cell(point.x+info.vec[2], point.y+info.vec[1])
      :clear_cell(point.x-info.vec[2], point.y+info.vec[1])
      chunk:insert_actor('Bridge'..bridge_dir_type, point.x, point.y)

      for n = 1, 1 do
        local segment_index = info.segment_index_2 - n
        local point = vec2(info.segment_2[segment_index].x, info.segment_2[segment_index].y)
        point = point + info.offset + info.clip_dimension_sum
        chunk:clear_cell(point.x, point.y)
        chunk:insert_actor('River'..river_dir_type, point.x, point.y)

        local segment_index = info.segment_index_2 + n
        local point = vec2(info.segment_2[segment_index].x, info.segment_2[segment_index].y)
        point = point + info.offset + info.clip_dimension_sum
        chunk:clear_cell(point.x, point.y)
        chunk:insert_actor('River'..river_dir_type, point.x, point.y)
      end
      

      -- chunk:clear_cell(x, y)

    end,
  }

  local edge_join_boss_door = {
    type = 'Join', 
    callback = function(chunk, info)
      local connection_point = vec2(info.match_point_2.x, info.match_point_2.y) + info.offset + info.clip_dimension_sum
      local x, y = connection_point.x, connection_point.y

      chunk:clear_cell(x, y)
      :clear_cell(x+info.vec[2], y+info.vec[1])
      :clear_cell(x-info.vec[2], y-info.vec[1])
      :insert_actor('Door_locked', x, y, function(actor, actors_by_unique_id)
        if not actors_by_unique_id[boss_key_uuid] then
          return 'Delay'
        end
        local chest_lock = actor:getComponent(components.Lock_id)
        chest_lock:setKey(actors_by_unique_id[boss_key_uuid])
      end)
    end,
  }
  
  local filler_nodes = {}
  for i = 1, 4 do
    filler_nodes[i] = graph:new_node{
      width = love.math.random(4, 10), height = love.math.random(4, 10),
      shaper = function(params, chunk)
        chunk:clear_rect(1,1, chunk.width-1, chunk.height-1)
      end,
      populater = function(params, chunk, clipping)
        local cx, cy = chunk:get_center()
        --chunk:insert_actor('Sqeeto', cx, cy)
      end,
    }
    graph:add_node(filler_nodes[i])
    
    if i > 1 then
      local tunnel = graph:new_node{
        width = 15, height = 15,
        shaper = function(params, chunk)
          local cx, cy = chunk:get_center()
          
          local path = chunk:drunkWalk(cx, cy,
          function(x, y, i, chunk)  
            return (i > 10) or (x < 1 or x > chunk.width-1 or y < 1 or y > chunk.height-1)
          end
        )
        
        chunk:clear_path(path)
        
      end,
      populater = function(params, chunk, clipping)
        for i = 1, 1 do
          local x, y
          repeat
            x, y = love.math.random(1, chunk.width-1)+1, love.math.random(1, chunk.height-1)+1
          until Clipper.PointInPolygon(Clipper.IntPoint(x, y), clipping) == 1
          if love.math.random(0, 1) == 1 then
            chunk:insert_actor('Glowshroom_1', x, y)
          else
            chunk:insert_actor('Glowshroom_2', x, y)
          end
        end
      end,
    }
    graph:add_node(tunnel)
    
    graph:connect_nodes(edge_join_river, filler_nodes[i], tunnel, filler_nodes[love.math.random(1, i-1)])
  end
end

graph:connect_nodes(edge_join_door, start, filler_nodes[love.math.random(1, #filler_nodes)])
graph:connect_nodes(edge_join_door, finish, filler_nodes[love.math.random(1, #filler_nodes)])
graph:connect_nodes(edge_join_breakable_wall, sqeeto_hive, filler_nodes[love.math.random(1, #filler_nodes)])
graph:connect_nodes(edge_join_boss_door, spider_nest, filler_nodes[love.math.random(1, #filler_nodes)])


local merged_room_3 = Map:special_merge(graph)
map:copy_map_onto_self_at_position(merged_room_3, 0, 0)


local player_pos
for i, v in ipairs(map.actors.list) do
  if v.id == 'Player' then
    player_pos = v.pos
    break
  end
end


for x = 0, map.width do
  for y = 0, map.height do
    if map.cells[x][y] == 1 then
      --map:insert_actor('Wall', x, y)
    end
    --map:clear_cell(x, y)
  end
end

local heat_map = Map:new(600, 600, 0)
heat_map:copy_map_onto_self_at_position(map, 0, 0)
heat_map = heat_map:dijkstra({player_pos}, 'vonNeuman')
for i, v in ipairs(heat_map.cells) do
  for i2, v2 in ipairs(v) do
    if v2 == 999 then
      map.cells[i][i2] = 1
    end
  end
end

for x = 0, self._width do
  for y = 0, self._height do
    callback(x, y, self._map.cells[x][y])
  end
end

return map, heat_map, rooms
end




return Level