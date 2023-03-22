--love.math.setRandomSeed(1)
love.audio.setVolume(0)

local Map = require "maps.map"
local Object = require "object"
local vec2 = require "vector"
local Clipper = require('maps.clipper.clipper')

local Clipper = require('maps.clipper.clipper')

local Level = Object:extend()

function Level:__new()
  self._width = 1000
  self._height = 1000
  self._map = Map:new(1000, 1000, 0)
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




  --[[
  loop[2] = graph:new_node{
    width = 4, height = 4,
    actors = {
      {name = 'Glowshroom', positioning = 'Center'}
    }
  }
  graph:add_node(loop[2])

  loop[3] = graph:new_node{
    width = 4, height = 4,
    actors = {
      {name = 'Stationarytorch', positioning = 'Center'}
    }
  }
  graph:add_node(loop[3])
  --]]

  -- local min, max = 4, 8

  -- local loop = {}
  -- loop[1] = graph:new_node{
  --   width = love.math.random(min, max), height = love.math.random(min, max),
  --   actors = {
  --     {name = 'Player', positioning = 'Center'},
  --     {name = 'Web', positioning = 'Center'},
  --   }
  -- }
  -- graph:add_node(loop[1])

  -- for i = 2, 3 do
  --   loop[i] = graph:new_node{
  --     width = love.math.random(min, max), height = love.math.random(min, max),
  --     actors = {
  --       --{name = 'Stairs', positioning = 'Ce'}
  --     }
  --   }
  --   graph:add_node(loop[i])
  -- end

  -- loop[#loop] = graph:new_node{
  --   width = love.math.random(min, max), height = love.math.random(min, max),
  --   actors = {
  --     {name = 'Stairs', positioning = 'Center'}
  --   }
  -- }
  -- graph:add_node(loop[#loop])

  -- for i, v in ipairs(loop) do
  --   graph:connect_nodes({type='Join'}, v, (loop[i+1] or loop[1] ))
  -- end

  --[[
      graph:add_node(uniques.finish)
  uniques['challenge'] = graph:new_node{
    width = 20, height = 20,
    shaping = function(params, room)
      for i = 1, 2 do
        room:drunkWalk(room.width/2, room.height/2,
          function(x, y, i, room)  
            return (i > 10) or (x < 5 or x > room.width-5 or y < 5 or y > room.height-5)
          end
        )
      end

      for i = 1, 20 do
        room:DLA()
      end
    end,
    actors = {
      {name = 'Webweaver', positioning = 'Center'}
    }
  }
  ]]

  local uniques = {}
  uniques['start'] = graph:new_node{
    width = 4, height = 4,
    shaping = function(params, room)
      clear_ellipse(params.width/2, params.height/2, 1, 1)(params, room)
    end,
    actors = {
      {name = 'Player', positioning = 'Center'}
    }
  }
  graph:add_node(uniques.start)
  uniques['finish'] = graph:new_node{
    width = 4, height = 4, 
    actors = {
      {name = 'Stairs', positioning = 'Center'}
    }
  }
  graph:add_node(uniques.finish)
  uniques['challenge'] = graph:new_node{
    width = 20, height = 20,
    shaping = function(params, room)
      for i = 1, 2 do
        room:drunkWalk(room.width/2, room.height/2,
          function(x, y, i, room)  
            return (i > 10) or (x < 5 or x > room.width-5 or y < 5 or y > room.height-5)
          end
        )
      end

      for i = 1, 20 do
        room:DLA()
      end
    end,
  }
  graph:add_node(uniques.challenge)

  local branches = {}
  branches['reward'] = graph:new_node{
    width = 4, height = 4, 
    actors = {
      {name = 'Prism', positioning = 'Center'}
    }
  }
  --graph:add_node(branches.reward)

  -- local filler = {}
  -- for i = 1, 5 do
  --   filler[i] = graph:new_node{
  --     width = love.math.random(5, 10), height = love.math.random(5, 10), 
  --     actors = {
  --     }
  --   }
  --   graph:add_node(filler[i])
  -- end

  -- for i, v in ipairs(filler) do
  --   local random_connection_index
  --   while true do
  --     random_connection_index = love.math.random(1, #filler)

  --     local already_connected = false
  --     for i2, v2 in ipairs(v.edges) do
  --       if v2 == filler[random_connection_index] then
  --         already_connected = true
  --         break
  --       end
  --     end

  --     if
  --       (graph.nodes[filler[random_connection_index]] ~= v) and
  --       (already_connected == false)
  --     then
  --       break
  --     end
  --   end
  --   graph:connect_nodes({type='Join'}, v, filler[random_connection_index])
  -- end

  -- for k, v in pairs(uniques) do
  --   graph:connect_nodes({type='Join'}, v, filler[love.math.random(1, #filler)])
  -- end



  graph:connect_nodes({type='Join'}, uniques.start, uniques.challenge)
  graph:connect_nodes({type='Join'}, uniques.challenge, uniques.finish)

  --graph:connect_nodes({type='Join'}, uniques.challenge, branches.reward)


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