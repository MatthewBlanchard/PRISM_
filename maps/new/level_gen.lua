--love.math.setRandomSeed(1)
love.audio.setVolume(0)

local Map = require "maps.map"
local Object = require "object"
local vec2 = require "vector"
local Clipper = require('maps.clipper.clipper')

local Level = Object:extend()

function Level:__new()
  self._width = 100
  self._height = 100
  self._map = Map:new(100, 100, 0)
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
    shaper = function(params, room)
      room:clear_rect(1,1, params.width-1, params.height-1)
    end,
    populater = function(params, room)
    end,
  }

  local start = graph:new_node{
    width = 4, height = 4,
    shaper = function(params, room)
      local cx, cy = room:get_center()
      room:clear_ellipse(cx, cy, 1, 1)
    end,
    populater = function(params, room)
      local cx, cy = room:get_center()
      room:insert_actor('Player', cx, cy)
    end,
  }
  graph:add_node(start)

  local finish = graph:new_node{
    width = 4, height = 4,
    shaper = function(params, room)
      room:clear_rect(1,1, params.width-1, params.height-1)
    end,
    populater = function(params, room)
      local cx, cy = room:get_center()

      room:insert_actor('Stairs', cx, cy)
    end,
  }
  graph:add_node(finish)

  -- local sqeeto_hive = graph:new_node{
  --   width = 20, height = 20,
  --   shaper = function(params, room)
  --     room:clear_ellipse(params.width/2, params.height/2, 5, 5)
  --     for i = 1, 20 do
  --       room:DLAInOut()
  --     end
  --   end,
  --   populater = function(params, room, clipping)
  --     local cx, cy = math.floor(params.width/2)+1, math.floor(params.height/2)+1

  --     for i = 1, 3 do
  --       local x, y
  --       repeat
  --         x, y = love.math.random(1, params.width-1)+1, love.math.random(1, params.height-1)+1
  --       until Clipper.PointInPolygon(Clipper.IntPoint(x, y), clipping) == 1
  --       room:insert_actor('Sqeeto', x, y)
  --     end

  --     room:insert_actor('Prism', cx, cy)
  --   end,

  -- }
  -- graph:add_node(sqeeto_hive)

  -- local spider_nest = graph:new_node{
  --   width = 20, height = 20,
  --   shaper = function(params, room)
  --     for i = 1, 2 do
  --       room:drunkWalk(room.width/2, room.height/2,
  --         function(x, y, i, room)  
  --           return (i > 10) or (x < 5 or x > room.width-5 or y < 5 or y > room.height-5)
  --         end
  --       )
  --     end

  --     for i = 1, 20 do
  --       room:DLA()
  --     end
  --   end,
  --   populater = function(params, room, clipping)
  --     local cx, cy = math.floor(params.width/2)+1, math.floor(params.height/2)+1

  --     for i = 1, 1 do
  --       local x, y
  --       repeat
  --         x, y = love.math.random(1, params.width-1)+1, love.math.random(1, params.height-1)+1
  --       until Clipper.PointInPolygon(Clipper.IntPoint(x, y), clipping) == 1
  --       room:insert_actor('Webweaver', x, y)
  --     end

  --     for i = 1, 1 do
  --       local x, y
  --       repeat
  --         x, y = love.math.random(1, params.width-1)+1, love.math.random(1, params.height-1)+1
  --       until Clipper.PointInPolygon(Clipper.IntPoint(x, y), clipping) == 1
  --       --room:insert_actor('Web', x, y)
  --     end

  --   end,

  -- }
  -- graph:add_node(spider_nest)

  -- local shop = graph:new_node{
  --   width = 8, height = 8,
  --   shaper = function(params, room)
  --     room:clear_rect(1,1, params.width-1, params.height-1)
  --   end,
  --   populater = function(params, room)
  --     local cx, cy = math.floor(params.width/2)+1, math.floor(params.height/2)+1

  --     local _, shopkeep_id = room:insert_actor('Shopkeep', cx, cy-1)
  --     room:insert_actor('Stationarytorch', cx-2, cy-1)
  --     room:insert_actor('Stationarytorch', cx+2, cy-1)

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
  --           status = 'delay'
  --         end

  --         return status
  --       end
  --       room:insert_actor('Product', cx-2+i, cy, callback)
  --     end
  --   end,
  -- }
  -- graph:add_node(shop)

  -- local snip_farm = graph:new_node{
  --   width = 10, height = 10,
  --   shaper = function(params, room)
  --     room:clear_rect(1,1, params.width-1, params.height-1)
  --   end,
  --   populater = function(params, room)
  --     local cx, cy = math.floor(params.width/2)+1, math.floor(params.height/2)+1

  --     room:fill_perimeter(cx-2, cy-2, cx+2, cy+2)
  --     room:clear_cell(cx, cy+2)

  --     local _, shopkeep_id = room:insert_actor('Shopkeep', cx, cy+2)

  --     room:target_rect(cx-1, cy-1, cx+1, cy+1, function(x, y)
  --         room:insert_actor('Snip', x, y)
  --       end
  --     )
  --   end,
  -- }
  -- graph:add_node(snip_farm)

  -- local tunnel = graph:new_node{
  --   width = 10, height = 10,
  --   shaper = function(params, room)
  --     local cx, cy = room:get_center()

  --     room:drunkWalk(cx, cy,
  --       function(x, y, i, room)  
  --         return (i > 10) or (x < 1 or x > room.width-1 or y < 1 or y > room.height-1)
  --       end
  --     )

  --   end,
  --   populater = function(params, room)
  --   end,
  -- }
  -- graph:add_node(tunnel)

  -- local lake = graph:new_node{
  --   width = 10, height = 10,
  --   shaper = function(params, room)
  --     local cx, cy = room:get_center()
  --     room:clear_rect(1, 1, room.width-1, room.height-1)
  --   end,
  --   populater = function(params, room)
  --     local cx, cy = room:get_center()
  --     room:target_ellipse(cx, cy, 3, 3, function(x, y)
  --       room:insert_actor('Water', x, y)
  --     end
  --   )
  --   end,
  -- }
  -- graph:add_node(lake)

  local path_test = graph:new_node{
    width = 20, height = 20,
    shaper = function(params, room)
      for i = 1, 2 do
        local path = room:drunkWalk(room.width/2, room.height/2,
          function(x, y, i, room)  
            return (i > 10) or (x < 5 or x > room.width-5 or y < 5 or y > room.height-5)
          end
        )
        room:clear_path(path)
      end



      for i = 1, 50 do
        room:DLA()
      end
    end,
    populater = function(params, room, clipping)
      local cx, cy = math.floor(params.width/2)+1, math.floor(params.height/2)+1
    end,
  }
  graph:add_node(path_test)

  -- local lake = graph:new_node{
  --   width = 10, height = 10,
  --   shaper = function(params, room)
  --     local cx, cy = room:get_center()
  --     room:clear_rect(1, 1, room.width-1, room.height-1)
  --   end,
  --   populater = function(params, room)
  --     local cx, cy = room:get_center()
  --     local path = room:new_path()
  --     for i = 0, 3 do
  --       path:add_point(vec2(cx+i, cy+i))
  --     end

  --     room:target_path(path, function(x, y)
  --       room:insert_actor('Water', x, y)
  --     end)
  --   end,
  -- }
  -- graph:add_node(lake)
  
  graph:connect_nodes({type = 'Join'}, start, path_test, finish)

  -- local filler_nodes = {}
  -- for i = 1, 4 do
  --   filler_nodes[i] = graph:new_node{
  --     width = love.math.random(4, 10), height = love.math.random(4, 10),
  --     shaper = function(params, room)
  --       room:clear_rect(1,1, params.width-1, params.height-1)
  --     end,
  --     populater = function(params, room)
  --       local cx, cy = math.floor(params.width/2)+1, math.floor(params.height/2)+1
  --     end,
  --   }
  --   graph:add_node(filler_nodes[i])

  --   if i > 1 then
  --     local tunnel = graph:new_node{
  --       width = 15, height = 15,
  --       shaper = function(params, room)
  --         local cx, cy = room:get_center()
    
  --         room:drunkWalk(cx, cy,
  --           function(x, y, i, room)  
  --             return (i > 10) or (x < 1 or x > room.width-1 or y < 1 or y > room.height-1)
  --           end
  --         )
    
  --       end,
  --       populater = function(params, room)
  --       end,
  --     }
  --     graph:add_node(tunnel)

  --     graph:connect_nodes({type = 'Join'}, filler_nodes[i], tunnel, filler_nodes[love.math.random(1, i-1)])
  --   end
  -- end

  -- graph:connect_nodes({type = 'Join'}, start, filler_nodes[love.math.random(1, #filler_nodes)])
  -- graph:connect_nodes({type = 'Join'}, finish, filler_nodes[love.math.random(1, #filler_nodes)])


  local merged_room_3 = Map:special_merge(graph)
  map:copy_map_onto_self_at_position(merged_room_3, 0, 0)


  local player_pos
  for i, v in ipairs(map.actors.list) do
    if v.id == 'Player' then
      player_pos = v.pos
      break
    end
  end

  local heat_map = Map:new(1000, 1000, 0)
  heat_map:copy_map_onto_self_at_position(map, 0, 0)

  -- heat_map = heat_map:dijkstra({player_pos}, 'moore')
  -- for i, v in ipairs(heat_map.map) do
  --   for i2, v2 in ipairs(v) do
  --     if v2 == 999 then
  --       map.map[i][i2] = 1
  --     end
  --   end
  -- end

  for x = 0, self._width do
    for y = 0, self._height do
      callback(x, y, self._map.cells[x][y])
    end
  end

  return map, heat_map, rooms
end




return Level