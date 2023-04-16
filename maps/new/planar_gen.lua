--love.math.setRandomSeed(2)
--love.audio.setVolume(0) --gitignore

local Map = require "maps.map"
local Object = require "object"
local vec2 = require "math.vector"
local function point_in_polygon(point, polygon)
  local oddNodes = false
  local j = #polygon
  for i = 1, #polygon do
      if polygon[i].x == point.x and polygon[i].y == point.y then return -1 end
      if (polygon[i].y < point.y and polygon[j].y >= point.y or polygon[j].y < point.y and polygon[i].y >= point.y) then
          if (polygon[i].x + ( point.y - polygon[i].y ) / (polygon[j].y - polygon[i].y) * (polygon[j].x - polygon[i].x) < point.x) then
              oddNodes = not oddNodes;
          end
      end
      j = i;
  end
  return oddNodes and 1 or 0
end
local Bresenham = require 'math.bresenham'

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
  function Graph:get_connected_vertices(vertex)
    local vertices = {}
    for i, v in ipairs(vertex.edges) do
      table.insert(vertices, v.vertex)
    end
    return vertices
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
  edges.empty = {
    type = 'Join', 
    callback = function(chunk, info)
      print(#info.points)
    end
  }
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
  edges.breakable_wall = {
    type = 'Join', 
    callback = function(chunk, info)
      local point = info.points[math.floor(#info.points/2)+1]
      chunk:remove_entities(point.x, point.y)

      chunk:clear_cell(point.x, point.y)
      :clear_cell(point.x+info.slope.y, point.y+info.slope.x)
      :clear_cell(point.x-info.slope.y, point.y-info.slope.x)
      :insert_entity("Breakable_wall", point.x, point.y)
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

  -- rules
  local function graph_writer(graph)
    local Chunk = require 'maps.chunk'
    local level_specifications = {
      chunk_count = 2
    }

    local function get_id(id)
      if type(id) == 'string' then
        return id
      elseif type(id) == 'table' then
        return id[love.math.random(1,#id)]
      end
    end

    local shapers = {
      square = function(self, chunk, info)
        local width = info and info.size or self.width
        local height = info and info.size or self.height

        chunk:clear_rect(0, 0, self.width, self.height)

        --local center = vec2(self.width/2, self.height/2)
        --chunk:clear_rect(math.floor(center.x - width/2), math.floor(center.y - height/2), math.floor(center.x + width/2), math.floor(center.y + height/2))
      end,
      circle = function(self, chunk, info)
        local center = vec2(chunk:get_center2())
        chunk:clear_ellipse(center.x, center.y, info.size, info.size) 
      end,
      funnel = function(self, chunk)
      end,
      DLA1 = function(self, chunk, info)
        chunk:DLAInOut()
      end,
      DLA2 = function(self, chunk, info)
        chunk:DLA()
      end,
      tunnel = function(self, chunk, info)
        local center = vec2(chunk:get_center2())

        local path = chunk:drunkWalk(center.x, center.y,
          function(x, y, i, chunk)  
            return (x == 0 or x == chunk.width or y == 0 or y == chunk.height)
          end
        )
        
        chunk:clear_path(path)
      end,

      tunnel2 = function(self, chunk, info)
        local p = vec2(love.math.random(1, chunk.width-1), love.math.random(1, chunk.height-1))
        local q = vec2(chunk.width-p.x, chunk.height-p.y)

        local line = Bresenham.line(p.x, p.y, q.x, q.y)
        local path = chunk:new_path()
        for i, v in ipairs(line) do
          path:add_point(vec2(v[1], v[2]))
        end

        chunk:target_path(path, function(x, y) 
          chunk:clear_rect(x-1, y-1, x+1, y+1)
        end)
      end
    }
    local populaters = {
      center = function(self, info, id, callback, uuid, meta) 
        local chunk, map, offset, polygon = info.chunk, info.map, info.offset, info.polygon
        local center = vec2(chunk:get_center2()) + offset

        meta.offset = meta.offset or vec2(0,0)

        map:insert_entity(id, center.x+meta.offset.x, center.y+meta.offset.y, callback, uuid)
      end,
      random = function(self, info, id, callback, uuid) 
        local chunk, map, offset, polygon = info.chunk, info.map, info.offset, info.polygon

        local x, y
        repeat 
          x = love.math.random(1, chunk.width-1)
          y = love.math.random(1, chunk.height-1)
        until map:get_cell(x + offset.x, y + offset.y) == 0 and point_in_polygon(vec2(x, y), polygon) == 1

        map:insert_entity(get_id(id), x + offset.x, y + offset.y)
      end,

      perimeter = function(self, info, id, callback, uuid)  
        local chunk, map, offset, polygon = info.chunk, info.map, info.offset, info.polygon

        for x, y, cell in chunk:for_cells() do
          if map:get_cell(x + offset.x, y + offset.y) == 1 and point_in_polygon(vec2(x, y), polygon) == -1 then
            local x, y = x + offset.x, y + offset.y
            map:insert_entity(get_id(id), x, y)
            map:clear_cell(x, y)
          end
        end
      end,

      all_wall = function(self, info, id, callback, uuid) 
        local chunk, map, offset, polygon = info.chunk, info.map, info.offset, info.polygon

        for x, y, cell in chunk:for_cells() do
          if map:get_cell(x + offset.x, y + offset.y) == 1 and point_in_polygon(vec2(x, y), polygon) ~= 0 then
            local x, y = x + offset.x, y + offset.y
            map:insert_entity(get_id(id), x, y)
            --map:clear_cell(x, y)
          end
        end
      end,

      inner_floor = function(self, info, id, callback, uuid) 
        local chunk, map, offset, polygon = info.chunk, info.map, info.offset, info.polygon

        for x, y, cell in chunk:for_cells() do
          if cell == 0 and point_in_polygon(vec2(x, y), polygon) == 1 then
            local x, y = x + offset.x, y + offset.y
            map:insert_entity(id, x, y)
          end
        end
      end,

      bridge = function(self, info, id, callback, uuid) 
        local chunk, map, offset, polygon, vertex, edges_info = info.chunk, info.map, info.offset, info.polygon, info.vertex, info.edges
        local center = vec2(chunk:get_center()) + offset

        local endpoints = {}
        for k, v in ipairs(edges_info[vertex]) do
          local edge = v
          local points = edge.points

          local point = points[math.floor(#points/2)+1]
          table.insert(endpoints, point)
        end

        local paths = {}
        for i, v in ipairs(endpoints) do
          table.insert(paths, map:aStar(v.x, v.y, center.x, center.y))
        end

        
        for _, path in ipairs(paths) do
          local bridge_dir_type = '_v'
          for i2, v2 in ipairs(path.points) do

            if i2 ~= #path.points then
              map:remove_entities(v2.x, v2.y)
              bridge_dir_type = math.abs(path:get_slope(i2, i2+1).x) == 0 and '_v' or '_h'
              map:insert_entity('Bridge'..bridge_dir_type, v2.x, v2.y)
            end
          end
        end

      end,

      heat_map = function(self, info, id, callback, uuid) 
        local chunk, map, offset, polygon, vertex, edges_info = info.chunk, info.map, info.offset, info.polygon, info.vertex, info.edges
        local center = vec2(chunk:get_center()) + offset

        local endpoints = {}
        for k, v in ipairs(edges_info[vertex]) do
          local edge = v
          local points = edge.points

          local point = points[math.floor(#points/2)+1]
          table.insert(endpoints, point)
        end

        local path = map:aStar(endpoints[1].x, endpoints[1].y, endpoints[2].x, endpoints[2].y)

        local heat_path = {}
        for i, v in ipairs(path.points) do
          if i ~= 1 and i ~= #path.points then
            table.insert(heat_path, v - offset)
          end
        end

        local heat_map = Map:new(chunk.width, chunk.height, 0)
        heat_map:blit(chunk, 0, 0)
        local heat_map = heat_map:dijkstra(heat_path, 'vonNeuman')
        local max = 0
        for x, y, cell in heat_map:for_cells() do
          if cell ~= math.huge then
            max = math.max(max, cell)
          end
        end
        print(max)


        local treasure_spots = {}
        for x, y, cell in heat_map:for_cells() do
          if cell >= max - max * .3 and cell ~= math.huge then
            table.insert(treasure_spots, vec2(x + info.offset.x, y + info.offset.y))
          end
        end

        for n = 1, 5 do
          local spot = treasure_spots[love.math.random(1, #treasure_spots)]
          map:insert_entity('Shard', spot.x, spot.y)
        end

      end
    }

    local reference_pool = {}

    local function clarify_level_specifications(level_specifications)
      local function parameterize_vertex_from_specification(vertex)
        vertex.parameters.parameters = function(self)
          self.width = vertex.specifications.width
          self.height = vertex.specifications.height
        end
        vertex.parameters.shaper = function(self, chunk)
          for i, v in ipairs(vertex.specifications.shape) do
            if type(v) == 'function' then 
              v(i, vertex.specifications.shape)
            else
              shapers[v[1]](self, chunk, v[2])
            end
          end
        end
        vertex.parameters.populater = function(self, info)
          for i, v in ipairs(vertex.specifications.population) do
            if type(v) == 'function' then 
              v(i, vertex.specifications.population)
            else
              v.info = v.info or {}
              v.meta = v.meta or {}
              populaters[v.type](self, info, v.id, v.info.callback, v.info.uuid, v.meta)
            end
          end
        end
      end
      -- how many open tiles are there
      -- what are the qualities of the paths between chunks
      -- direct/winding, narrow/wide, short/long
      -- edge specifications
      -- local a, b, c
      -- edges = { {a} }
      -- patterns
      -- goal patterns, loop patterns
      -- what is the entitiy's importance level in its chunk
      -- how accessible should the entity be in its chunk

      local entities = {}
      entities.shopkeep = {
        uuid = id_generator(), 
        callback = function() 
          print('wow')
        end
      }
      entities.product = {
        uuid = id_generator(),
        callback = function(actor, actors_by_unique_id)
          if actors_by_unique_id[entities.shopkeep.uuid] then
            local sellable_component = actor:getComponent(components.Sellable)
            sellable_component:setItem(actors.Bomb())
            sellable_component:setPrice(actors.Shard, 1)

            actor:initialize()

            sellable_component:setShopkeep(actors_by_unique_id[entities.shopkeep.uuid])
          else
            return 'Delay'
          end
        end
      }

      entities.telepad_1 = {
        uuid = id_generator(),
        callback = function(entity, entities_by_unique_id)
          if entities_by_unique_id[entities.telepad_2.uuid] then
            local destination = entities_by_unique_id[entities.telepad_2.uuid].position
            entity.teleport_destination = vec2(destination.x, destination.y)
          else
            return 'Delay'
          end
        end
      }
      entities.telepad_2 = {
        uuid = id_generator(),
        callback = function(entity, entities_by_unique_id)
          if entities_by_unique_id[entities.telepad_1.uuid] then
            local destination = entities_by_unique_id[entities.telepad_1.uuid].position
            entity.teleport_destination = vec2(destination.x, destination.y)
          else
            return 'Delay'
          end
        end
      }

      local current_chunk

      local stack = {}
      function stack.push(v)
        table.insert(stack, v)
      end
      function stack.pop()
        return table.remove(stack)
      end
      function stack.get(i)
        local n = i and #stack - i or #stack
        return stack[n]
      end

      local chunks = {}
      chunks.add_chunk = function(k, v)
        last_chunk, current_chunk = current_chunk, v
        chunks[k] = v
      end


      chunks.add_chunk('start', graph:add_vertex(Chunk:extend()):specify{
        width = 3,
        height = 3,
    
        shape = {
          {'square'}
        },
    
        population = {
          {id = 'Player', type = 'center'},
          {id = {'Rocks_1', 'Rocks_2', 'Rocks_3'}, type = 'all_wall'},
        }
      })
      stack.push(current_chunk)

      chunks.add_chunk('finish', graph:add_vertex(Chunk:extend()):specify{
        width = 3,
        height = 3,

        shape = {
          {'square'}
        },

        population = { 
          {id = 'Stairs', type = 'center'},
          {id = {'Rocks_1', 'Rocks_2', 'Rocks_3'}, type = 'all_wall'},
        }
      })
      graph:add_edge(edges.narrow, stack.get(), current_chunk)

      chunks.add_chunk('entrance', graph:add_vertex(Chunk:extend()):specify{
        width = 15,
        height = 15,

        shape = {
          {'circle', {size = 5}},
          function(i, t)
            for n = 1, 20 do table.insert(t, i+1, {'DLA1'}) end 
          end,
        },
    
        population = { 
          function(i, t)
            for n = 1, 10 do table.insert(t, i+1, {id = {'Glowshroom_1', 'Glowshroom_2'}, type = 'random'}) end 
          end,
          {id = '', type = 'bridge'},
          {id = {'Rocks_1', 'Rocks_2', 'Rocks_3'}, type = 'all_wall'},
        }
      })
      graph:splice(stack.get(), graph:get_connected_vertices(stack.get())[1], current_chunk)
      stack.push(current_chunk)


      chunks.add_chunk('foyer', graph:add_vertex(Chunk:extend()):specify{
        width = 20,
        height = 20,
    
        shape = {
          {'circle', {size = 5}},
          function(i, t)
            for n = 1, 50 do table.insert(t, i+1, {'DLA1'}) end 
          end,
          function(i, t)
            for n = 1, 50 do table.insert(t, i+1, {'DLA2'}) end 
          end,
        },
    
        population = {
          function(i, t)
            for n = 1, 10 do table.insert(t, i+1, {id = {'Glowshroom_1', 'Glowshroom_2'}, type = 'random'}) end 
          end,
          function(i, t)
            for n = 1, 3 do table.insert(t, i+1, {id = 'Sqeeto', type = 'random'}) end 
          end,
          {id = {'Rocks_1', 'Rocks_2', 'Rocks_3'}, type = 'all_wall'},
        }
      })
      graph:splice(stack.get(), graph:get_connected_vertices(stack.get())[2], current_chunk)
      stack.push(current_chunk)

      chunks.add_chunk('shop', graph:add_vertex(Chunk:extend()):specify{
        width = 9,
        height = 9,
    
        shape = {
          {'circle', {size = 3}},
        },
    
        population = {
          {id = {'Bricks_1', 'Bricks_2', 'Bricks_3', 'Bricks_4', 'Bricks_5'}, type = 'all_wall'},
          {id = 'Shopkeep', type = 'center', info = entities.shopkeep, meta = {offset = vec2(0,0)} },
          {id = 'Product', type = 'center', info = entities.product, meta = {offset = vec2(0,2)} },

        }
      })
      graph:add_edge(edges.door, stack.get(), current_chunk)
      stack.push(current_chunk)

      chunks.add_chunk('backroom', graph:add_vertex(Chunk:extend()):specify{
        width = 3,
        height = 3,
    
        shape = {
          {'square', {size = 3}},
        },
    
        population = {
          {id = 'Telepad', type = 'center', info = entities.telepad_1}
        }
      })
      graph:add_edge(edges.breakable_wall, stack.get(), current_chunk)
      stack.pop()

      chunks.add_chunk('prism', graph:add_vertex(Chunk:extend()):specify{
        width = 15,
        height = 15,
    
        shape = {
          {'circle', {size = 5}},
          function(i, t)
            for n = 1, 20 do table.insert(t, i+1, {'DLA1'}) end 
          end,
        },
    
        population = {
          {id = 'Prism', type = 'center'},
          function(i, t)
            for n = 1, 6 do table.insert(t, i+1, {id = 'Sqeeto', type = 'random'}) end 
          end,
          {id = {'Rocks_1', 'Rocks_2', 'Rocks_3'}, type = 'all_wall'},
        }
      })
      graph:add_edge(edges.door, stack.get(), current_chunk)
      stack.push(current_chunk)

      chunks.add_chunk('pit', graph:add_vertex(Chunk:extend()):specify{
        width = 15,
        height = 15,
    
        shape = {
          {'circle', {size = 5}},
          function(i, t)
            for n = 1, 20 do table.insert(t, i+1, {'DLA1'}) end 
          end,
        },
    
        population = {
          {id = 'Pit', type = 'inner_floor'},
          {id = '', type = 'bridge'},
          function(i, t)
            for n = 1, 3 do table.insert(t, i+1, {id = 'Sqeeto', type = 'random'}) end 
          end,
          {id = {'Rocks_1', 'Rocks_2', 'Rocks_3'}, type = 'all_wall'},
        }
      })
      graph:splice(stack.get(1), stack.get(0), current_chunk)
      stack.pop()

      chunks.add_chunk('crystals', graph:add_vertex(Chunk:extend()):specify{
        width = 10,
        height = 10,
    
        shape = {
          {'circle', {size = 3}},
          function(i, t)
            for n = 1, 10 do table.insert(t, i+1, {'DLA1'}) end 
          end,
        },
    
        population = {
          {id = {'Crystals_2', 'Crystals_3', 'Crystals_4', 'Rocks_1', 'Rocks_2', 'Rocks_3'}, type = 'all_wall'},
          {id = 'Crystal', type = 'center'},
          {id = 'Golem', type = 'random'},
          function(i, t)
            for n = 1, 5 do table.insert(t, i+1, {id = 'Shard', type = 'random'}) end 
          end,
        }
      })
      graph:add_edge(edges.narrow, stack.get(), current_chunk)


      chunks.add_chunk('hall', graph:add_vertex(Chunk:extend()):specify{
        width = 30,
        height = 30,
    
        shape = {
          {'tunnel'}
        },
    
        population = {
          {id = {'Rocks_1', 'Rocks_2', 'Rocks_3'}, type = 'all_wall'},
          {id = 'Glowshroom_1', type = 'heat_map'}
        }
      })
      graph:add_edge(edges.narrow, stack.get(), current_chunk)
      stack.push(current_chunk)

      chunks.add_chunk('spider_nest', graph:add_vertex(Chunk:extend()):specify{
        width = 10,
        height = 10,
    
        shape = {
          {'circle', {size = 1}},
          {'tunnel'},
          function(i, t)
            for n = 1, 10 do table.insert(t, i+1, {'DLA2'}) end 
          end,
        },
    
        population = {
          function(i, t)
            for n = 1, 7 do table.insert(t, i+1, {id = {'Bones_1', 'Bones_2', 'Web'}, type = 'random'}) end 
          end,
          {id = 'Webweaver', type = 'random'},
          {id = {'Rocks_1', 'Rocks_2', 'Rocks_3'}, type = 'all_wall'},
        }
      })
      graph:add_edge(edges.door, stack.get(), current_chunk)
      stack.push(current_chunk)

      chunks.add_chunk('backroom', graph:add_vertex(Chunk:extend()):specify{
        width = 3,
        height = 3,
    
        shape = {
          {'square', {size = 3}},
        },
    
        population = {
          {id = 'Telepad', type = 'center', info = entities.telepad_2}
        }
      })
      graph:add_edge(edges.door, stack.get(), current_chunk)
      stack.pop()

      -- chunks.add_chunk('crossroads', graph:add_vertex(Chunk:extend()):specify{
      --   width = 30,
      --   height = 30,
    
      --   shape = {
      --     {'tunnel2'},
      --     {'tunnel2'}
      --   },
    
      --   population = {
      --     {id = {'Rocks_1', 'Rocks_2', 'Rocks_3'}, type = 'all_wall'},
      --   }
      -- })
      -- graph:add_edge(edges.wide, stack.get(), current_chunk)



      for _, v in ipairs(graph.vertices) do
        parameterize_vertex_from_specification(v)
      end
    end

    clarify_level_specifications(level_specifications)
  end
  graph_writer(graph)


  chunks.newFiller = chunks.Filler:extend()
  function chunks.newFiller:populater()
  end

  print('map start')
  local merged_room = Map:planar_embedding(graph)
  map:blit(merged_room, 0, 0)
  print('map made')


  -- local player_pos
  -- for x, y, v in map.entities.sparsemap:each() do
  --   if v.id == 'Player' then
  --     player_pos = v.pos
  --     break
  --   end
  -- end
  -- local heat_map = Map:new(self._width, self._height, 0)
  -- heat_map:blit(map, 0, 0) 
  -- heat_map = heat_map:dijkstra({player_pos}, 'vonNeuman')
  -- for x, y, cell in heat_map:for_cells() do
  --   if cell == math.huge then
  --     map:fill_cell(x, y)
  --   end
  -- end

  map:fill_perimeter(0, 0, self._width, self._height)

  for x, y, cell in map:for_cells() do
    local cell_is_occupied = false
    for entity, _ in pairs(map:get_entities(x, y)) do
      if cells[entity.id] then
        cell_is_occupied = true
        break
      end
    end

    --if cell_is_occupied == false then
      callback(x+1, y+1, cell)
    --end
  end

  -- map:target_perimeter(0, 0, self._width, self._height, function(x, y)
  --   callback(x+1, y+1, 1)
  -- end)

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