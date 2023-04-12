--love.math.setRandomSeed(1)
--love.audio.setVolume(0) --gitignore

local Map = require "maps.map"
local Object = require "object"
local vec2 = require "math.vector"
local Clipper = require('maps.clipper.clipper')

local Level = Object:extend()

function Level:__new()
  self._width = 300
  self._height = 300
  self._map = Map:new(self._width, self._height, 0)
end

function Level:create(callback)
  local map = self._map
  
  local Graph = Object:extend()
  function Graph:__new()
    self.vertices = {}
    self.edges = {}

    return self
  end
  function Graph:add_vertex(parameters)
    local vertex = {
      parameters = parameters,
      chunk = nil,
      outline_edges = nil,
      polygon = nil,
      num_of_points = nil,
      
      edges = {}
    }

    vertex.specify = function(self, specifications)
      self.specifications = specifications

      return self
    end

    table.insert(self.vertices, vertex)
    self.vertices[vertex] = #self.vertices
    
    return vertex
  end
  function Graph:add_edge(meta, ...)
    local vertices = {...}
    for i = 1, #vertices-1 do
      local vertex_1 = vertices[i]
      local vertex_2 = vertices[i+1]

      table.insert(self.edges, {meta = meta, vertex_1 = vertex_1, vertex_2 = vertex_2})
      table.insert(vertex_1.edges, {meta = meta, vertex = vertex_2})
      table.insert(vertex_2.edges, {meta = meta, vertex = vertex_1})
    end
  end
  function Graph:splice(v1, v2, splicer)
    for _, v in ipairs(v1.edges) do
      if v.vertex == v2 then
        v.vertex = splicer
        break
      end
    end
    for _, v in ipairs(v2.edges) do
      if v.vertex == v1 then
        v.vertex = splicer
        break
      end
    end

    for _, edge in ipairs(self.edges) do
      if (edge.vertex_1 == v1 and edge.vertex_2 == v2) then
        local copy = {meta = edge.meta, vertex_1 = v2, vertex_2 = v1}
        copy.vertex_2 = splicer
        edge.vertex_2 = splicer
        table.insert(self.edges, copy)

        table.insert(splicer.edges, {meta = edge.meta, vertex = v1} )
        table.insert(splicer.edges, {meta = edge.meta, vertex = v2} )
        break
      elseif (edge.vertex_1 == v2 and edge.vertex_2 == v1) then
        v1, v2 = v2, v1
        local copy = {meta = edge.meta, vertex_1 = v2, vertex_2 = v1}
        copy.vertex_2 = splicer
        edge.vertex_2 = splicer
        table.insert(self.edges, copy)

        table.insert(splicer.edges, {meta = edge.meta, vertex = v1} )
        table.insert(splicer.edges, {meta = edge.meta, vertex = v2} )
        break
      end
    end


  end

  local graph = Graph()

  
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

  -- table in, level out
  -- rules
  local function graph_writer(graph)
    local Chunk = require 'maps.chunk'
    local level_specifications = {
      chunk_count = 2
    }

    local shapers = {
      square = function(self, chunk) 
        chunk:clear_rect(0, 0, self.width, self.height) 
      end,
      circle = function(self, chunk)
        local center = vec2(chunk:get_center2())
        chunk:clear_ellipse(center.x, center.y, 2, 2) 
      end,
      funnel = function(self, chunk)
      end,
    }
    local populaters = {
      center = function(self, id, info) 
        local chunk, map, offset, polygon = info.chunk, info.map, info.offset, info.polygon
        local center = vec2(chunk:get_center2()) + offset

        map:insert_entity(id, center.x, center.y)
      end,
      random = function(self, id, info) 
        local chunk, map, offset, polygon = info.chunk, info.map, info.offset, info.polygon
        local center = vec2(chunk:get_center2()) + offset

        local x, y
        repeat 
          x = love.math.random(1, chunk.width-1)
          y = love.math.random(1, chunk.height-1)
        until map:get_cell(x + offset.x, y + offset.y) == 0 and Clipper.PointInPolygon(Clipper.IntPoint(x, y), polygon) == 1
        map:insert_entity(id, x + offset.x, y + offset.y)
      end

    }

    local reference_pool = {}

    local function parameterize_vertex_from_specification(vertex)
      vertex.parameters.parameters = function(self)
        self.width = vertex.specifications.width
        self.height = vertex.specifications.height
      end
      vertex.parameters.shaper = function(self, chunk)
        for i, v in ipairs(vertex.specifications.shape) do
          shapers[v](self, chunk)
        end
      end
      vertex.parameters.populater = function(self, info)
        for i, v in ipairs(vertex.specifications.population) do
          populaters[v.pos](self, v.id, info)
        end
      end
    end

    local function clarify_level_specifications(level_specifications)
      -- how many open tiles are there
      -- what are the qualities of the paths between chunks
      -- direct/winding, narrow/wide, short/long
      -- edge specifications
      -- local a, b, c
      -- edges = { {a} }
      -- patterns
      -- goal patterns, loop patterns


      local start = graph:add_vertex(Chunk:extend()):specify{
        width = 5,
        height = 5,
    
        shape = {'circle'},
    
        population = { {id = 'Player', pos = 'random'},  {id = 'Shortsword', pos = 'random'}}
      }
      
      local finish = graph:add_vertex(Chunk:extend()):specify{
        width = 5,
        height = 5,
    
        shape = {'square'},
    
        population = { {id = 'Stairs', pos = 'random'}}
      }

      graph:add_edge(edges.narrow, start, finish)

      local filler_1 = graph:add_vertex(Chunk:extend()):specify{
        width = 5,
        height = 5,
    
        shape = {'square'},
    
        population = { {id = 'Glowshroom_1', pos = 'random'} }
      }

      local filler_2 = graph:add_vertex(Chunk:extend()):specify{
        width = 5,
        height = 5,
    
        shape = {'square'},
    
        population = { {id = 'Glowshroom_2', pos = 'random'} }
      }

      local filler_3 = graph:add_vertex(Chunk:extend()):specify{
        width = 5,
        height = 5,
    
        shape = {'square'},
    
        population = { {id = 'Sqeeto', pos = 'random'} }
      }

      graph:splice(start, finish, filler_1)
      graph:splice(filler_1, finish, filler_2)
      graph:splice(filler_1, filler_2, filler_3)


      for _, v in ipairs(graph.vertices) do
        parameterize_vertex_from_specification(v)
      end
    end

    clarify_level_specifications(level_specifications)
  end
  graph_writer(graph)


  
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

  chunks.newFiller = chunks.Filler:extend()
  function chunks.newFiller:populater()
  end

  -- local telepad_1_id = id_generator()
  -- local telepad_2_id = id_generator()


  -- local start = graph:add_vertex(chunks.Filler:extend())
  -- function start.parameters:populater(info)
  --   local chunk, map, offset, polygon = info.chunk, info.map, info.offset, info.polygon

  --   local center = vec2(chunk:get_center()) + offset
  --   map:insert_entity('Player', center.x, center.y)

  --   local walls = {'Rocks_1', 'Rocks_2', 'Rocks_3'}
  --   for x, y, cell in chunk:for_cells() do
  --     if map:get_cell(x + offset.x, y + offset.y) == 1 and Clipper.PointInPolygon(Clipper.IntPoint(x, y), polygon) == -1 then
  --       local x, y = x + offset.x, y + offset.y
  --       map:insert_entity(walls[love.math.random(1, 3)], x, y)
  --     end
  --   end
  -- end

  -- Portal

  -- local portal_room_1 = graph:add_vertex(chunks.Filler:extend())
  -- function portal_room_1.parameters:populater(info)
  --   local chunk, map, offset, polygon = info.chunk, info.map, info.offset, info.polygon

  --   local center = vec2(chunk:get_center()) + offset
  --   map:insert_entity('Telepad', center.x-1, center.y, function(entity, entities_by_unique_id)
  --     if entities_by_unique_id[telepad_1_id] then
  --       local destination = entities_by_unique_id[telepad_1_id].position
  --       entity.teleport_destination = vec2(destination.x, destination.y)
  --     else
  --       status = 'Delay'
  --     end
  --     return status
  --   end, telepad_2_id)
  -- end

  -- local portal_room_2 = graph:add_vertex(chunks.Filler:extend())
  -- function portal_room_2.parameters:populater(info)
  --   local chunk, map, offset, polygon = info.chunk, info.map, info.offset, info.polygon

  --   local center = vec2(chunk:get_center()) + offset
  --   map:insert_entity('Telepad', center.x, center.y, function(entity, entities_by_unique_id)
  --     if entities_by_unique_id[telepad_2_id] then
  --       local destination = entities_by_unique_id[telepad_2_id].position
  --       entity.teleport_destination = vec2(destination.x, destination.y)
  --     else
  --       status = 'Delay'
  --     end
  --     return status
  --   end, telepad_1_id)
  -- end

  -- graph:add_edge(edges.door, start, portal_room_1)

  --

  -- Lake

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

  -- local entrance = graph:add_vertex(chunks.newFiller:extend())
  -- local exit = graph:add_vertex(chunks.newFiller:extend())
  -- local finish = graph:add_vertex(chunks.newFiller:extend())

  -- graph:add_edge(edges.door, start, entrance)
  -- graph:add_edge(edges.wide, entrance, lake)
  -- graph:add_edge(edges.wide, lake, exit)
  -- graph:add_edge(edges.door, exit, finish)

  --

  -- Window Loop

  -- local spider_room = graph:add_vertex(chunks.newFiller:extend())
  -- function spider_room.parameters:populater(info)
  --   local chunk, map, offset, polygon = info.chunk, info.map, info.offset, info.polygon

  --   local center = vec2(chunk:get_center()) + offset
  --   map:insert_entity('Webweaver', center.x, center.y)

  --   local walls = {'Rocks_1', 'Rocks_2', 'Rocks_3'}
  --   for x, y, cell in chunk:for_cells() do
  --     if map:get_cell(x + offset.x, y + offset.y) == 1 and Clipper.PointInPolygon(Clipper.IntPoint(x, y), polygon) == -1 then
  --       local x, y = x + offset.x, y + offset.y
  --       map:insert_entity(walls[love.math.random(1, 3)], x, y)
  --     end
  --   end
  -- end


  -- local filler_1 = graph:add_vertex(chunks.newFiller)
  -- local filler_2 = graph:add_vertex(chunks.newFiller)

  -- graph:add_edge(edges.window, start, spider_room)
  -- graph:add_edge(edges.narrow, start, filler_1)
  -- graph:add_edge(edges.narrow, filler_1, filler_2)
  -- graph:add_edge(edges.door, filler_2, spider_room)

  --


  local merged_room = Map:planar_embedding(graph)
  map:blit(merged_room, 0, 0) 


  local player_pos
  for x, y, v in map.entities.sparsemap:each() do
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

  map:fill_perimeter(0, 0, self._width, self._height)

  -- map:target_perimeter(0, 0, self._width, self._height, function(x, y)
  --   callback(x+1, y+1, map.cells[x][y])
  -- end)

  for x, y, cell in map:for_cells() do
    callback(x+1, y+1, cell)
  end

  -- for x, y, cell in map:for_cells() do
  --   local cell_is_occupied = false
  --   for k, v in pairs(map:get_entities(x, y)) do
  --     if cells[v.id] then
  --       cell_is_occupied = true
  --       break
  --     end
  --   end
  --   if cell_is_occupied == false then
  --     if cell == 1 then
  --       map:insert_entity('Wall', x, y)
  --     elseif cell == 0 then
  --       map:insert_entity('Floor', x, y)
  --     end
  --   end
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