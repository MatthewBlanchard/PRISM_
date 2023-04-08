--love.math.setRandomSeed(1)
love.audio.setVolume(0) --gitignore

local Map = require "maps.map"
local Object = require "object"
local vec2 = require "vector"
local Clipper = require('maps.clipper.clipper')

local Level = Object:extend()

function Level:__new()
  self._width = 500
  self._height = 500
  self._map = Map:new(500, 500, 0)
end

function Level:create(callback)
  local map = self._map
  
  local graph = {
    vertices = {},
    edges = {}
  }
  function graph:add_vertex(parameters)
    local vertex = {
      parameters = parameters,
      chunk = nil,
      outline_edges = nil,
      polygon = nil,
      num_of_points = nil,
      
      edges = {}
    }

    table.insert(self.vertices, vertex)
    self.vertices[vertex] = #self.vertices
    
    return vertex
  end
  function graph:add_edge(meta, ...)
    local vertices = {...}
    for i = 1, #vertices-1 do
      local vertex_1 = vertices[i]
      local vertex_2 = vertices[i+1]

      table.insert(self.edges, {meta = meta, vertex_1 = vertex_1, vertex_2 = vertex_2})
      table.insert(vertex_1.edges, {meta = meta, vertex = vertex_2})
      table.insert(vertex_2.edges, {meta = meta, vertex = vertex_1})
    end
  end
  
  local id_generator = require 'maps.uuid'
  local boss_key_uuid

  local chunks = {}
  local function loadItems(directoryName, items, recurse)
    local info = {}
  
    for k, item in pairs(love.filesystem.getDirectoryItems(directoryName)) do
      local fileName = directoryName .. "/" .. item
      love.filesystem.getInfo(fileName, info)
      if info.type == "file" then
        fileName = string.gsub(fileName, ".lua", "")
        fileName = string.gsub(fileName, "/", ".")
        local name = string.gsub(item:sub(1, 1):upper() .. item:sub(2), ".lua", "")
  
        items[name] = require(fileName)
      elseif info.type == "directory" and recurse then
        loadItems(fileName, items, recurse)
      end
    end
  end
  loadItems("maps/chunks", chunks, false)
  

  local edge_join = {}
  edge_join.door = {
    type = 'Join', 
    callback = function(chunk, info)
      local point = info.points[1]

      chunk:remove_entities(point.x, point.y)

      chunk:clear_cell(point.x, point.y)
      :clear_cell(point.x+info.slope.y, point.y+info.slope.x)
      :clear_cell(point.x-info.slope.y, point.y-info.slope.x)
      :insert_entity('Door', point.x, point.y)
    end,
  }
  edge_join.breakable_wall = {
    type = 'Join', 
    callback = function(chunk, info)
      local point = info.points[1]

      chunk:clear_cell(point.x, point.y)
      :clear_cell(point.x+info.slope.y, point.y+info.slope.x)
      :clear_cell(point.x-info.slope.y, point.y-info.slope.x)
      :insert_entity('Breakable_wall', point.x, point.y)
    end,
  }
  edge_join.river = {
    type = 'Join', 
    callback = function(chunk, info)
      local bridge_dir_type = math.abs(info.slope.x) == 1 and '_v' or '_h'
      local river_dir_type = info.slope.x == 0 and '_v' or '_h'

      if #info.points % 2 == 0 then
        local point = info.points[math.floor(#info.points / 2)]
        chunk:clear_cell(point.x, point.y)
        :clear_cell(point.x+info.slope.y, point.y+info.slope.x)
        :clear_cell(point.x-info.slope.y, point.y-info.slope.x)
        :insert_entity('Bridge'..bridge_dir_type, point.x, point.y)

        local point = info.points[math.floor(#info.points / 2)+1]
        chunk:clear_cell(point.x, point.y)
        :clear_cell(point.x+info.slope.y, point.y+info.slope.x)
        :clear_cell(point.x-info.slope.y, point.y-info.slope.x)
        :insert_entity('Bridge'..bridge_dir_type, point.x, point.y)
      else
        local point = info.points[math.ceil(#info.points / 2)]
        chunk:clear_cell(point.x, point.y)
        :clear_cell(point.x+info.slope.y, point.y+info.slope.x)
        :clear_cell(point.x-info.slope.y, point.y-info.slope.x)
        :insert_entity('Bridge'..bridge_dir_type, point.x, point.y)

        -- for i = math.ceil(#info.points / 2)+1, #info.points do
        --   local point = info.points[i]
        --   chunk:clear_cell(point.x, point.y)
        --   :clear_cell(point.x+info.slope.y, point.y+info.slope.x)
        --   :clear_cell(point.x-info.slope.y, point.y-info.slope.x)
        --   :insert_entity('River'..river_dir_type, point.x, point.y)

        --   local point = info.points[#info.points-2*i]
        --   chunk:clear_cell(point.x, point.y)
        --   :clear_cell(point.x+info.slope.y, point.y+info.slope.x)
        --   :clear_cell(point.x-info.slope.y, point.y-info.slope.x)
        --   :insert_entity('River'..river_dir_type, point.x, point.y)
        -- end
      end
    end,
  }
  edge_join.boss_door = {
    type = 'Join', 
    callback = function(chunk, info)
      local point = info.points[1]

      chunk:clear_cell(point.x, point.y)
      :clear_cell(point.x+info.slope.y, point.y+info.slope.x)
      :clear_cell(point.x-info.slope.y, point.y-info.slope.x)
      :insert_entity('Door_locked', point.x, point.y, function(actor, entities_by_unique_id)
        if not entities_by_unique_id[boss_key_uuid] then
          return 'Delay'
        end
        local chest_lock = actor:getComponent(components.Lock_id)
        chest_lock:setKey(entities_by_unique_id[boss_key_uuid])
      end)
    end,
  }


  local edges = {}
  edges.narrow = {
    type = 'Join', 
    callback = function(chunk, info)
      local point = info.points[math.floor(#info.points/2)+1]
      chunk:remove_entities(point.x, point.y)

      chunk:clear_cell(point.x, point.y)
      :clear_cell(point.x+info.slope.y, point.y+info.slope.x)
      :clear_cell(point.x-info.slope.y, point.y-info.slope.x)
    end
  }
  edges.wide = {
    type = 'Join', 
    callback = function(chunk, info)
      for i, v in ipairs(info.points) do
        local point = info.points[i]
        chunk:remove_entities(point.x, point.y)

        chunk:clear_cell(point.x, point.y)
        :clear_cell(point.x+info.slope.y, point.y+info.slope.x)
        :clear_cell(point.x-info.slope.y, point.y-info.slope.x)
      end
    end
  }
  edges.window = {
    type = 'Join', 
    callback = function(chunk, info)
      local point = info.points[math.floor(#info.points/2)+1]
      chunk:remove_entities(point.x, point.y)

      chunk:clear_cell(point.x, point.y)
      :clear_cell(point.x+info.slope.y, point.y+info.slope.x)
      :clear_cell(point.x-info.slope.y, point.y-info.slope.x)
      :insert_entity("Fence", point.x, point.y)
    end
  }
  edges.door = {
    type = 'Join', 
    callback = function(chunk, info)
      local point = info.points[math.floor(#info.points/2)+1]
      chunk:remove_entities(point.x, point.y)

      chunk:clear_cell(point.x, point.y)
      :clear_cell(point.x+info.slope.y, point.y+info.slope.x)
      :clear_cell(point.x-info.slope.y, point.y-info.slope.x)
      :insert_entity("Door", point.x, point.y)
    end
  }


  
  -- local filler_vertices = {}
  -- for i = 1, 4 do
  --   local t = filler_vertices

  --   t[i] = graph:add_vertex(chunks.Filler)
  --   if i > 1 then
  --     local tunnel = graph:add_vertex(chunks.Tunnel)
  --     graph:add_edge(edge_join_river, t[i], tunnel, t[love.math.random(1, i-1)])
  --   end
  -- end

  -- local Start = chunks.Start
  -- Start.key_id = id_generator()
  -- boss_key_uuid = Start.key_id

  local telepad_1_id = id_generator()
  local telepad_2_id = id_generator()


  local start = graph:add_vertex(chunks.Filler:extend())
  function start.parameters:populater(info)
    local chunk, map, offset, polygon = info.chunk, info.map, info.offset, info.polygon

    local center = vec2(chunk:get_center()) + offset
    map:insert_entity('Player', center.x, center.y)
    map:insert_entity('Telepad', 0, 0, function(entity, entities_by_unique_id)
      if entities_by_unique_id[telepad_2_id] then
        local destination = entities_by_unique_id[telepad_2_id].position
        entity.teleport_destination = vec2(destination.x, destination.y)
      else
        status = 'Delay'
      end
      return status
    end, telepad_1_id)

    map:insert_entity('Telepad', center.x-1, center.y, function(entity, entities_by_unique_id)
      if entities_by_unique_id[telepad_1_id] then
        local destination = entities_by_unique_id[telepad_1_id].position
        entity.teleport_destination = vec2(destination.x, destination.y)
      else
        status = 'Delay'
      end
      return status
  end, telepad_2_id)


    local walls = {'Rocks_1', 'Rocks_2', 'Rocks_3'}
    for x, y, cell in chunk:for_cells() do
      if map:get_cell(x + offset.x, y + offset.y) == 1 and Clipper.PointInPolygon(Clipper.IntPoint(x, y), polygon) == -1 then
        local x, y = x + offset.x, y + offset.y
        map:insert_entity(walls[love.math.random(1, 3)], x, y)
      end
    end
  end

  local portal_room = graph:add_vertex(chunks.Filler:extend())
  function portal_room.parameters:populater(info)
    local chunk, map, offset, polygon = info.chunk, info.map, info.offset, info.polygon

    local center = vec2(chunk:get_center()) + offset
    --map:insert_entity('Telepad', center.x, center.y)
  end

  -- local lake = graph:add_vertex(chunks.Filler:extend())
  -- function lake.parameters:parameters()
  --   self.width, self.height = 10, 10
  -- end
  -- function lake.parameters:shaper(chunk)
  --   local cx, cy = chunk:get_center()
  --   chunk:clear_ellipse(cx-1, cx-1, 4, 4)
  --   for i = 1, 15 do
  --     chunk:DLAInOut()
  --   end
  -- end
  -- function lake.parameters:populater(info)
  --   local chunk, map, offset, polygon, vertex, edges_info = info.chunk, info.map, info.offset, info.polygon, info.vertex, info.edges
  --   local center = vec2(chunk:get_center()) + offset

  --   for x, y, cell in chunk:for_cells() do
  --     if cell == 0 and Clipper.PointInPolygon(Clipper.IntPoint(x, y), polygon) == 1 then
  --       local x, y = x + offset.x, y + offset.y
  --       map:insert_entity('Water', x, y)
  --     end
  --   end

  --   local endpoints = {}
  --   for k, v in pairs(edges_info[vertex]) do
  --     local edge = v
  --     local points = edge.points

  --     local point = points[math.floor(#points/2)+1]
  --     table.insert(endpoints, point)
  --   end

  --   local paths = {}
  --   for i, v in ipairs(endpoints) do
  --     table.insert(paths, map:aStar(center.x, center.y, v.x, v.y))
  --   end

    
  --   for _, path in ipairs(paths) do
  --     local bridge_dir_type = '_v'
  --     for i2, v2 in ipairs(path.points) do
  --       map:remove_entities(v2.x, v2.y)
  --       if i2 ~= #path.points then
  --         bridge_dir_type = math.abs(path:get_slope(i2, i2+1).x) == 0 and '_v' or '_h'
  --       end
  --       map:insert_entity('Bridge'..bridge_dir_type, v2.x, v2.y)
  --     end
  --   end

  -- end

  -- local entrance = graph:add_vertex(chunks.Filler:extend())
  -- local exit = graph:add_vertex(chunks.Filler:extend())
  -- local finish = graph:add_vertex(chunks.Filler:extend())

  -- graph:add_edge(edges.door, start, entrance)
  -- graph:add_edge(edges.wide, entrance, lake)
  -- graph:add_edge(edges.wide, lake, exit)
  -- graph:add_edge(edges.door, exit, finish)


  -- local spider_room = graph:add_vertex(chunks.Filler:extend())
  -- function spider_room.parameters:populater(info)
  --   local chunk, map, offset = info.chunk, info.map, info.offset

  --   local center = vec2(chunk:get_center()) + offset
  --   map:insert_entity('Webweaver', center.x, center.y)

  --   local walls = {'Rocks_1', 'Rocks_2', 'Rocks_3'}
  --   for x, y, cell in chunk:for_cells() do
  --     local x, y = x + offset.x, y + offset.y
  --     if cell == 1 then
  --       map:insert_entity(walls[love.math.random(1, 3)], x, y)
  --     end
  --   end
  -- end


  -- local filler_1 = graph:add_vertex(chunks.Filler)
  -- local filler_2 = graph:add_vertex(chunks.Filler)

  -- graph:add_edge(edges.window, start, spider_room)
  -- graph:add_edge(edges.narrow, start, filler_1)
  -- graph:add_edge(edges.narrow, filler_1, filler_2)
  -- graph:add_edge(edges.door, filler_2, spider_room)


  local merged_room = Map:planar_embedding(graph)
  map:blit(merged_room, 0, 0) 


  local player_pos
  for k, v in pairs(map.entities.list) do
    if v.id == 'Player' then
      player_pos = v.pos
      break
    end
  end


  -- local heat_map = Map:new(500, 500, 0)
  -- heat_map:blit(map, 0, 0) 
  -- heat_map = heat_map:dijkstra({player_pos}, 'vonNeuman')
  -- for x, y, cell in heat_map:for_cells() do
  --   if cell == 999 then
  --     map:fill_cell(x, y)
  --   end
  -- end


  for x, y, cell in map:for_cells() do
    local cell_is_occupied = false
    for k, v in pairs(map:get_entities(x, y)) do
      if cells[v.id] then
        cell_is_occupied = true
        break
      end
    end
    if cell_is_occupied == false then
      if cell == 1 then
        map:insert_entity('Wall', x, y)
      elseif cell == 0 then
        map:insert_entity('Floor', x, y)
      end
    end
  end

  -- for x, y in map:for_cells() do
  --   callback(x, y, map.cells[x][y])
  -- end

-- local function draw_heat_map()
--   for i, v in ipairs(heat_map.map) do
--     for i2, v2 in ipairs(v) do
--       if v2 ~= 999 then
--         local color_modifier = v2*5
--         local custom = {
--           color = {
--             math.max(0, (255-color_modifier)/255),
--             0/255,
--             math.max(0, (0+color_modifier)/255),
--             1
--           }
--         }
--         local coloredtile = entities.Coloredtile(custom)
--         spawn_actor(coloredtile, i, i2)
--       end
--     end
--   end
-- end
-- draw_heat_map()

  return map
end




return Level