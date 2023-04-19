--love.math.setRandomSeed(1)
--love.audio.setVolume(0)

local Map = require "maps.map"
local Object = require "object"
local vec2 = require "math.vector"
local Clipper = require "maps.clipper.clipper"

local Level = Object:extend()

function Level:__new()
   self._width = 600
   self._height = 600
   self._map = Map:new(600, 600, 0)
end

function Level:create(callback)
   local map = self._map

   local graph = {
      nodes = {},
      edges = {},
   }
   function graph:add_node(parameters)
      local node = {
         parameters = parameters,
         chunk = nil,
         edges = {},
      }

      table.insert(self.nodes, node)
      self.nodes[node] = #self.nodes

      return node
   end
   function graph:connect_nodes(meta, ...)
      local nodes = { ... }
      for i = 1, #nodes - 1 do
         table.insert(nodes[i].edges, { meta = meta, node = nodes[i + 1] })
         table.insert(nodes[i + 1].edges, { meta = meta, node = nodes[i] })
      end
   end

   local Chunk = require "maps.chunk"
   local id_generator = require "maps.uuid"

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

   local Start = chunks.Start
   Start.key_id = id_generator()
   boss_key_uuid = Start.key_id
   local start = graph:add_node(Start)

   local finish = graph:add_node(chunks.Finish)
   local sqeeto_hive = graph:add_node(chunks.Sqeeto_hive)
   local spider_nest = graph:add_node(chunks.Spider_nest)
   local shop = graph:add_node(chunks.Shop)
   local snip_farm = graph:add_node(chunks.Snip_farm)

   local encounters = {
      { cr = 1, actors = { "sqeeto" } },
      { cr = 2, actors = { "lizbop" } },
      { cr = 3, actors = { "Webweaver" } },
   }

   local edge_join_door = {
      type = "Join",
      callback = function(chunk, info)
         local connection_point = vec2(info.match_point_2.x, info.match_point_2.y)
            + info.offset
            + info.clip_dimension_sum
         local x, y = connection_point.x, connection_point.y

         chunk
            :clear_cell(x, y)
            :clear_cell(x + info.vec[2], y + info.vec[1])
            :clear_cell(x - info.vec[2], y - info.vec[1])
            :insert_actor("Door", x, y)
      end,
   }

   local edge_join_breakable_wall = {
      type = "Join",
      callback = function(chunk, info)
         local connection_point = vec2(info.match_point_2.x, info.match_point_2.y)
            + info.offset
            + info.clip_dimension_sum
         local x, y = connection_point.x, connection_point.y

         chunk
            :clear_cell(x, y)
            :clear_cell(x + info.vec[2], y + info.vec[1])
            :clear_cell(x - info.vec[2], y - info.vec[1])
            :insert_actor("Breakable_wall", x, y)
      end,
   }

   local edge_join_river = {
      type = "Join",
      callback = function(chunk, info)
         local connection_point = vec2(info.match_point_2.x, info.match_point_2.y)
            + info.offset
            + info.clip_dimension_sum
         local x, y = connection_point.x, connection_point.y
         local bridge_dir_type = info.vec[1] == 1 and "_v" or "_h"
         local river_dir_type = info.vec[1] == 0 and "_v" or "_h"

         local segment_index = info.segment_index_2
         local point = vec2(info.segment_2[segment_index].x, info.segment_2[segment_index].y)
         point = point + info.offset + info.clip_dimension_sum
         chunk
            :clear_cell(point.x, point.y)
            :clear_cell(point.x + info.vec[2], point.y + info.vec[1])
            :clear_cell(point.x - info.vec[2], point.y + info.vec[1])
         chunk:insert_actor("Bridge" .. bridge_dir_type, point.x, point.y)

         for n = 1, 1 do
            local segment_index = info.segment_index_2 - n
            if segment_index ~= 1 then
               local point = vec2(info.segment_2[segment_index].x, info.segment_2[segment_index].y)
               point = point + info.offset + info.clip_dimension_sum
               chunk:clear_cell(point.x, point.y)
               chunk:insert_actor("River" .. river_dir_type, point.x, point.y)
            end

            local segment_index = info.segment_index_2 + n
            if segment_index ~= #info.segment_2 then
               local point = vec2(info.segment_2[segment_index].x, info.segment_2[segment_index].y)
               point = point + info.offset + info.clip_dimension_sum
               chunk:clear_cell(point.x, point.y)
               chunk:insert_actor("River" .. river_dir_type, point.x, point.y)
            end
         end

         -- chunk:clear_cell(x, y)
      end,
   }

   local edge_join_boss_door = {
      type = "Join",
      callback = function(chunk, info)
         local connection_point = vec2(info.match_point_2.x, info.match_point_2.y)
            + info.offset
            + info.clip_dimension_sum
         local x, y = connection_point.x, connection_point.y

         chunk
            :clear_cell(x, y)
            :clear_cell(x + info.vec[2], y + info.vec[1])
            :clear_cell(x - info.vec[2], y - info.vec[1])
            :insert_actor("Door_locked", x, y, function(actor, actors_by_unique_id)
               if not actors_by_unique_id[boss_key_uuid] then return "Delay" end
               local chest_lock = actor:getComponent(components.Lock_id)
               chest_lock:setKey(actors_by_unique_id[boss_key_uuid])
            end)
      end,
   }

   local filler_nodes = {}
   for i = 1, 4 do
      filler_nodes[i] = graph:add_node(chunks.Hallway)

      if i > 1 then
         local tunnel = graph:add_node(chunks.Tunnel)

         graph:connect_nodes(
            edge_join_river,
            filler_nodes[i],
            tunnel,
            filler_nodes[love.math.random(1, i - 1)]
         )
      end
   end

   graph:connect_nodes(edge_join_door, start, filler_nodes[love.math.random(1, #filler_nodes)])
   graph:connect_nodes(edge_join_door, finish, filler_nodes[love.math.random(1, #filler_nodes)])
   graph:connect_nodes(
      edge_join_breakable_wall,
      sqeeto_hive,
      filler_nodes[love.math.random(1, #filler_nodes)]
   )
   graph:connect_nodes(
      edge_join_boss_door,
      spider_nest,
      filler_nodes[love.math.random(1, #filler_nodes)]
   )
   graph:connect_nodes(edge_join_door, shop, filler_nodes[love.math.random(1, #filler_nodes)])
   graph:connect_nodes(edge_join_door, snip_farm, filler_nodes[love.math.random(1, #filler_nodes)])

   local merged_room_3 = Map:special_merge(graph)
   map:blit(merged_room_3, 0, 0)

   local player_pos
   for i, v in ipairs(map.actors.list) do
      if v.id == "Player" then
         player_pos = v.pos
         break
      end
   end

   -- for x, y, cell in map:for_cells() do
   --   if cell == 1 then
   --     map:insert_actor('Wall', x, y)
   --     map:clear_cell(x, y)
   --   end
   -- end

   local heat_map = Map:new(600, 600, 0)
   heat_map:blit(map, 0, 0)
   heat_map = heat_map:dijkstra({ player_pos }, "vonNeuman")
   for x, y, cell in heat_map:for_cells() do
      if cell == 999 then map:fill_cell(x, y) end
   end

   for x, y in map:for_cells() do
      callback(x + 1, y + 1, map.cells[x][y])
   end

   return map, heat_map, rooms
end

return Level
