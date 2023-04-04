--love.math.setRandomSeed(1)
--love.audio.setVolume(0) --gitignore

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
  


  local edge_join_door = {
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

  local edge_join_breakable_wall = {
    type = 'Join', 
    callback = function(chunk, info)
      local point = info.points[1]

      chunk:clear_cell(point.x, point.y)
      :clear_cell(point.x+info.slope.y, point.y+info.slope.x)
      :clear_cell(point.x-info.slope.y, point.y-info.slope.x)
      :insert_entity('Breakable_wall', point.x, point.y)
    end,
  }

  local edge_join_river = {
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

  local edge_join_boss_door = {
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
  
  local filler_vertices = {}
  for i = 1, 4 do
    local t = filler_vertices

    t[i] = graph:add_vertex(chunks.Filler)
    if i > 1 then
      local tunnel = graph:add_vertex(chunks.Tunnel)
      graph:add_edge(edge_join_river, t[i], tunnel, t[love.math.random(1, i-1)])
    end
  end

  local Start = chunks.Start
  Start.key_id = id_generator()
  boss_key_uuid = Start.key_id
  local start = graph:add_vertex(Start)

  local finish = graph:add_vertex(chunks.Finish)
  local sqeeto_hive = graph:add_vertex(chunks.Sqeeto_hive)  
  --local spider_nest = graph:add_vertex(chunks.Spider_nest)
  local shop = graph:add_vertex(chunks.Shop)
  local snip_farm = graph:add_vertex(chunks.Snip_farm)

  graph:add_edge(edge_join_door, start, filler_vertices[love.math.random(1, #filler_vertices)])
  graph:add_edge(edge_join_door, finish, filler_vertices[love.math.random(1, #filler_vertices)])
  graph:add_edge(edge_join_breakable_wall, sqeeto_hive, filler_vertices[love.math.random(1, #filler_vertices)])
  --graph:add_edge(edge_join_boss_door, spider_nest, filler_vertices[love.math.random(1, #filler_vertices)])
  -- graph:add_edge(edge_join_door, shop, filler_vertices[love.math.random(1, #filler_vertices)])
  -- graph:add_edge(edge_join_door, snip_farm, filler_vertices[love.math.random(1, #filler_vertices)])

  local merged_room = Map:planar_embedding(graph)
  map:blit(merged_room, 0, 0) 


  local player_pos
  for k, v in pairs(map.entities.list) do
    if v.id == 'Player' then
      player_pos = v.pos
      break
    end
  end


  local heat_map = Map:new(500, 500, 0)
  heat_map:blit(map, 0, 0) 
  heat_map = heat_map:dijkstra({player_pos}, 'vonNeuman')
  for x, y, cell in heat_map:for_cells() do
    if cell == 999 then
      --map:fill_cell(x, y)
    end
  end


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