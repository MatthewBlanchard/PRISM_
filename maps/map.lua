local Object = require "object"
local Map = Object:extend()

local vec2 = require "vector"
local Sparse_map = require 'sparsemap'

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
  
  self.entities = {
    list = {},
    keys = {},
    sparsemap = Sparse_map(),
  }

  self.map = map
  self.cells = map
  self.width = width
  self.height = height
end

function Map:insert_entity(entity_id, x, y, callback, unique_id)
  local position = vec2(x, y)
  local unique_id = unique_id or id_generator()
  local entity = {id = entity_id, unique_id = unique_id, pos = position, callback = callback}
  self.entities.list[entity] = entity
  self.entities.sparsemap:insert(x, y, entity)

  return self, unique_id
end

function Map:remove_entities(x, y)
  local entities = {}
  for k, v in pairs(self.entities.sparsemap:get(x, y)) do
    table.insert(entities, k)
    self.entities.sparsemap:remove(x, y, k)
  end

  for i, v in ipairs(entities) do
    self.entities.list[v] = nil
  end
end

function Map:get_entities(x, y)

  local entities = {}
  for k, v in pairs(self.entities.sparsemap:get(x, y)) do
    table.insert(entities, k)
  end

  for i, v in ipairs(entities) do
    entities[i] = self.entities.list[v]
  end

  return entities
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

-- Merging
function Map:blit(map, x, y, is_destructive)
  for i = x, x+map.width do
    for i2 = y, y+map.height do
      if (is_destructive) or (self:get_cell(i, i2) == 0) then
        self:set_cell(i, i2, map:get_cell(i-x, i2-y))
      end
    end
  end
  
  local copy = tablex.deep_copy(map.entities)

  for k, v in pairs(copy.list) do
    v.pos = v.pos + vec2(x, y)
  end
  self.entities.list = tablex.overlay(self.entities.list, copy.list)

  for x2, y2, k in copy.sparsemap:each() do
    self.entities.sparsemap:insert(x2+x, y2+y, k)
  end

  return self
end

function Map:special_merge(graph)
  local function new_chunk(params)
    params:parameters()
    local chunk = Map:new(params.width, params.height, 1)
    params:shaper(chunk)

    local overlay = Map:new(params.width+1, params.height+1, 0)
    overlay:fill_perimeter(0, 0, params.width+1, params.height+1) 
    overlay:blit(chunk, 0, 0) 
    
    return overlay:new_from_outline()
  end
  
  for _, v in ipairs(graph.vertices) do
    local chunk = new_chunk(v.parameters)
    local outline = chunk:new_from_outline_strict()
    local edge = outline:find_edges()

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
    
    v.chunk = chunk
    v.outline_edges = edge
    v.num_of_points = num_of_points
    v.polygon = path
    
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
  local function find_valid_matches(vertex1, vertex2, edge_meta_info)
    local matches = get_matching_edges(vertex1.outline_edges, vertex2.outline_edges)
    local matches_without_intersections = {}
    
    for _, v in ipairs(matches) do
      for i = 2, #v[1]-1 do
        for i2 = 2, #v[2]-1 do
          local segment_index_1 = i
          local segment_index_2 = i2
          
          local offset = vec2(v[1][segment_index_1].x - v[2][segment_index_2].x, v[1][segment_index_1].y - v[2][segment_index_2].y)
          local connection_point_1 = vec2(v[1][segment_index_1].x, v[1][segment_index_1].y)
          local connection_point_2 = vec2(v[2][segment_index_2].x, v[2][segment_index_2].y)
          local is_intersect, offset_clip = does_intersect(vertex1.polygon, vertex2.polygon, vertex2.num_of_points, offset)
          if (not is_intersect) then
            table.insert(matches_without_intersections, {
              v, segment_index_1, segment_index_2, offset_clip, vertex2, offset, num_of_points, connection_point_1, connection_point_2,
              
              segment_index_1 = segment_index_1,
              segment_index_2 = segment_index_2,
              
              offset = offset,
              offset_clip = offset_clip,
              clip = vertex2.polygon,
              num_of_points = vertex2.num_of_points,
              edge_meta_info = edge_meta_info
              
            })
          end


        end
      end
    end
    
    local matches = matches_without_intersections
    assert(#matches > 0, "no matches found")
    return matches
  end
  
  local function solve_for_room_positions()
    local function build_queue_and_matches()
      local travelled = {[graph.vertices[1]] = true}
      local matches = {}
      local queue = {{parent = nil, self = graph.vertices[1]}}
      
      local function recursion(vertex)
        for i, v in ipairs(vertex.edges) do
          if (not travelled[v.vertex]) and v.meta.type == 'Join' then
            travelled[v.vertex] = true
            table.insert(queue, {parent = vertex, self = v.vertex})
            matches[tostring(vertex)..' '..tostring(v.vertex)] = find_valid_matches(vertex, v.vertex, v.meta)
            recursion(v.vertex)
          end
        end
      end
      recursion(graph.vertices[1])
      
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
          local vertex, parent = queue[n].self, queue[n].parent
          local parent_offset = offsets[parent] or vec2(0, 0)
          local match = {}
          if parent ~= nil then
            match = matches[tostring(parent)..' '..tostring(vertex)]
          else
            clip_buffer[n] = vertex
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
            offsets[vertex] = offset
            for i3 = 0, clip.num_of_points-1 do
              clip.offset_clip[i3] = Clipper.IntPoint(clip.clip[i3].X + offset.x, clip.clip[i3].Y + offset.y)
            end
            clip_buffer[n] = clip
            
            
            local clips = clip_buffer
            local clipper = Clipper.Clipper()
            local subject = clips[1].polygon
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
  for i, v in ipairs(graph.vertices) do
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
    map:blit(match[5].chunk, offset.x+clip_width_sum, offset.y+clip_height_sum, false)
  end
  
  for i, v in ipairs(connections) do
    v.edge_meta_info.callback(map, v)
  end

  return map
end

function Map:planar_embedding(graph)
  local function fill_vertices_info()
    local function new_chunk(params)
      params:parameters()
      local chunk = Map:new(params.width, params.height, 1)
      params:shaper(chunk)

      local overlay = Map:new(params.width+1, params.height+1, 0)
      overlay:fill_perimeter(0, 0, params.width+1, params.height+1) 
      overlay:blit(chunk, 0, 0) 
      
      return overlay:new_from_outline()
    end
    
    for _, v in ipairs(graph.vertices) do
      local chunk = new_chunk(v.parameters)
      local outline = chunk:new_from_outline_strict()
      local edges = outline:find_edges()

      local num_of_points = 0
      for _, v2 in ipairs(edges) do
        for _, v3 in ipairs(v2) do
          num_of_points = num_of_points + 1
        end
      end
      local path = Clipper.Path(num_of_points)
      local i = 0
      for _, v2 in ipairs(edges) do
        for _, v3 in ipairs(v2) do
          path[i] = Clipper.IntPoint(v3.x, v3.y)
          i = i + 1
        end
      end
      
      v.chunk = chunk
      v.outline_edges = edges
      v.num_of_points = num_of_points
      v.polygon = path
      
      v.parameters.populater(v.parameters, v.chunk, path)
    end
  end

  local function get_variables()
    local variables = {}
    for _, v in ipairs(graph.vertices) do
      table.insert(variables, v)
    end
    return variables
  end

  local function find_domain_range_max()
    local chunk_dimensions_sum = vec2(0, 0)
    for i, v in ipairs(graph.vertices) do
      local chunk_dimensions = vec2(v.chunk.width, v.chunk.height)
      chunk_dimensions_sum = chunk_dimensions_sum + chunk_dimensions
    end

    return math.max(chunk_dimensions_sum.x, chunk_dimensions_sum.y)
  end
  local function get_domains(variables)
    local domains = {}
    local domain_range = vec2(0, find_domain_range_max())
    for _, v in ipairs(variables) do
      local domain = {}
      for x = domain_range.x, domain_range.y do
        for y = domain_range.x, domain_range.y do
          table.insert(domain, vec2(x, y))
        end
      end
      domains[v] = domain
    end

    return domains
  end

  local function get_constraints()
    local constraints = {}

    local function common_edge(assignment)
      local function shares_common_edge(vertex_1, vertex_2)
        local function get_offset_edges(vertex)
          local edges = vertex.outline_edges
          local offset = assignment[vertex]

          local offset_edges = tablex.deep_copy(edges)

          for _, edge in ipairs(offset_edges) do
            for i, point in ipairs(edge) do
              edge[i] = vec2(point.x + offset.x, point.y + offset.y)
            end
          end

          return offset_edges
        end
        local function areIntersecting(x1, y1, x2, y2, x3, y3, x4, y4)
          local denominator = ((y4 - y3) * (x2 - x1)) - ((x4 - x3) * (y2 - y1))
          local numerator1 = ((x4 - x3) * (y1 - y3)) - ((y4 - y3) * (x1 - x3))
          local numerator2 = ((x2 - x1) * (y1 - y3)) - ((y2 - y1) * (x1 - x3))
          
          if denominator == 0 then
            if numerator1 == 0 and numerator2 == 0 then
              return true
            else
              return false
            end
          end
          
          local r = numerator1 / denominator
          local s = numerator2 / denominator
          
          if r >= 0 and r <= 1 and s >= 0 and s <= 1 then
            return true
          else
            return false
          end
        end

        local edges_1 = get_offset_edges(vertex_1)
        local edges_2 = get_offset_edges(vertex_2)

        local shares_common_edge = false
        for _, edge_1 in ipairs(edges_1) do
          for _, edge_2 in ipairs(edges_2) do

            local p1, q1 = edge_1[1], edge_1[#edge_1]
            local p2, q2 = edge_2[1], edge_2[#edge_2]
            
            local dx1, dy1 = p1.x - q1.x, p1.y - q1.y
            local dx2, dy2 = p2.x - q2.x, p2.y - q2.y
            
            if math.sign(dx1) == -math.sign(dx2) and math.sign(dy1) == -math.sign(dy2) then
              if #edge_1 > 2 and #edge_2 > 2 then
                if areIntersecting(
                  p1.x, p1.y, q1.x, q1.y,
                  p2.x, p2.y, q2.x, q2.y
                ) 
                then
                  shares_common_edge = true
                  break
                end
              end
            end

          end

        end

        return shares_common_edge
      end

      local is_consistent = true
      for _, v in ipairs(graph.edges) do
        local vertex_1, vertex_2 = v.vertex_1, v.vertex_2
        if assignment[vertex_1] ~= nil and assignment[vertex_2] ~= nil then

          if not shares_common_edge(vertex_1, vertex_2) then
            is_consistent = false
            break
          end

        end
      end

      return is_consistent
    end

    local function no_overlap(assignment)
      local function does_intersect(vertex_1, vertex_2)

        local function get_offset_clip(vertex)
          local clip = vertex.polygon
          local num_of_points = vertex.num_of_points
          local offset = assignment[vertex]

          local offset_clip = Clipper.Path(num_of_points)
          for i = 0, num_of_points-1 do
            offset_clip[i] = Clipper.IntPoint(clip[i].X + offset.x, clip[i].Y + offset.y)
          end

          return offset_clip
        end

        local subject = get_offset_clip(vertex_1)
        local clip = get_offset_clip(vertex_2)

        local solution = Clipper.Paths(1)
        local clipper = Clipper.Clipper()
        clipper:AddPath(subject, Clipper.ptSubject, true)
        clipper:AddPath(clip, Clipper.ptClip, true)
        clipper:Execute(Clipper.ctUnion, solution)
        
        local is_intersect = (Clipper.Area(solution[0]) ~= Clipper.Area(subject)+Clipper.Area(clip))
        return is_intersect
      end

      local is_consistent = true
      for _, vertex_1 in ipairs(graph.vertices) do

        if assignment[vertex_1] ~= nil then

          for _, vertex_2 in ipairs(graph.vertices) do
            if vertex_1 ~= vertex_2 then

              if assignment[vertex_2] ~= nil then


                if does_intersect(vertex_1, vertex_2) then
                  is_consistent = false
                  break
                end
                

              end

            end
          end

        end
      end

      return is_consistent
    end

    table.insert(constraints, common_edge)
    table.insert(constraints, no_overlap)

    return constraints
  end

  fill_vertices_info()

  local variables = get_variables()
  local domains = get_domains(variables)
  local constraints = get_constraints()
  local assignment = {}

  local function select_unassigned_variable(vars, domains, assignment)
    -- Select the variable with the fewest remaining values in its domain
    local min_var, min_size = nil, math.huge
    for _, var in ipairs(vars) do
        if assignment[var] == nil and #domains[var] < min_size then
            min_var = var
            min_size = #domains[var]
        end
    end
    return min_var
  end

  local function is_consistent(assignment, constraints)
    -- Check if the assignment satisfies all constraints
    -- for _, clause in ipairs(constraints) do
    --     local satisfied = false
    --     for _, literal in ipairs(clause) do
    --         if assignment[literal.variable] == literal.value then
    --             satisfied = true
    --             break
    --         end
    --     end
    --     if not satisfied then
    --         return false
    --     end
    -- end
    -- return true

    -- Check if the assignment satisfies all constraints
    local satisfied = true
    for _, clause in ipairs(constraints) do
      if clause(assignment) == false then
        satisfied = false
        break
      end
    end
    return satisfied
  end

  local function backtrack_search(vars, domains, constraints, assignment)
    -- If all variables are assigned, return the solution
    if #tablex.keys(assignment) == #vars then
      return assignment
    end
    
    -- Choose the next unassigned variable
    local var = select_unassigned_variable(vars, domains, assignment)
    
    -- Try assigning each value in the domain of the variable
    for _, value in ipairs(domains[var]) do
        -- Assign the value to the variable
        assignment[var] = value
        
        -- Check if the assignment satisfies all constraints
        if is_consistent(assignment, constraints) then
            -- Recursively search with the updated assignment
            local result = backtrack_search(vars, domains, constraints, assignment)
            
            -- If a solution is found, return it
            if result ~= nil then
                return result
            end
        end
        
        -- If the assignment violates a constraint, backtrack
        assignment[var] = nil
    end
    
    -- If no solution is found, return nil
    return nil
  end

  local assignment = backtrack_search(variables, domains, constraints, assignment)
  assert(assignment, 'unsatisfiable')

  local length = find_domain_range_max()
  local map = Map:new(length*2, length*2, 0)

  for i, v in ipairs(variables) do
    print(assignment[v])
    map:blit(v.chunk, assignment[v].x, assignment[v].y, false)
  end

  return map
end

-- function Map:get_padding()
--   local padding_left, padding_right = 0, 0
--   local padding_top, padding_bottom = 0, 0
  
--   for x = 0, self.width do
--     local binary = false
--     for y = 0, self.height do
--       if self:get_cell(x, y) == 1 then
--         binary = true
--         break
--       end
--     end
--     if binary == true then
--       break
--     end
--     padding_left = padding_left + 1
--   end
  
--   for x = self.width, 0, -1 do
--     local binary = false
--     for y = 0, self.height do
--       if self:get_cell(x, y) == 1 then
--         binary = true
--         break
--       end
--     end
--     if binary == true then
--       break
--     end
--     padding_right = padding_right + 1
--   end
  
--   for y = 0, self.height do
--     local binary = false
--     for x = 0, self.width do
--       if self:get_cell(x, y) == 1 then
--         binary = true
--         break
--       end
--     end
--     if binary == true then
--       break
--     end
--     padding_top = padding_top + 1
--   end
  
--   for y = self.height, 0, -1 do
--     local binary = false
--     for x = 0, self.width do
--       if self:get_cell(x, y) == 1 then
--         binary = true
--         break
--       end
--     end
--     if binary == true then
--       break
--     end
--     padding_bottom = padding_bottom + 1
--   end
  
--   return padding_left, padding_right, padding_top, padding_bottom
-- end

-- function Map:new_from_trim_edges(left, right, top, bottom)
--   local map = Map:new(self.width-(left+right), self.height-(top+bottom), 0)
  
--   for x = left, self.width-right do
--     for y = top, self.height-bottom do
--       map:set_cell(x-left, y-top, self:get_cell(x, y))
--     end
--   end
  
--   local copy = tablex.deep_copy(self.entities.list)
--   for i, v in ipairs(copy) do
--     v.pos = v.pos - vec2(left, top)
--   end
--   map.entities.list = copy
  
--   return map
-- end

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
function Map:get_cell(x, y)
  return self.cells[x] and self.cells[x][y] or nil
end
function Map:set_cell(x, y, v)
  self.cells[x][y] = v
end

--Space
function Map:clear_cell(x,y)
  self.cells[x][y] = 0
  
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
    for y = cy-rady, cx+rady do
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
-- function Map:rollGrowthPotential(cell, probability, max, min)
--   local size = min or 1
  
--   while size < max do
--     if love.math.random() <= probability then
--       size = size + 1
--     else
--       break
--     end
--   end
  
--   return size
-- end

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

-- function Map:spacePropogation(value, neighborhood, cell, size)
--   local neighborhood = self:getNeighborhood(neighborhood)
  
--   self.cells[cell.x][cell.y] = value
  
--   local function recurse(cell, size)
--     if size > 0 then
--       for _, v in pairs(neighborhood) do
--         local x = cell.x + v[1]
--         local y = cell.y + v[2]
--         if self:posIsInMap(x, y) then
--           self.cells[x][y] = value
--           recurse({x=x,y=y}, size - 1)
--         end
--       end
--     end
--   end
  
--   recurse(cell, size)
-- end

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


-- function Map:aStar(x1,y1, x2,y2)
  
--   local vonNeuman = {
--     n = {0, -1},
--     e = {1, 0},
--     s = {0, 1},
--     w = {-1, 0},
--   }
  
--   local aMap = {}
--   for x = 1, self.width do
--     aMap[x] = {}
--     for y = 1, self.height do
--       aMap[x][y] = 0
--     end
--   end
  
--   local toTravel = {}
--   local travelled = {}
--   local function MDistance(x1,y1, x2,y2)
--     return math.abs(x1 - x2) + math.abs(y1 - y2)
--   end
  
--   local SEMDistance = MDistance(x1,y1, x2,y2)
--   local startNode = {x = x1, y = y1, s = 0, e = SEMDistance, t = SEMDistance}
--   table.insert(toTravel, startNode)
  
--   while true do
--     local nextNode = nil
--     local vertexIndex = nil
    
--     for i, v in ipairs(toTravel) do
--       if aMap[v.x][v.y] == 0 then
        
--         if nextNode == nil then
--           nextNode = v
--           vertexIndex = i
--         elseif  v.t < nextNode.t then
--           nextNode = v
--           vertexIndex = i
--         elseif v.t == nextNode.t and v.e < nextNode.e then
--           nextNode = v
--           vertexIndex = i
--         end
        
--       end
--     end
    
--     table.remove(toTravel, vertexIndex)
--     table.insert(travelled, nextNode)
--     aMap[nextNode.x][nextNode.y] = nextNode.s
    
--     if nextNode.x == x2 and nextNode.y == y2 then
--       break
--     end
    
--     for k, v in pairs(vonNeuman) do
--       if self:posIsInMap(nextNode.x + v[1], nextNode.y + v[2]) then
--         if self.cells[nextNode.x + v[1]][nextNode.y + v[2]] ~= 1 then
--           local newNode = {}
--           newNode.x = nextNode.x + v[1]
--           newNode.y = nextNode.y + v[2]
--           newNode.s = nextNode.s + 1
--           newNode.e = MDistance(newNode.x,newNode.y, x2,y2)
--           newNode.t = newNode.s + newNode.e
          
--           local match = nil
--           for i, v in ipairs(toTravel) do
--             if v.x == newNode.x and v.y == newNode.y then
--               match = {s = v.s, i = i}
--             end
--           end
          
--           if match ~= nil then
--             if match.s > newNode.s then
--               table.remove(toTravel, match.i)
--               table.insert(toTravel, newNode)
--             end
--           else
--             table.insert(toTravel, newNode)
--           end
          
--         end
--       end
--     end
--   end
  
  
--   local aPath = {}
  
--   local furthestS = -1
--   for i, v in ipairs(travelled) do
--     if v.s > furthestS then
--       furthestS = v.s
--     end
--   end
  
--   local endNode = {x = x2, y = y2, s = furthestS, e = 0, t = furthestS}
--   table.insert(aPath, endNode)
  
--   while #aPath ~= furthestS + 1  do
--     for i, v in ipairs(travelled) do
--       if v.s == aPath[#aPath].s - 1 then
--         if MDistance(v.x, v.y, aPath[#aPath].x, aPath[#aPath].y) == 1  then
--           table.insert(aPath, v)
--         end
--       end
--     end
--   end
  
--   return aPath
-- end

-- function Map:automata(map)
--   local neighbors = {
--     {-1,1},{0,1},{1,1},
--     {-1,0},      {1,0},
--     {-1,-1},{0,-1},{1,-1}
--   }
  
--   local copy = {}
--   for x = 1, #map do
--     copy[x] = {}
--     for y = 1, #map[x] do
--       copy[x][y] = 0
--     end
--   end
  
--   for x = 1, #map do
--     for y = 1, #map[x] do
--       local numOfNeighbors = 0
--       for i, v in ipairs(neighbors) do
--         if self:posIsInArea(x+v[1], y+v[2], 1,1,#map,#map[x]) then
--           if map[x+v[1]][y+v[2]] == 1 then
--             numOfNeighbors = numOfNeighbors + 1
--           end
--         else
--           numOfNeighbors = numOfNeighbors + 1
--         end
--       end
      
--       if map[x][y] == 0 then
--         if numOfNeighbors > 4 then
--           copy[x][y] = 1
--         end
--       elseif map[x][y] == 1 then
--         if numOfNeighbors >= 3 then
--           copy[x][y] = 1
--         else
--           copy[x][y] = 0
--         end
--       end
      
--     end
--   end
  
  
--   for x = 1, #copy do
--     for y = 1, #copy[x] do
--       map[x][y] = copy[x][y]
--     end
--   end
  
-- end

-- function Map:automata2()
--   local perms = {}
--   local square = {1,1,1, 0,0, 0,0,0}
  
--   table.insert(perms, square)
--   local function mirrorX(t)
--     local new = {}
--     for i = 1,3 do
--       new[i] = t[i+5]
--     end
--     for i = 4,5 do
--       new[i] = t[i]
--     end
--     for i = 6,8 do
--       new[i] = t[i-5]
--     end
    
--     return new
--   end
  
--   table.insert(perms, mirrorX(square))
  
--   local function match(x,y, comp)
--     local map = self.cells
--     local neighbors = {
--       {-1,1},{0,1},{1,1},
--       {-1,0},      {1,0},
--       {-1,-1},{0,-1},{1,-1}
--     }
    
--     local bit = true
    
--     for i, v in ipairs(neighbors) do
--       local x,y = x+v[1],y+v[2]
--       if map[x][y] ~= comp[i] then
--         bit = false
--         break
--       end
--     end
    
--     return bit
--   end
  
--   for x = 2, self.width-1 do
--     for y = 2, self.height-1 do
--       for i, v in ipairs(perms) do
--         if match(x,y, v) then
--           self.cells[x][y] = 1
--         end
--       end
--     end
--   end
-- end

function Map:DLAInOut()
  local is_at_least_one_empty = false
  local is_at_least_one_full = false
  for x, y, cell in self:for_cells() do
    if cell == 0 then
      is_at_least_one_empty = true
    elseif cell == 1 then
      is_at_least_one_full = true
    end
  end
  assert(is_at_least_one_empty and is_at_least_one_full)

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
    until self:get_cell(x1, y1) == 0
    
    
    local n = 0
    while n ~= 4 do
      local vec = love.math.random(1, 4-n)
      x2 = x1 + neighbors[vec][1]
      y2 = y1 + neighbors[vec][2]
      
      if self:get_cell(x2, y2) == 1 then
        break
      else
        n = n + 1
        table.remove(neighbors, vec)
      end
    end
    
    if n ~= 4 then
      self:clear_cell(x2, y2)
      break
    end
  end
end

function Map:DLA()
  local is_at_least_one_empty = false
  local is_at_least_one_full = false
  for x, y, cell in self:for_cells() do
    if cell == 0 then
      is_at_least_one_empty = true
    elseif cell == 1 then
      is_at_least_one_full = true
    end
  end
  assert(is_at_least_one_empty and is_at_least_one_full)

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

-- function Map:guidedDrunkWalk(x1, y1, x2, y2, map, limit)
--   local x, y = x1, y1
  
--   local neighbors = {}
--   if math.max(x1, x2) == x2 then
--     table.insert(neighbors, {1,0})
--   else
--     table.insert(neighbors, {-1,0})
--   end
--   if math.max(y1, y2) == y2 then
--     table.insert(neighbors, {0,1})
--   else
--     table.insert(neighbors, {0,-1})
--   end
  
  
--   local function clamp(n, min, max)
--     local n = math.max(math.min(n, max), min)
--     return n
--   end
  
--   repeat
--     self:clear_cell(x, y)
--     local vec = math.random(1, 2)
--     x = clamp(x + neighbors[vec][1], math.min(x1, x2), math.max(x1, x2))
--     y = clamp(y + neighbors[vec][2], math.min(y1, y2), math.max(y1, y2))
--   until map[x][y] == limit
  
-- end

return Map