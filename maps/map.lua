local Object = require "object"
local Map = Object:extend()

local vec2 = require "math.vector"

local lib_path = love.filesystem.getSource() .. '/maps/clipper'
local extension = jit.os == 'Windows' and 'dll' or jit.os == 'Linux' and 'so' or jit.os == 'OSX' and 'dylib'
package.cpath = string.format('%s;%s/?.%s', package.cpath, lib_path, extension)
local Clipper = require('maps.clipper.clipper')

local tablex = require 'lib.batteries.tablex'

local id_generator = require 'maps.uuid'

function Map:new(width, height, value)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o:init(width, height, value)
  return o
end

function Map:init(width, height, value)
  local map = {}
  
  for x = 0, width do
    map[x] = {}
    for y = 0, height do
      map[x][y] = value
    end
  end
  
  self.actors = {
    list = {},
    position_key = {}
  }
  self.map = map
  self.cells = map
  self.width = width
  self.height = height
end

function Map:insert_actor(actor_id, x, y, callback, unique_id)
  local position = vec2(x, y)
  local unique_id = unique_id or id_generator()
  table.insert(self.actors.list, {id = actor_id, unique_id = unique_id, pos = position, callback = callback})
  
  return self, unique_id
end

function Map:for_cells()
  local x = 0
  local y = -1
  
  return function ()
    if y < self.height then
      y = y + 1
    elseif y == self.height then
      y = 0
      x = x + 1
    end
    
    if x <= self.width then
      return x, y, self.cells[x][y]
    end
  end
end

function Map:get_random_open_tile()
  local x, y = math.random(0, self.width), math.random(0, self.height)

  while self:get_cell(x, y) ~= 0 do
    x, y = math.random(0, self.width), math.random(0, self.height)
  end

  return x, y
end

function Map:get_random_closed_tile()
  local x, y = math.random(0, self.width), math.random(0, self.height)

  while self:get_cell(x, y) == 0 do
    --print("SEARCHING FOR CLOSED TILE", x, y)
    x, y = math.random(0, self.width), math.random(0, self.height)
  end

  return x, y
end

-- Merging
function Map:blit(map, x, y, is_destructive, mask)
  local mask = mask or 0
  for i = x, x+map.width do
    for i2 = y, y+map.height do
      if is_destructive or (self:get_cell(i, i2) == mask) then
        self:set_cell_checked(i, i2, map:get_cell(i-x, i2-y))
      end
    end
  end
  
  local copy = tablex.deep_copy(map.actors.list)
  for i, v in ipairs(copy) do
    v.pos = v.pos + vec2(x, y)
  end
  self.actors.list = tablex.append(self.actors.list, copy)
  return self
end

function Map:check_overlap(map, x, y)
  for i = x, x + map.width do
    for j = y, y + map.height do
      if self:get_cell(i, j) and map:get_cell(i - x, j - y) then
        local currentCell = self:get_cell(i, j)
        local mapCell = map:get_cell(i - x, j - y)

        if currentCell == 0 and mapCell == 0 then
          return true
        end
      else
        return true
      end
    end
  end
  return false
end

function Map:check_adjacency(map, x, y)
  local hasOverlap = false
  local door_candidates = {}

  -- does the map overlap with our current map?
  if self:check_overlap(map, x, y) then
    return false
  end

  -- loop through each tile in the map
  for i = x, x + map.width do
    for j = y, y + map.height do
      -- get the current cell and the cell in the map
      local currentCell = self:get_cell(i, j)
      local mapCell = map:get_cell(i - x, j - y)

      local neighbors = {
        vec2(0, 1),
        vec2(0, -1),
        vec2(1, 0),
        vec2(-1, 0),
        vec2(1, 1),
        vec2(-1, -1),
        vec2(1, -1),
        vec2(-1, 1),
      }

      -- if our current cell is a floor tile and it neighbours a floor tile
      -- on the map then we should reject it
      if mapCell == 0 then
        for _, offset in ipairs(neighbors) do
          local ni = i + offset.x
          local nj = j + offset.y

          local neighbour = self:get_cell(ni, nj)

          if neighbour == 0 then
            hasOverlap = true
          end
        end
      end

      if mapCell == 1 and currentCell == 1 then
        local offsets = {
          vec2(0, 1),
          vec2(0, -1),
          vec2(1, 0),
          vec2(-1, 0)
        }

        for _, offset in ipairs(offsets) do
          local ni = i + offset.x
          local nj = j + offset.y

          local ni1 = i - offset.x
          local nj1 = j - offset.y

          local neighborCurrentCell = self:get_cell(ni, nj)
          local neighborMapCell = map:get_cell(ni1 - x, nj1 - y)

          if neighborCurrentCell == 0 and neighborMapCell == 0 then
            table.insert(door_candidates, {i, j})
          end
        end
      end
    end
  end


  local hasAdjacentWall = table.remove(door_candidates, math.random(1, #door_candidates))
  if not hasOverlap and hasAdjacentWall then
    return hasAdjacentWall
  end
end


function Map:room_accretion(map, open_tile, wall_tile)
  local open_tile = open_tile or 0
  local wall_tile = wall_tile or 1
  local placed = false

  -- Find all possible starting positions
  local possible_positions = {}
  for x = 1, self.height do
    for y = 1, self.width do
      table.insert(possible_positions, {x, y})
    end
  end

  -- Shuffle the possible_positions list using the Fisher-Yates algorithm
  for i = #possible_positions, 2, -1 do
    local j = math.random(1, i)
    if not possible_positions[i] or not possible_positions[j] then
      print(i, j)
    end
    possible_positions[i], possible_positions[j] = possible_positions[j], possible_positions[i]
  end
  
  -- Iterate through the shuffled positions and try to place the map
  local attempts = 0
  while attempts < 100 and not placed do
    attempts = attempts + 1

    local x, y = unpack(table.remove(possible_positions, math.random(1, #possible_positions)))

    local adjacent = self:check_adjacency(map, x, y)

    if adjacent then
      self:blit(map, x, y, false, 1)

      local roomTiles = {}
      for i = x, x + map.width do
        for j = y, y + map.height do
          if map:get_cell(i - x, j - y) == 0 then
            table.insert(roomTiles, {i, j})
          end
        end
      end

      return roomTiles, adjacent
    end
  end
end

function Map:from_chunk(chunk)
  chunk:parameters()
  local map = Map:new(chunk.width, chunk.height, 1)
  chunk:shaper(map)
  chunk:populater(map)

  return map
end

function Map:special_merge(graph)
  local function new_chunk(params)
    params:parameters()
    local chunk = Map:new(params.width, params.height, 1)
    
    params:shaper(chunk)
    
    return chunk:new_from_outline()
  end
  
  local strict_outlines = {}
  local edges = {}
  local paths = {}
  for _, v in ipairs(graph.nodes) do
    v.chunk = new_chunk(v.parameters)
    
    local outline = v.chunk:new_from_outline_strict()
    table.insert(strict_outlines, outline)
    
    local edge = outline:find_edges()
    table.insert(edges, edge)
    
    local num_of_points = 0
    for _, v2 in ipairs(edge) do
      for _, v3 in ipairs(v2) do
        num_of_points = num_of_points + 1
      end
    end
    
    local path = Clipper.Path(num_of_points)
    local i = 0
    for _, v2 in ipairs(edge) do
      for _, v3 in ipairs(v2) do
        path[i] = Clipper.IntPoint(v3.x, v3.y)
        i = i + 1
      end
    end
    table.insert(paths, path)
    
    v.parameters.populater(v.parameters, v.chunk, path)
  end
  
  local function get_matching_edges(edges1, edges2)
    local matches = {}
    for _, edge1 in ipairs(edges1) do
      for _, edge2 in ipairs(edges2) do
        local p1, q1 = edge1[1], edge1[#edge1]
        local p2, q2 = edge2[1], edge2[#edge2]
        
        local dx1, dy1 = p1.x - q1.x, p1.y - q1.y
        local dx2, dy2 = p2.x - q2.x, p2.y - q2.y
        
        if math.sign(dx1) == -math.sign(dx2) and math.sign(dy1) == -math.sign(dy2) then
          if #edge1 > 2 and #edge2 > 2 then
            table.insert(matches, {edge1, edge2})
          end
        end
      end
    end
    
    return matches
  end
  
  local function does_intersect(subject, clip, num_of_points, offset)
    local offset_clip = Clipper.Path(num_of_points)
    for i = 0, num_of_points-1 do
      offset_clip[i] = Clipper.IntPoint(clip[i].X + offset.x, clip[i].Y + offset.y)
    end
    
    local solution = Clipper.Paths(1)
    
    local clipper = Clipper.Clipper()
    clipper:AddPath(subject, Clipper.ptSubject, true)
    clipper:AddPath(offset_clip, Clipper.ptClip, true)
    clipper:Execute(Clipper.ctUnion, solution)
    
    local is_intersect = (Clipper.Area(solution[0]) ~= Clipper.Area(subject)+Clipper.Area(offset_clip))
    
    return is_intersect, offset_clip
  end

  local function find_valid_matches(node_index1, node_index2, edge_meta_info)
    local matches = get_matching_edges(edges[node_index1], edges[node_index2])
    local matches_without_intersections = {}
    
    local num_of_points = 0
    for i, v in ipairs(edges[node_index2]) do
      for i2, v2 in ipairs(v) do
        num_of_points = num_of_points + 1
      end
    end
    
    for _, v in ipairs(matches) do
      for i = 2, #v[1]-1 do
        for i2 = 2, #v[2]-1 do
          local segment_index_1 = i
          local segment_index_2 = i2
          
          local offset = vec2(v[1][segment_index_1].x - v[2][segment_index_2].x, v[1][segment_index_1].y - v[2][segment_index_2].y)
          local connection_point_1 = vec2(v[1][segment_index_1].x, v[1][segment_index_1].y)
          local connection_point_2 = vec2(v[2][segment_index_2].x, v[2][segment_index_2].y)
          local is_intersect, offset_clip = does_intersect(paths[node_index1], paths[node_index2], num_of_points, offset)
          if (not is_intersect) then
            table.insert(matches_without_intersections, {
              v, segment_index_1, segment_index_2, offset_clip, node_index2, offset, num_of_points, connection_point_1, connection_point_2,
              
              segment_index_1 = segment_index_1,
              segment_index_2 = segment_index_2,
              
              offset = offset,
              offset_clip = offset_clip,
              clip = paths[node_index2],
              num_of_points = num_of_points,
              edge_meta_info = edge_meta_info
              
            })
          end
          
          --::continue::
        end
      end
    end
    
    local matches = matches_without_intersections
    assert(#matches > 0, "no matches found")
    return matches
  end
  
  local function solve_for_room_positions()
    local function build_queue_and_matches()
      local travelled = {[graph.nodes[1]] = true}
      local matches = {}
      local queue = {{parent = nil, self = graph.nodes[1]}}
      
      local function recursion(node)
        for i, v in ipairs(node.edges) do
          if (not travelled[v.node]) and v.meta.type == 'Join' then
            travelled[v.node] = true
            table.insert(queue, {parent = node, self = v.node})
            matches[tostring(node)..' '..tostring(v.node)] = find_valid_matches(graph.nodes[node], graph.nodes[v.node], v.meta)
            recursion(v.node)
          end
        end
      end
      recursion(graph.nodes[1])
      
      return queue, matches
    end
    
    local function build_clip_sets(queue, matches)
      local offsets = {}
      local clip_buffer = {}
      local input_matches = {}
      
      local exit = false
      
      local cycles = 0
      local function recursion(n)
        if exit then goto exit end
        if n ~= #queue+1 then
          --cycles = cycles + 1
          --print(cycles, n)
          local node, parent = queue[n].self, queue[n].parent
          local parent_offset = offsets[parent] or vec2(0, 0)
          local match = {}
          if parent ~= nil then
            match = matches[tostring(parent)..' '..tostring(node)]
          else
            clip_buffer[n] = node
            recursion(n+1)
          end
          
          local function rpairs(t)
            local total = #t
            
            return function()
              if total > 0 then
                local r = math.random(total)
                local v = t[r]
                
                t[r], t[total] = t[total], t[r]
                total = total - 1
                
                return v
              end
            end
          end
          
          for v2 in rpairs(match) do
            local clip = tablex.copy(v2)
            
            clip.offset_clip = Clipper.Path(clip.num_of_points)
            
            local offset = parent_offset
            clip.offset, offset = clip.offset + offset, offset + clip.offset
            offsets[node] = offset
            for i3 = 0, clip.num_of_points-1 do
              clip.offset_clip[i3] = Clipper.IntPoint(clip.clip[i3].X + offset.x, clip.clip[i3].Y + offset.y)
            end
            clip_buffer[n] = clip
            
            
            local clips = clip_buffer
            local clipper = Clipper.Clipper()
            local subject = paths[graph.nodes[clips[1]]]
            clipper:AddPath(subject, Clipper.ptSubject, true)
            for i = 2, n do
              clipper:AddPath(clips[i].offset_clip, Clipper.ptClip, true)
            end
            local solution = Clipper.Paths(1)
            clipper:Execute(Clipper.ctUnion, solution)
            
            local sum = Clipper.Area(subject)
            for i = 2, n do
              sum = sum + Clipper.Area(clips[i].offset_clip)
            end
            
            if Clipper.Area(solution[0]) == sum then
              recursion(n+1)
            end
          end
        else
          table.insert(input_matches, tablex.copy(clip_buffer))
          exit = true
        end
        
        ::exit::
      end
      recursion(1)
      
      return input_matches
    end
    
    return build_clip_sets(build_queue_and_matches())
  end

  local start = love.timer.getTime()
  local matches, loop_points = solve_for_room_positions()
  local match_index = 1
  local connections = {}
  assert(#matches > 0, 'no complex matches!')
  
  print((love.timer.getTime() - start) * 100)
  
  local clip_width_sum, clip_height_sum = 0, 0
  for i, v in ipairs(graph.nodes) do
    clip_width_sum = clip_width_sum + v.chunk.width
    clip_height_sum = clip_height_sum + v.chunk.height
  end
  local clip_dimension_sum = vec2(clip_width_sum, clip_height_sum)
  
  local map = Map:new(clip_width_sum*2, clip_height_sum*2, 0)
  
  map:blit(matches[match_index][1].chunk, clip_width_sum, clip_height_sum, false)
  for i = 2, #matches[match_index] do
    local match = matches[match_index][i]
    local segment_index_1 = match.segment_index_1
    local segment_index_2 = match.segment_index_2
    local vec = match[1][1].vec
    local offset = match.offset
    local connection_point = match[8]
    
    table.insert(connections, {
      segment_1 = match[1][1],
      segment_2 = match[1][2],
      
      segment_index_1 = segment_index_1,
      segment_index_2 = segment_index_2,
      
      match_point_1 = match[1][1][segment_index_1],
      match_point_2 = match[1][2][segment_index_2],
      
      offset = vec2(offset.x, offset.y),
      clip_dimension_sum = clip_dimension_sum,
      
      vec = vec,
      edge_meta_info = match.edge_meta_info,
    })
    map:blit(graph.nodes[match[5]].chunk, offset.x+clip_width_sum, offset.y+clip_height_sum, false)
  end
  
  for i, v in ipairs(connections) do
    v.edge_meta_info.callback(map, v)
  end

  return map
end

function Map:get_padding()
  local padding_left, padding_right = 0, 0
  local padding_top, padding_bottom = 0, 0
  
  for x = 0, self.width do
    local binary = false
    for y = 0, self.height do
      if self:get_cell(x, y) == 1 then
        binary = true
        break
      end
    end
    if binary == true then
      break
    end
    padding_left = padding_left + 1
  end
  
  for x = self.width, 0, -1 do
    local binary = false
    for y = 0, self.height do
      if self:get_cell(x, y) == 1 then
        binary = true
        break
      end
    end
    if binary == true then
      break
    end
    padding_right = padding_right + 1
  end
  
  for y = 0, self.height do
    local binary = false
    for x = 0, self.width do
      if self:get_cell(x, y) == 1 then
        binary = true
        break
      end
    end
    if binary == true then
      break
    end
    padding_top = padding_top + 1
  end
  
  for y = self.height, 0, -1 do
    local binary = false
    for x = 0, self.width do
      if self:get_cell(x, y) == 1 then
        binary = true
        break
      end
    end
    if binary == true then
      break
    end
    padding_bottom = padding_bottom + 1
  end
  
  return padding_left, padding_right, padding_top, padding_bottom
end

function Map:new_from_trim_edges(left, right, top, bottom)
  local map = Map:new(self.width-(left+right), self.height-(top+bottom), 0)
  
  for x = left, self.width-right do
    for y = top, self.height-bottom do
      map:set_cell(x-left, y-top, self:get_cell(x, y))
    end
  end
  
  local copy = tablex.deep_copy(self.actors.list)
  for i, v in ipairs(copy) do
    v.pos = v.pos - vec2(left, top)
  end
  map.actors.list = copy
  
  return map
end

function Map:new_from_outline()
  local padding = 1
  local offset = vec2(padding, padding)
  local outline_map = Map:new(self.width+padding*2, self.height+padding*2, 1)
  :blit(self, padding, padding, true)
  
  
  for x, y in outline_map:for_cells() do
    local is_adjacent_to_air = false
    for k, v in pairs(Map:getNeighborhood('moore')) do
      if outline_map:get_cell(x+v[1], y+v[2]) == 0 then
        is_adjacent_to_air = true
        break
      end
    end
    
    if not is_adjacent_to_air then
      outline_map:set_cell(x, y, 999) -- dummy value
    end
  end
  
  for x, y in outline_map:for_cells() do
    if outline_map:get_cell(x, y) == 999 then
      outline_map:set_cell(x, y, 0)
    end
  end
  
  return outline_map, offset
end

function Map:new_from_outline_strict()
  local outline_map = Map:new(self.width, self.height, 0)
  
  local to_check = {{0,0}}
  local checked = {}
  while true do
    
    local current_tile = table.remove(to_check)
    local x, y = current_tile[1], current_tile[2]
    
    for k, v in pairs(Map:getNeighborhood('moore')) do
      local x, y = x+v[1], y+v[2]    
      if not checked[tostring(x)..','..tostring(y)] then
        if self:get_cell(x, y) == 0 then
          table.insert(to_check, {x, y})
        elseif self:get_cell(x, y) == 1 then
          outline_map:fill_cell(x, y)
        end
      end
    end
    
    checked[tostring(x)..','..tostring(y)] = true
    
    
    if #to_check == 0 then
      break
    end 
  end
  
  return outline_map
end

function Map:find_edges()
  
  local startPos
  for x, y in self:for_cells() do
    if self:get_cell(x, y) == 1 then
      startPos = {x=x, y=y}
    end
  end
  
  local edges = {{startPos}}
  
  local moore = Map:getNeighborhood('moore')
  local vonNeuman = Map:getNeighborhood('vonNeuman')
  local winding = {vonNeuman.e, vonNeuman.s, vonNeuman.w, vonNeuman.n}
  --local winding = {moore.e, moore.se, moore.s, moore.sw, moore.w, moore.nw, moore.n, moore.ne}
  
  while true do
    local edge = edges[#edges] -- Current edge is the last element
    local start = edge[1] -- Starting position is the first element
    for i, v in ipairs(winding) do
      if #edges == 1 or -- If there's only one edge
      not ( (v[1] == edges[#edges-1].vec[1] * -1) and (v[2] == edges[#edges-1].vec[2] * -1)) -- if not the direction we came from
      then
        local x, y = start.x+v[1], start.y+v[2] -- Check from the starting point + a neighbor
        if self:get_cell(x, y) == 1 then -- If that pos is a wall
          edge.vec = {v[1],v[2]} -- Define the edges vector as the neighbor direction
          table.insert(edge, {x=x,y=y}) -- insert the position
          break
        end
      end
    end
    
    repeat -- keep going until you run out of map or reach an empty space
    local x = edge[#edge].x + edge.vec[1]
    local y = edge[#edge].y + edge.vec[2]
    
    if self:get_cell(x, y) == 1 then
      table.insert(edge, {x=x,y=y})
    end
  until self:get_cell(x, y) ~= 1 
  
  if -- if you reach the starting position you've done a full loop
  edge[#edge].x == startPos.x and
  edge[#edge].y == startPos.y
  then
    break
  end
  
  table.insert(edges, {edge[#edge]})
end


return edges
end

-- -------------------------------------------------------------------------- --

function Map:get_center()
  return math.floor(self.width/2), math.floor(self.height/2)
end

function Map:get_center2()
  return math.ceil(self.width/2), math.ceil(self.height/2)
end

function Map:get_cell(x, y)
  return self.cells[x] and self.cells[x][y] or nil
end

function Map:set_cell(x, y, v)
  self.cells[x][y] = v
end

function Map:set_cell_checked(x, y, v)
  if self.cells[x] and self.cells[x][y] then
    self:set_cell(x, y, v)
  end
end

--Space
function Map:clear_cell(x,y)
  self.cells[x][y] = 0
  
  return self
end

function Map:clear_cell_checked(x, y)
  if self.map[x] and self.map[x][y] then
    self:clear_cell(x, y)
  end
  
  return self
end

function Map:fill_cell(x,y)
  self.cells[x][y] = 1
  
  return self
end


-- Rect
function Map:target_rect(x1,y1, x2,y2, func)
  for x = x1, x2 do
    for y = y1, y2 do
      func(x, y)
    end
  end
  
  return self
end

function Map:clear_rect(x1,y1, x2,y2)
    self:target_rect(
    x1,y1, x2,y2,
    function(x,y)
      self:clear_cell(x,y)
    end
  )

  return self
end

function Map:fill_rect(x1,y1, x2,y2)
  self:target_rect(
    x1,y1, x2,y2,
    function(x,y)
      self:fill_cell(x,y)
    end
  )

  return self
end

-- Perimeter
function Map:target_perimeter(x1,y1, x2,y2, func)
  Map:target_rect(
  x1,y1, x2,y2,
  function(x,y)
    if x==x1 or x==x2 or y==y1 or y==y2 then
      func(x, y)
    end
  end
)
  return self
end
function Map:clear_perimeter(x1,y1, x2,y2)
  Map:target_perimeter(
  x1,y1, x2,y2,
  function(x,y)
    self:clear_cell(x, y)
  end
)
  return self
end
function Map:fill_perimeter(x1,y1, x2,y2)
  Map:target_perimeter(
  x1,y1, x2,y2,
  function(x,y)
    self:fill_cell(x, y)
  end
)
  return self
end

-- Ellipse
function Map:target_ellipse(cx, cy, radx, rady, func)
  for x = cx-radx, cx+radx do
    for y = cy-rady, cy+rady do
      local dx = (x - cx)^2
      local dy = (y - cy)^2
      if dx/(radx^2) + dy/(rady)^2 <= 1 then
        func(x, y)
      end
      
    end
  end
  
  return self
end
function Map:clear_ellipse(cx, cy, radx, rady)
  self:target_ellipse(
  cx, cy, radx, rady,
  function(x,y)
    self:clear_cell(x,y)
  end
)

return self
end
function Map:fill_ellipse(cx, cy, radx, rady)
  self:target_ellipse(
  cx, cy, radx, rady,
  function(x,y)
    self:fill_cell(x,y)
  end
)

return self
end

-- Circumference
function Map:target_circumference(cx, cy, radx, rady, func)
  Map:target_ellipse(cx, cy, radx, rady, function(x, y)
    local dx = (x - cx)^2
    local dy = (y - cy)^2
    print(dx/(radx^2) + dy/(rady)^2)
    if dx/(radx^2) + dy/(rady)^2 >= 0.5 then
      func(x, y)
    end
  end)
  
  return self
end
function Map:clear_circumference(cx, cy, radx, rady)
  self:target_circumference(
  cx, cy, radx, rady,
  function(x,y)
    self:clear_cell(x,y)
  end
)

return self
end
function Map:fill_circumference(cx, cy, radx, rady)
  self:target_circumference(
  cx, cy, radx, rady,
  function(x,y)
    self:clear_cell(x,y)
  end
)

return self
end

-- Path
function Map:new_path()
  local path = {
    points = {}
  }
  function path:add_point(vec)
    table.insert(self.points, vec)
  end
  
  return path
end
function Map:target_path(path, func)
  for i = 1, #path.points do
    local x, y = path.points[i].x, path.points[i].y
    func(x, y)
  end
  
  return self
end
function Map:clear_path(path)
  self:target_path(
  path,
  function(x,y)
    self:clear_cell(x,y)
  end
)
return self
end
function Map:fill_path(path)
  self:target_path(
  path,
  function(x,y)
    self:fill_cell(x,y)
  end
)
return self
end

--ProcMap
function Map:rollGrowthPotential(cell, probability, max, min)
  local size = min or 1
  
  while size < max do
    if love.math.random() <= probability then
      size = size + 1
    else
      break
    end
  end
  
  return size
end

function Map:getNeighborhood(choice)
  local neighborhood = {}
  
  neighborhood.vonNeuman = {
    n = {0, -1},
    e = {1, 0},
    s = {0, 1},
    w = {-1, 0},
  }
  
  neighborhood.moore = {
    n = {0, -1},
    ne = {1, -1},
    e = {1, 0},
    se = {1, 1},
    s = {0, 1},
    sw = {-1, 1},
    w = {-1, 0},
    nw = {-1, -1}
  }
  
  return neighborhood[choice]
end

function Map:spacePropogation(value, neighborhood, cell, size)
  local neighborhood = self:getNeighborhood(neighborhood)
  
  self.cells[cell.x][cell.y] = value
  
  local function recurse(cell, size)
    if size > 0 then
      for _, v in pairs(neighborhood) do
        local x = cell.x + v[1]
        local y = cell.y + v[2]
        if self:get_cell(x, y) then
          self.cells[x][y] = value
          recurse({x=x,y=y}, size - 1)
        end
      end
    end
  end
  
  recurse(cell, size)
end

function Map:dijkstra(start, neighborhood)
  local neighborhood = neighborhood or "vonNeuman"
  local neighbors = Map:getNeighborhood(neighborhood)
  local map = Map:new(self.width, self.height, 999)
  
  for i, v in ipairs(start) do
    map:set_cell(v.x, v.y, 0)
  end
  
  local to_check = start
  local checked = {}
  
  while true do 
    local current_tile = table.remove(to_check)
    local x, y = current_tile.x, current_tile.y
    local minimum_distance_value = map:get_cell(x, y)
    
    for k, v in pairs(neighbors) do
      local x, y = x+v[1], y+v[2]
      
      if self:get_cell(x, y) then
        
        if not checked[tostring(x)..','..tostring(y)] then
          if self:get_cell(x, y) ~= 1 then
            table.insert(to_check, {x=x, y=y})
            map:set_cell(x, y, math.min(minimum_distance_value + 1, map:get_cell(x, y)))
          end
        end
        
        
      end
    end
    
    map:set_cell(x, y, minimum_distance_value)
    
    checked[tostring(x)..','..tostring(y)] = true
    
    if #to_check == 0 then
      break
    end 
  end
  
  return map
end


function Map:aStar(x1,y1, x2,y2)
  local vonNeuman = Map:getNeighborhood('vonNeuman')
  local aStar_map = Map:new(self.width, self.height, 0)

  local toTravel = {}
  local travelled = {}
  local function MDistance(x1,y1, x2,y2)
    return math.abs(x1 - x2) + math.abs(y1 - y2)
  end
  
  local SEMDistance = MDistance(x1,y1, x2,y2)
  local startNode = {x = x1, y = y1, s = 0, e = SEMDistance, t = SEMDistance}
  table.insert(toTravel, startNode)
  
  while true do
    local nextNode = nil
    local vertexIndex = nil
    
    for i, v in ipairs(toTravel) do
      if aStar_map.cells[v.x][v.y] == 0 then
        
        if nextNode == nil then
          nextNode = v
          vertexIndex = i
        elseif  v.t < nextNode.t then
          nextNode = v
          vertexIndex = i
        elseif v.t == nextNode.t and v.e < nextNode.e then
          nextNode = v
          vertexIndex = i
        end
        
      end
    end
    
    table.remove(toTravel, vertexIndex)
    table.insert(travelled, nextNode)
    aStar_map.cells[nextNode.x][nextNode.y] = nextNode.s
    
    if nextNode.x == x2 and nextNode.y == y2 then
      break
    end
    
    for k, v in pairs(vonNeuman) do
        if 
          self:get_cell(nextNode.x + v[1], nextNode.y + v[2]) ~= 1 and 
          self:get_cell(nextNode.x + v[1], nextNode.y + v[2]) ~= nil 
        then
          local newNode = {}
          newNode.x = nextNode.x + v[1]
          newNode.y = nextNode.y + v[2]
          newNode.s = nextNode.s + 1
          newNode.e = MDistance(newNode.x,newNode.y, x2,y2)
          newNode.t = newNode.s + newNode.e
          
          local match = nil
          for i, v in ipairs(toTravel) do
            if v.x == newNode.x and v.y == newNode.y then
              match = {s = v.s, i = i}
            end
          end
          
          if match ~= nil then
            if match.s > newNode.s then
              table.remove(toTravel, match.i)
              table.insert(toTravel, newNode)
            end
          else
            table.insert(toTravel, newNode)
          end
          
        end
    end
  end
  
  
  local aStar_path = {}
  
  
  local furthestS = -1
  for i, v in ipairs(travelled) do
    if v.s > furthestS then
      furthestS = v.s
    end
  end
  
  local endNode = {x = x2, y = y2, s = furthestS, e = 0, t = furthestS}
  table.insert(aStar_path, endNode)
  
  while #aStar_path ~= furthestS + 1  do
    for i, v in ipairs(travelled) do
      if v.s == aStar_path[#aStar_path].s - 1 then
        if MDistance(v.x, v.y, aStar_path[#aStar_path].x, aStar_path[#aStar_path].y) == 1  then
          table.insert(aStar_path, v)
        end
      end
    end
  end

  local path = Map:new_path()
  for i, v in ipairs(aStar_path) do
    path:add_point(vec2(v.x, v.y))
  end
  
  return path
end

function Map:automata(map)
  local neighbors = {
    {-1,1},{0,1},{1,1},
    {-1,0},      {1,0},
    {-1,-1},{0,-1},{1,-1}
  }
  
  local copy = {}
  for x = 1, #map do
    copy[x] = {}
    for y = 1, #map[x] do
      copy[x][y] = 0
    end
  end
  
  for x = 1, #map do
    for y = 1, #map[x] do
      local numOfNeighbors = 0
      for i, v in ipairs(neighbors) do
        if self:posIsInArea(x+v[1], y+v[2], 1,1,#map,#map[x]) then
          if map[x+v[1]][y+v[2]] == 1 then
            numOfNeighbors = numOfNeighbors + 1
          end
        else
          numOfNeighbors = numOfNeighbors + 1
        end
      end
      
      if map[x][y] == 0 then
        if numOfNeighbors > 4 then
          copy[x][y] = 1
        end
      elseif map[x][y] == 1 then
        if numOfNeighbors >= 3 then
          copy[x][y] = 1
        else
          copy[x][y] = 0
        end
      end
      
    end
  end
  
  
  for x = 1, #copy do
    for y = 1, #copy[x] do
      map[x][y] = copy[x][y]
    end
  end
  
end

function Map:automata2()
  local perms = {}
  local square = {1,1,1, 0,0, 0,0,0}
  
  table.insert(perms, square)
  local function mirrorX(t)
    local new = {}
    for i = 1,3 do
      new[i] = t[i+5]
    end
    for i = 4,5 do
      new[i] = t[i]
    end
    for i = 6,8 do
      new[i] = t[i-5]
    end
    
    return new
  end
  
  table.insert(perms, mirrorX(square))
  
  local function match(x,y, comp)
    local map = self.cells
    local neighbors = {
      {-1,1},{0,1},{1,1},
      {-1,0},      {1,0},
      {-1,-1},{0,-1},{1,-1}
    }
    
    local bit = true
    
    for i, v in ipairs(neighbors) do
      local x,y = x+v[1],y+v[2]
      if map[x][y] ~= comp[i] then
        bit = false
        break
      end
    end
    
    return bit
  end
  
  for x = 2, self.width-1 do
    for y = 2, self.height-1 do
      for i, v in ipairs(perms) do
        if match(x,y, v) then
          self.cells[x][y] = 1
        end
      end
    end
  end
end

-- DLA needs a cleared cell to start from and a space to clear
function Map:DLAInOut(attempts)
  local attempts = attempts or 1000
  local attempt_counter = 0

  local function clamp(n, min, max)
    local n = math.max(math.min(n, max), min)
    return n
  end
  
  while true do
    local neighbors = {{1,0},{-1,0},{0,1},{0,-1}}
    local x1,y1 = nil,nil
    local x2,y2 = nil,nil
    
    repeat
      x1 = love.math.random(2, self.width - 2)
      y1 = love.math.random(2, self.height - 2)
      attempt_counter = attempt_counter + 1
    until self.cells[x1][y1] == 0 or attempt_counter > attempts
    
    
    local n = 0
    while n ~= 4 do
      local vec = love.math.random(1, 4-n)
      x2 = x1 + neighbors[vec][1]
      y2 = y1 + neighbors[vec][2]
      
      if self.cells[x2][y2] == 1 then
        break
      else
        n = n + 1
        table.remove(neighbors, vec)
      end
    end
    
    if n ~= 4 then
      self.cells[x2][y2] = 0
      break
    end
  end
end

function Map:DLA()
  local x1,y1 = nil,nil
  repeat
    x1 = math.random(2, self.width-2)
    y1 = math.random(2, self.height-2)
  until self:get_cell(x1, y1) == 1
  
  local function clamp(n, min, max)
    local n = math.max(math.min(n, max), min)
    return n
  end
  local neighbors = {{1,0},{-1,0},{0,1},{0,-1}}
  local x2, y2 = nil, nil
  
  repeat
    x2,y2 = x1,y1
    
    local vec = math.random(1, 4)
    x1 = clamp(x1 + neighbors[vec][1], 2, self.width-2)
    y1 = clamp(y1 + neighbors[vec][2], 2, self.height-2)
  until self:get_cell(x1, y1) == 0
  
  self:clear_cell(x2, y2) 
end

function Map:drunkWalk(x, y, exitFunc)
  local path = Map:new_path()
  path:add_point(vec2(x, y))
  
  local neighbors = {{1,0},{-1,0},{0,1},{0,-1}}
  local function clamp(n, min, max)
    local n = math.max(math.min(n, max), min)
    return n
  end
  
  local i = 0
  repeat
    i = i + 1
    local vec = love.math.random(1, 4)
    x = clamp(x + neighbors[vec][1], 1, self.width-1)
    y = clamp(y + neighbors[vec][2], 1, self.height-1)
    
    path:add_point(vec2(x,y))
  until exitFunc(x, y, i, self) == true
  
  return path
end

function Map:guidedDrunkWalk(x1, y1, x2, y2, map, limit)
  local x, y = x1, y1
  
  local neighbors = {}
  if math.max(x1, x2) == x2 then
    table.insert(neighbors, {1,0})
  else
    table.insert(neighbors, {-1,0})
  end
  if math.max(y1, y2) == y2 then
    table.insert(neighbors, {0,1})
  else
    table.insert(neighbors, {0,-1})
  end
  
  
  local function clamp(n, min, max)
    local n = math.max(math.min(n, max), min)
    return n
  end
  
  repeat
    self:clear_cell(x, y)
    local vec = math.random(1, 2)
    x = clamp(x + neighbors[vec][1], math.min(x1, x2), math.max(x1, x2))
    y = clamp(y + neighbors[vec][2], math.min(y1, y2), math.max(y1, y2))
  until map[x][y] == limit
  
end

function Map:tunneler(x1, y1, width, turnThreshold, steps, startingDirection, min_turn)
  local x, y = x1, y1
  local directions = {
    {1, 0},  -- Right
    {-1, 0}, -- Left
    {0, 1},  -- Down
    {0, -1}  -- Up
  }

  local min_turn = min_turn or 0
  -- Use the provided starting direction or randomize it if not provided
  local currentDirection = startingDirection or directions[math.random(1, 4)]

  local function clear_tunnel_cells(x, y, direction, width)
    local halfWidth = math.floor(width / 2)
    
    for i = -halfWidth, halfWidth do
      for j = -halfWidth, halfWidth do
        local newX, newY = x + i, y + j
        self:clear_cell_checked(newX, newY)
      end
    end
  end

  local function change_direction(x, y, width)
    local newDirection = currentDirection

    local ndx, ndy = unpack(newDirection)
    local cdx, cdy = unpack(currentDirection)

    while math.abs(ndx) == math.abs(cdx) and math.abs(ndy) == math.abs(cdy) do
      newDirection = directions[math.random(1, 4)]
      ndx, ndy = unpack(newDirection)
    end
    currentDirection = newDirection
  end

  local function push_away_from_edge(x, y, width)
    local changed = false
    if x <= width then
      changed = true
      x = width + 1
    elseif x >= #self.map - width then
      changed = true
      x = #self.map - width - 1
    end

    if y <= width then
      changed = true
      y = width + 1
    elseif y >= #self.map[1] - width then
      changed = true
      y = #self.map[1] - width - 1
    end

    if changed then
      change_direction(x, y, width)
    end

    return x, y
  end

  local last_turn = 1
  for step = 1, steps do
    x, y = push_away_from_edge(x, y, width)
    clear_tunnel_cells(x, y, currentDirection, width)

    if turnThreshold > math.random() and step - last_turn > min_turn then
      last_turn = step
      change_direction(x, y, width)
    end

    x = x + currentDirection[1]
    y = y + currentDirection[2]

    -- Ensure the tunneler stays within the map boundaries
    x = math.max(math.min(x, #self.map - 1), 1)
    y = math.max(math.min(y, #self.map[1] - 1), 1)
  end
end

function Map:remove_isolated_walls()
  local function flood_fill(x, y)
    local queue = {{x = x, y = y}}

    while #queue > 0 do
      local current = table.remove(queue, 1)
      local x, y = current.x, current.y

      if self:get_cell(x, y) ~= 1 then
        goto continue
      end

      self:set_cell(x, y, 0)

      local neighbors = {
        {x = x + 1, y = y},
        {x = x - 1, y = y},
        {x = x, y = y + 1},
        {x = x, y = y - 1}
      }

      for _, neighbor in ipairs(neighbors) do
        table.insert(queue, neighbor)
      end

      ::continue::
    end
  end

  for x = 1, self.width do
    for y = 1, self.height do
      local cell = self:get_cell(x, y)
      if cell == 1 then
        local wall_neighbors = 0
        for _, v in ipairs({{-1, 0}, {1, 0}, {0, -1}, {0, 1}}) do
          local nx, ny = x + v[1], y + v[2]
          if self:get_cell(nx, ny) == 1 then
            wall_neighbors = wall_neighbors + 1
          end
        end

        if wall_neighbors < 2 then
          flood_fill(x, y)
        end
      end
    end
  end
end

function Map:find_wall_tiles_to_remove()
  local wall_tiles_to_remove = {}
  
  local vonNeuman = {
    n = {0, -1},
    e = {1, 0},
    s = {0, 1},
    w = {-1, 0},
  }
  
  -- Find wall tiles with two opposite floor tiles
  for x = 1, self.width do
    for y = 1, self.height do
      if self:get_cell(x, y) == 1 then
        local opposite_floor_tiles = {}
        for _, dir in pairs(vonNeuman) do
          local floor1_x = x + dir[1]
          local floor1_y = y + dir[2]
          local floor2_x = x - dir[1]
          local floor2_y = y - dir[2]
          if self:get_cell(floor1_x, floor1_y) ~= nil and self:get_cell(floor2_x, floor2_y) ~= nil and
            self:get_cell(floor1_x, floor1_y) == 0 and self:get_cell(floor2_x, floor2_y) == 0 then
            table.insert(opposite_floor_tiles, {{x = floor1_x, y = floor1_y}, {x = floor2_x, y = floor2_y}})
          end
        end
        if #opposite_floor_tiles > 0 then
          table.insert(wall_tiles_to_remove, {x = x, y = y, opposite_floor_tiles = opposite_floor_tiles})
        end
      end
    end
  end

  -- Find and remove the walls with the greatest pathfinding distance between their neighboring floor tiles
  local max_distance = -1
  local wall_to_remove = nil
  for _, wall in ipairs(wall_tiles_to_remove) do
    for _, floor_pair in ipairs(wall.opposite_floor_tiles) do
      local path = self:aStar(floor_pair[1].x, floor_pair[1].y, floor_pair[2].x, floor_pair[2].y)
      local distance = #path - 1
      if distance > max_distance then
        max_distance = distance
        wall_to_remove = wall
      end
    end
  end

  if wall_to_remove then
    self:set_cell(wall_to_remove.x, wall_to_remove.y, 0)
  end
end

return Map