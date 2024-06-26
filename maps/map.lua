local Object = require "object"
local Map = Object:extend()

local vec2 = require "math.vector"
local Sparse_map = require "structures.sparsemap"
local SparseGrid = require "structures.sparsegrid"

local tablex = require "lib.batteries.tablex"

local id_generator = require "maps.uuid"

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
   local entity = { id = entity_id, unique_id = unique_id, pos = position, callback = callback }
   self.entities.sparsemap:insert(x, y, entity)

   return self, unique_id
end
Map.insert_actor = Map.insert_entity -- temp alias

function Map:remove_entities(x, y)
   for k, v in pairs(self.entities.sparsemap:get(x, y)) do
      self.entities.sparsemap:remove(x, y, k)
   end
end

function Map:get_entities(x, y) return self.entities.sparsemap:get(x, y) end

function Map:for_cells()
   local x = 0
   local y = -1

   return function()
      if y < self.height then
         y = y + 1
      elseif y == self.height then
         y = 0
         x = x + 1
      end

      if x <= self.width then return x, y, self.cells[x][y] end
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
   for i = x, x + map.width do
      for i2 = y, y + map.height do
         if is_destructive or (self:get_cell(i, i2) == mask) then
            self:set_cell_checked(i, i2, map:get_cell(i - x, i2 - y))
         end
      end
   end

   local copy = tablex.deep_copy(map.entities)
   for x2, y2, k in copy.sparsemap:each() do
      if k then self.entities.sparsemap:insert(x2 + x, y2 + y, k) end
   end

   return self
end

function Map:check_overlap(map, x, y)
   for i = x, x + map.width do
      for j = y, y + map.height do
         if self:get_cell(i, j) and map:get_cell(i - x, j - y) then
            local currentCell = self:get_cell(i, j)
            local mapCell = map:get_cell(i - x, j - y)

            if currentCell == 0 and mapCell == 0 then return true end
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
   if self:check_overlap(map, x, y) then return false end

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

               if neighbour == 0 then hasOverlap = true end
            end
         end

         if mapCell == 1 and currentCell == 1 then
            local offsets = {
               vec2(0, 1),
               vec2(0, -1),
               vec2(1, 0),
               vec2(-1, 0),
            }

            for _, offset in ipairs(offsets) do
               local ni = i + offset.x
               local nj = j + offset.y

               local ni1 = i - offset.x
               local nj1 = j - offset.y

               local neighborCurrentCell = self:get_cell(ni, nj)
               local neighborMapCell = map:get_cell(ni1 - x, nj1 - y)

               if neighborCurrentCell == 0 and neighborMapCell == 0 then
                  table.insert(door_candidates, { i, j })
               end
            end
         end
      end
   end

   local hasAdjacentWall = table.remove(door_candidates, math.random(1, #door_candidates))
   if not hasOverlap and hasAdjacentWall then return hasAdjacentWall end
end

function Map:room_accretion(map, open_tile, wall_tile)
   local open_tile = open_tile or 0
   local wall_tile = wall_tile or 1
   local placed = false

   -- Find all possible starting positions
   local possible_positions = {}
   for x = 1, self.height do
      for y = 1, self.width do
         table.insert(possible_positions, { x, y })
      end
   end

   -- Shuffle the possible_positions list using the Fisher-Yates algorithm
   for i = #possible_positions, 2, -1 do
      local j = math.random(1, i)
      if not possible_positions[i] or not possible_positions[j] then print(i, j) end
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
               if map:get_cell(i - x, j - y) == 0 then table.insert(roomTiles, { i, j }) end
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

function Map:planar_embedding(graph)
   local start = love.timer.getTime()

   local function fill_vertices_info()
      local function new_chunk(params)
         params:parameters()
         local chunk = Map:new(params.width, params.height, 1)
         params:shaper(chunk)

         local overlay = Map:new(params.width + 1, params.height + 1, 0)
         overlay:fill_perimeter(0, 0, params.width + 1, params.height + 1)
         overlay:blit(chunk, 0, 0)

         return overlay:new_from_outline()
      end

      for _, v in ipairs(graph.vertices) do
         local chunk = new_chunk(v.parameters)
         local outline = chunk:new_from_outline_strict()
         local edges = outline:find_edges()

         local path = {}
         local i = 0
         for _, v2 in ipairs(edges) do
            for _, v3 in ipairs(v2) do
               path[i] = vec2(v3.x, v3.y)
               i = i + 1
            end
         end

         v.chunk = chunk
         v.outline_edges = edges
         v.num_of_points = num_of_points
         v.polygon = path
      end
   end
   local function get_id(t) return string.format("%p", t) end
   local function get_variables()
      local variables = {}
      for _, v in ipairs(graph.vertices) do
         table.insert(variables, v)
      end

      for k, v in pairs(graph.vertices) do
         variables[get_id(v)] = v
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
      local domain_range = { min = 0, max = find_domain_range_max() }

      for _, v in ipairs(variables) do
         local domain = {}

         for x = domain_range.min, domain_range.max - v.chunk.width do
            for y = domain_range.min, domain_range.max - v.chunk.height do
               table.insert(domain, vec2(x, y))
            end
         end

         domains[v] = domain
      end

      return domains
   end

   local domain_constraints = {}
   local edge_matches = {}
   local function point_in_polygon(point, polygon)
      local oddNodes = false
      local j = #polygon
      for i = 1, #polygon do
         if polygon[i].x == point.x and polygon[i].y == point.y then return -1 end
         if
            polygon[i].y < point.y and polygon[j].y >= point.y
            or polygon[j].y < point.y and polygon[i].y >= point.y
         then
            if
               polygon[i].x
                  + (point.y - polygon[i].y) / (polygon[j].y - polygon[i].y) * (polygon[j].x - polygon[i].x)
               < point.x
            then
               oddNodes = not oddNodes
            end
         end
         j = i
      end
      return oddNodes and 1 or 0
   end
   local function get_constraints(variables)
      local memoize = require "maps.memoize"
      --local memoize = function(f) return f end

      local constraints = {}

      local function common_edge(variables, assignment)
         local shares_common_edge = memoize(function(vertex_1, vertex_2, assignment_1, assignment_2)
            local function get_offset_edges(vertex, assignment)
               local edges = vertex.outline_edges
               local offset = assignment

               local offset_edges = tablex.deep_copy(edges)

               for _, edge in ipairs(offset_edges) do
                  for i, point in ipairs(edge) do
                     edge[i] = vec2(point.x + offset.x, point.y + offset.y)
                  end
               end

               return offset_edges
            end

            local function are_intersecting(p1, q1, p2, q2)
               local function on_segment(p, q, r)
                  if
                     q.x <= math.max(p.x, r.x)
                     and q.x >= math.min(p.x, r.x)
                     and q.y <= math.max(p.y, r.y)
                     and q.y >= math.min(p.y, r.y)
                  then
                     return true
                  else
                     return false
                  end
               end

               local function orientation(p, q, r)
                  local val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y)
                  if val == 0 then
                     return 0
                  else
                     return val > 0 and 1 or 2
                  end
               end

               local function do_intersect(p1, q1, p2, q2)
                  local o1 = orientation(p1, q1, p2)
                  local o2 = orientation(p1, q1, q2)
                  local o3 = orientation(p2, q2, p1)
                  local o4 = orientation(p2, q2, q1)

                  if o1 ~= o2 and o3 ~= o4 then
                     return true
                  elseif o1 == 0 and on_segment(p1, p2, q1) then
                     return true
                  elseif o2 == 0 and on_segment(p1, q2, q1) then
                     return true
                  elseif o3 == 0 and on_segment(p2, p1, q2) then
                     return true
                  elseif o4 == 0 and on_segment(p2, q1, q2) then
                     return true
                  else
                     return false
                  end
               end

               return do_intersect(p1, q1, p2, q2)
            end

            local edges_1 = get_offset_edges(vertex_1, assignment_1)
            local edges_2 = get_offset_edges(vertex_2, assignment_2)

            local shares_common_edge = false
            for _, edge_1 in ipairs(edges_1) do
               for _, edge_2 in ipairs(edges_2) do
                  local p1, q1 = edge_1[1], edge_1[#edge_1]
                  local p2, q2 = edge_2[1], edge_2[#edge_2]

                  local dx1, dy1 = p1.x - q1.x, p1.y - q1.y
                  local dx2, dy2 = p2.x - q2.x, p2.y - q2.y

                  local d1 = vec2(p1.x - q1.x, p1.y - q1.y)
                  local d2 = vec2(p2.x - q2.x, p2.y - q2.y)

                  if math.sign(dx1) == -math.sign(dx2) and math.sign(dy1) == -math.sign(dy2) then
                     if
                        (p1 ~= p2 and q1 ~= q2)
                        and (edge_1[1 + 1] ~= p2)
                        and (edge_1[#edge_1 - 1] ~= q2)
                     then
                        if are_intersecting(p1, q1, p2, q2) then
                           edge_matches[get_id(vertex_1) .. ":" .. get_id(vertex_2)] =
                              { edge_1 = edge_1, edge_2 = edge_2 }
                           shares_common_edge = true
                           break
                        end
                     end
                  end
               end
            end

            return shares_common_edge
         end)

         for _, v in ipairs(graph.edges) do
            local vertex_1, vertex_2 = v.vertex_1, v.vertex_2
            if assignment[vertex_1] ~= nil and assignment[vertex_2] ~= nil then
               if
                  shares_common_edge(vertex_1, vertex_2, assignment[vertex_1], assignment[vertex_2])
                  == false
               then
                  return false, { vertex_1, vertex_2 }
               end
            end
         end

         return true
      end

      local function no_overlap(variables, assignment)
         local does_intersect = memoize(function(vertex_1, vertex_2, assignment_1, assignment_2)
            local pos_1, hs_1 = intersect.rect_to_aabb(
               assignment_1,
               vec2(vertex_1.chunk.width, vertex_1.chunk.height)
            )
            local pos_2, hs_2 = intersect.rect_to_aabb(
               assignment_2,
               vec2(vertex_2.chunk.width, vertex_2.chunk.height)
            )
            if not intersect.aabb_aabb_overlap(pos_1, hs_1, pos_2, hs_2) then return false end

            local function get_offset_path(vertex, assignment)
               local path = vertex.polygon
               local offset = assignment

               local offset_path = tablex.copy(path)
               for i, v in ipairs(path) do
                  offset_path[i] = v + offset
               end
               return offset_path
            end

            local subject = get_offset_path(vertex_1, assignment_1)
            local clip = get_offset_path(vertex_2, assignment_2)

            local is_intersect = false
            local none_outside = true
            for i, v in ipairs(subject) do
               local relation = point_in_polygon(v, clip)
               if relation == 0 then none_outside = false end
               if relation == 1 then
                  is_intersect = true
                  break
               end
            end

            return is_intersect or none_outside
         end)

         for _, vertex_1 in ipairs(graph.vertices) do
            for _, vertex_2 in ipairs(graph.vertices) do
               if vertex_1 ~= vertex_2 and assignment[vertex_1] and assignment[vertex_2] then
                  if
                     does_intersect(vertex_1, vertex_2, assignment[vertex_1], assignment[vertex_2])
                  then
                     local bad_relation = assignment[vertex_1] - assignment[vertex_2]

                     local constraint_1 = function(pos, variables, assignment)
                        if assignment[vertex_2] then
                           local assignment_1, assignment_2 = pos, assignment[vertex_2]
                           local relation = assignment_2 - assignment_1

                           if relation == bad_relation then return false end
                        end
                        return true
                     end

                     local constraint_2 = function(pos, variables, assignment)
                        if assignment[vertex_1] then
                           local assignment_1, assignment_2 = assignment[vertex_1], pos
                           local relation = assignment_2 - assignment_1

                           if relation == bad_relation then return false end
                        end
                        return true
                     end

                     table.insert(domain_constraints[vertex_1], constraint_1)
                     table.insert(domain_constraints[vertex_2], constraint_2)

                     return false, { vertex_1, vertex_2 }
                  end
               end
            end
         end

         return true
      end

      table.insert(constraints, common_edge)
      table.insert(constraints, no_overlap)

      return constraints
   end

   fill_vertices_info()
   local variables = get_variables()
   local constraints = get_constraints(variables)
   local assignment = {}
   local domains = get_domains(variables)

   for _, v in ipairs(variables) do
      domain_constraints[v] = {}
   end
   local function make_domain_constraints()
      local does_intersect = function(vertex_1, vertex_2, assignment_1, assignment_2)
         local pos_1, hs_1 =
            intersect.rect_to_aabb(assignment_1, vec2(vertex_1.chunk.width, vertex_1.chunk.height))
         local pos_2, hs_2 =
            intersect.rect_to_aabb(assignment_2, vec2(vertex_2.chunk.width, vertex_2.chunk.height))
         if not intersect.aabb_aabb_overlap(pos_1, hs_1, pos_2, hs_2) then return false end

         local function get_offset_path(vertex, assignment)
            local path = vertex.polygon
            local offset = assignment

            local offset_path = tablex.copy(path)
            for i, v in ipairs(path) do
               offset_path[i] = v + offset
            end
            return offset_path
         end

         local subject = get_offset_path(vertex_1, assignment_1)
         local clip = get_offset_path(vertex_2, assignment_2)

         local is_intersect = false
         local none_outside = true
         for i, v in ipairs(subject) do
            local relation = point_in_polygon(v, clip)
            if relation == 0 then none_outside = false end
            if relation == 1 then
               is_intersect = true
               break
            end
         end

         return is_intersect or none_outside
      end

      local start = love.timer.getTime()
      for _, v in ipairs(graph.edges) do
         local valid_pos_pool = SparseGrid()

         local function get_offset_edges(vertex, assignment)
            local edges = vertex.outline_edges
            local offset = assignment

            local offset_edges = tablex.deep_copy(edges)

            for _, edge in ipairs(offset_edges) do
               for i, point in ipairs(edge) do
                  edge[i] = vec2(point.x + offset.x, point.y + offset.y)
               end
            end

            return offset_edges
         end
         local function are_intersecting(p1, q1, p2, q2)
            local function on_segment(p, q, r)
               if
                  q.x <= math.max(p.x, r.x)
                  and q.x >= math.min(p.x, r.x)
                  and q.y <= math.max(p.y, r.y)
                  and q.y >= math.min(p.y, r.y)
               then
                  return true
               else
                  return false
               end
            end

            local function orientation(p, q, r)
               local val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y)
               if val == 0 then
                  return 0
               else
                  return val > 0 and 1 or 2
               end
            end

            local function do_intersect(p1, q1, p2, q2)
               local o1 = orientation(p1, q1, p2)
               local o2 = orientation(p1, q1, q2)
               local o3 = orientation(p2, q2, p1)
               local o4 = orientation(p2, q2, q1)

               if o1 ~= o2 and o3 ~= o4 then
                  return true
               elseif o1 == 0 and on_segment(p1, p2, q1) then
                  return true
               elseif o2 == 0 and on_segment(p1, q2, q1) then
                  return true
               elseif o3 == 0 and on_segment(p2, p1, q2) then
                  return true
               elseif o4 == 0 and on_segment(p2, q1, q2) then
                  return true
               else
                  return false
               end
            end

            return do_intersect(p1, q1, p2, q2)
         end

         local vertex_1 = v.vertex_1
         local vertex_2 = v.vertex_2
         local edges_1 = get_offset_edges(vertex_1, vec2(0, 0))

         local points_of_interest = {}
         for _, edge_1 in ipairs(vertex_1.outline_edges) do
            for _, edge_2 in ipairs(vertex_2.outline_edges) do
               for _, p1 in ipairs(edge_1) do
                  for _, p2 in ipairs(edge_2) do
                     points_of_interest[-(p2.x - p1.x) .. ":" .. -(p2.y - p1.y)] = true
                  end
               end
            end
         end

         local function mysplit(inputstr, sep)
            local sep = sep or "%s"
            local t = {}
            for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
               table.insert(t, str)
            end
            return t
         end
         for k, v in pairs(points_of_interest) do
            local split = mysplit(k, ":")
            local x, y = split[1], split[2]

            local edges_2 = get_offset_edges(vertex_2, vec2(x, y))
            local shares_common_edge = false
            for _, edge_1 in ipairs(edges_1) do
               for _, edge_2 in ipairs(edges_2) do
                  local p1, q1 = edge_1[1], edge_1[#edge_1]
                  local p2, q2 = edge_2[1], edge_2[#edge_2]

                  local dx1, dy1 = p1.x - q1.x, p1.y - q1.y
                  local dx2, dy2 = p2.x - q2.x, p2.y - q2.y

                  local d1 = vec2(p1.x - q1.x, p1.y - q1.y)
                  local d2 = vec2(p2.x - q2.x, p2.y - q2.y)

                  if math.sign(dx1) == -math.sign(dx2) and math.sign(dy1) == -math.sign(dy2) then
                     if
                        (p1 ~= p2 and q1 ~= q2)
                        and (edge_1[1 + 1] ~= p2)
                        and (edge_1[#edge_1 - 1] ~= q2)
                     then
                        if are_intersecting(p1, q1, p2, q2) then
                           if not (does_intersect(vertex_1, vertex_2, vec2(0, 0), vec2(x, y))) then
                              valid_pos_pool:set(x, y, true)
                           end
                           break
                        end
                     end
                  end
               end
            end
         end

         local constraint_1 = function(pos, variables, assignment)
            if assignment[v.vertex_2] then
               local assignment_1, assignment_2 = pos, assignment[v.vertex_2]
               local relation = assignment_2 - assignment_1

               if valid_pos_pool:get(relation.x, relation.y) ~= true then return false end
            end
            return true
         end

         local constraint_2 = function(pos, variables, assignment)
            if assignment[v.vertex_1] then
               local assignment_1, assignment_2 = assignment[v.vertex_1], pos
               local relation = assignment_2 - assignment_1

               if valid_pos_pool:get(relation.x, relation.y) ~= true then return false end
            end
            return true
         end

         table.insert(domain_constraints[v.vertex_1], constraint_1)
         table.insert(domain_constraints[v.vertex_2], constraint_2)
      end
      print((love.timer.getTime() - start) * 100)
   end
   make_domain_constraints()

   local function constrain_domains(vars, domains, assignment)
      for var, domain in pairs(domains) do
         for i = #domain, 1, -1 do
            local pos = domain[i]

            if not pos then -- domain sometimes has a hole in it?
               table.remove(domain, i)
            else
               for _, v in ipairs(domain_constraints[var]) do
                  if not v(pos, vars, assignment) then
                     -- local back = #domain
                     -- domain[i], domain[back] = domain[back], domain[i]
                     -- table.remove(domain)
                     table.remove(domain, i)
                     break
                  end
               end
            end
         end
      end

      return domains
   end

   local function select_unassigned_variable(vars, domains, assignment)
      local min_var, min_size = nil, math.huge
      for _, var in ipairs(vars) do
         if assignment[var] == nil and #domains[var] < min_size then
            min_var = var
            min_size = #domains[var]
         end
      end
      return min_var
   end
   local function is_consistent(assignment, constraints, variables)
      for _, clause in ipairs(constraints) do
         local satisfied, conflicts = clause(variables, assignment)
         if satisfied == false then return false, conflicts end
      end
      return true
   end
   local function rpairs(t)
      local total = #t

      return function()
         if total > 0 then
            local r = love.math.random(total)
            local v = t[r]

            t[r], t[total] = t[total], t[r]
            total = total - 1

            return v
         end
      end
   end

   local domain_history = {}
   local function backtrack_search(vars, domains, constraints, assignment)
      if #assignment == #vars then return assignment end

      local domains = constrain_domains(vars, domains, assignment)
      table.insert(domain_history, domains)
      local var = select_unassigned_variable(vars, domains, assignment)

      for value in rpairs(domains[var]) do
         assignment[var] = value
         table.insert(assignment, var)

         local consistent, conflicts = is_consistent(assignment, constraints, vars)

         if consistent then
            local result = backtrack_search(vars, domains, constraints, assignment)
            if result ~= nil then return result end
         else
            -- local is_continue = true
            -- for i, v in ipairs(assignment) do
            --   for _, v2 in ipairs(conflicts) do
            --     if v == v2 then
            --       for n = #assignment, i+1, -1 do
            --         local var = table.remove(assignment)
            --         assignment[var] = nil
            --         table.remove(domain_history)
            --       end
            --       is_continue = false
            --       break
            --     end
            --   end
            --   if is_continue == false then
            --     break
            --   end
            -- end

            -- local domains = domain_history[#domain_history]
            -- local result = backtrack_search(vars, domains, constraints, assignment)
            -- if result ~= nil then
            --   return result
            -- end
         end

         assignment[var] = nil
         table.remove(assignment)
      end

      return nil
   end

   local assignment = backtrack_search(variables, domains, constraints, assignment)
   assert(assignment, "unsatisfiable")

   local length = find_domain_range_max()
   local map = Map:new(length, length, 0)

   for i, v in ipairs(variables) do
      map:blit(v.chunk, assignment[v].x, assignment[v].y, false)
   end

   local function vertex_edge_and_populator()
      local vertex_edge_info = {}
      for _, v in ipairs(variables) do
         vertex_edge_info[v] = {}
      end

      local function mysplit(inputstr, sep)
         local sep = sep or "%s"
         local t = {}
         for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
            table.insert(t, str)
         end
         return t
      end
      for k, v in pairs(edge_matches) do
         local split_string = mysplit(k, ":")
         local edge_1 = v.edge_1
         local edge_2 = v.edge_2

         local slope = edge_1[1] - edge_1[2]
         local overlapping_points = {}
         for i = 2, #edge_1 - 1 do
            for i2 = 2, #edge_2 - 1 do
               if edge_1[i] == edge_2[i2] then table.insert(overlapping_points, edge_1[i]) end
            end
         end

         table.sort(overlapping_points, function(a, b)
            if a.x == b.x then
               return a.y < b.y
            else
               return a.x < b.x
            end
         end)

         local vertex = variables[split_string[1]]
         for _, edge in ipairs(vertex.edges) do
            if variables[split_string[2]] == edge.vertex then
               local info = {
                  chunk_offset = assignment[vertex],
                  points = overlapping_points,
                  slope = slope,
               }

               vertex_edge_info[variables[split_string[1]]][variables[split_string[2]]] = info
               table.insert(vertex_edge_info[variables[split_string[1]]], info)

               vertex_edge_info[variables[split_string[2]]][variables[split_string[1]]] = info
               table.insert(vertex_edge_info[variables[split_string[2]]], info)

               edge.meta.callback(map, info)
            end
         end
      end

      for i, v in ipairs(graph.vertices) do
         local info = {
            vertex = v,
            map = map,
            chunk = v.chunk,
            offset = assignment[v],
            polygon = v.polygon,
            edges = vertex_edge_info,
         }
         v.parameters:populater(info)
      end
   end

   vertex_edge_and_populator()

   print((love.timer.getTime() - start) * 100)
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
--   for k, v in pairs(copy) do
--     v.pos = v.pos - vec2(left, top)
--   end
--   map.entities.list = copy

--   return map
-- end

function Map:new_from_outline()
   local padding = 1
   local offset = vec2(padding, padding)
   local outline_map = Map:new(self.width + padding * 2, self.height + padding * 2, 1)
      :blit(self, padding, padding, true)

   for x, y in outline_map:for_cells() do
      local is_adjacent_to_air = false
      for k, v in ipairs(Map:getNeighborhood "moore") do
         if outline_map:get_cell(x + v[1], y + v[2]) == 0 then
            is_adjacent_to_air = true
            break
         end
      end

      if not is_adjacent_to_air then
         outline_map:set_cell(x, y, 999) -- dummy value
      end
   end

   for x, y in outline_map:for_cells() do
      if outline_map:get_cell(x, y) == 999 then outline_map:set_cell(x, y, 0) end
   end

   return outline_map, offset
end

function Map:new_from_outline_strict()
   local outline_map = Map:new(self.width, self.height, 0)

   local to_check = { { 0, 0 } }
   local checked = {}
   while true do
      local current_tile = table.remove(to_check)
      local x, y = current_tile[1], current_tile[2]

      for k, v in ipairs(Map:getNeighborhood "moore") do
         local x, y = x + v[1], y + v[2]
         if not checked[tostring(x) .. "," .. tostring(y)] then
            if self:get_cell(x, y) == 0 then
               table.insert(to_check, { x, y })
            elseif self:get_cell(x, y) == 1 then
               outline_map:fill_cell(x, y)
            end
         end
      end

      checked[tostring(x) .. "," .. tostring(y)] = true

      if #to_check == 0 then break end
   end

   return outline_map
end

function Map:find_edges()
   local startPos
   for x, y in self:for_cells() do
      if self:get_cell(x, y) == 1 then startPos = vec2(x, y) end
   end

   local edges = { { startPos } }

   local moore = Map:getNeighborhood "moore"
   local vonNeuman = Map:getNeighborhood "vonNeuman"
   local winding = { vonNeuman.e, vonNeuman.s, vonNeuman.w, vonNeuman.n }
   --local winding = {moore.e, moore.se, moore.s, moore.sw, moore.w, moore.nw, moore.n, moore.ne}

   while true do
      local edge = edges[#edges] -- Current edge is the last element
      local start = edge[1] -- Starting position is the first element
      for i, v in ipairs(winding) do
         if
            #edges == 1 -- If there's only one edge
            or not (
               (v[1] == edges[#edges - 1].vec[1] * -1) and (v[2] == edges[#edges - 1].vec[2] * -1)
            ) -- if not the direction we came from
         then
            local x, y = start.x + v[1], start.y + v[2] -- Check from the starting point + a neighbor
            if self:get_cell(x, y) == 1 then -- If that pos is a wall
               edge.vec = { v[1], v[2] } -- Define the edges vector as the neighbor direction
               table.insert(edge, vec2(x, y)) -- insert the position
               break
            end
         end
      end

      repeat -- keep going until you run out of map or reach an empty space
         local x = edge[#edge].x + edge.vec[1]
         local y = edge[#edge].y + edge.vec[2]

         if self:get_cell(x, y) == 1 then table.insert(edge, vec2(x, y)) end
      until self:get_cell(x, y) ~= 1

      if -- if you reach the starting position you've done a full loop
         edge[#edge].x == startPos.x and edge[#edge].y == startPos.y
      then
         break
      end

      table.insert(edges, { edge[#edge] })
   end

   return edges
end

-- -------------------------------------------------------------------------- --

function Map:get_center() return math.floor(self.width / 2), math.floor(self.height / 2) end

function Map:get_center2() return math.ceil(self.width / 2), math.ceil(self.height / 2) end

function Map:get_cell(x, y) return self.cells[x] and self.cells[x][y] or nil end

function Map:set_cell(x, y, v) self.cells[x][y] = v end

function Map:set_cell_checked(x, y, v)
   if self.cells[x] and self.cells[x][y] then self:set_cell(x, y, v) end
end

--Space
function Map:clear_cell(x, y)
   self.cells[x][y] = 0

   return self
end

function Map:clear_cell_checked(x, y)
   if self.map[x] and self.map[x][y] then self:clear_cell(x, y) end

   return self
end

function Map:fill_cell(x, y)
   self.cells[x][y] = 1

   return self
end

-- Rect
function Map:target_rect(x1, y1, x2, y2, func)
   for x = x1, x2 do
      for y = y1, y2 do
         func(x, y)
      end
   end

   return self
end

function Map:clear_rect(x1, y1, x2, y2)
   self:target_rect(x1, y1, x2, y2, function(x, y) self:clear_cell(x, y) end)

   return self
end

function Map:fill_rect(x1, y1, x2, y2)
   self:target_rect(x1, y1, x2, y2, function(x, y) self:fill_cell(x, y) end)

   return self
end

-- Perimeter
function Map:target_perimeter(x1, y1, x2, y2, func)
   Map:target_rect(x1, y1, x2, y2, function(x, y)
      if x == x1 or x == x2 or y == y1 or y == y2 then func(x, y) end
   end)
   return self
end
function Map:clear_perimeter(x1, y1, x2, y2)
   Map:target_perimeter(x1, y1, x2, y2, function(x, y) self:clear_cell(x, y) end)
   return self
end
function Map:fill_perimeter(x1, y1, x2, y2)
   Map:target_perimeter(x1, y1, x2, y2, function(x, y) self:fill_cell(x, y) end)
   return self
end

-- Ellipse
function Map:target_ellipse(cx, cy, radx, rady, func)
   for x = cx - radx, cx + radx do
      for y = cy - rady, cy + rady do
         local dx = (x - cx) ^ 2
         local dy = (y - cy) ^ 2
         if dx / (radx ^ 2) + dy / rady ^ 2 <= 1 then func(x, y) end
      end
   end

   return self
end
function Map:clear_ellipse(cx, cy, radx, rady)
   self:target_ellipse(cx, cy, radx, rady, function(x, y) self:clear_cell(x, y) end)

   return self
end
function Map:fill_ellipse(cx, cy, radx, rady)
   self:target_ellipse(cx, cy, radx, rady, function(x, y) self:fill_cell(x, y) end)

   return self
end

-- Circumference
function Map:target_circumference(cx, cy, radx, rady, func)
   Map:target_ellipse(cx, cy, radx, rady, function(x, y)
      local dx = (x - cx) ^ 2
      local dy = (y - cy) ^ 2
      if dx / (radx ^ 2) + dy / rady ^ 2 >= 0.5 then func(x, y) end
   end)

   return self
end
function Map:clear_circumference(cx, cy, radx, rady)
   self:target_circumference(cx, cy, radx, rady, function(x, y) self:clear_cell(x, y) end)

   return self
end
function Map:fill_circumference(cx, cy, radx, rady)
   self:target_circumference(cx, cy, radx, rady, function(x, y) self:clear_cell(x, y) end)

   return self
end

-- Path
function Map:new_path()
   local path = {
      points = {},
   }
   function path:add_point(vec) table.insert(self.points, vec) end

   function path:get_slope(i, i2) return self.points[i] - self.points[i + 1] end

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
   self:target_path(path, function(x, y) self:clear_cell(x, y) end)
   return self
end
function Map:fill_path(path)
   self:target_path(path, function(x, y) self:fill_cell(x, y) end)
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
      { 0, -1 },
      { 1, 0 },
      { 0, 1 },
      { -1, 0 },

      n = { 0, -1 },
      e = { 1, 0 },
      s = { 0, 1 },
      w = { -1, 0 },
   }

   neighborhood.moore = {
      { 0, -1 },
      { 1, -1 },
      { 1, 0 },
      { 1, 1 },
      { 0, 1 },
      { -1, 1 },
      { -1, 0 },
      { -1, -1 },

      n = { 0, -1 },
      ne = { 1, -1 },
      e = { 1, 0 },
      se = { 1, 1 },
      s = { 0, 1 },
      sw = { -1, 1 },
      w = { -1, 0 },
      nw = { -1, -1 },
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
--         if self:get_cell(x, y) then
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
   local map = Map:new(self.width, self.height, math.huge)

   for i, v in ipairs(start) do
      map:set_cell(v.x, v.y, 0)
   end

   local to_check = start
   local checked = {}

   while true do
      local current_tile = table.remove(to_check)
      local x, y = current_tile.x, current_tile.y
      local minimum_distance_value = map:get_cell(x, y)

      for k, v in ipairs(neighbors) do
         local x, y = x + v[1], y + v[2]

         if self:get_cell(x, y) then
            if not checked[tostring(x) .. "," .. tostring(y)] then
               if self:get_cell(x, y) ~= 1 then
                  table.insert(to_check, { x = x, y = y })
                  map:set_cell(x, y, math.min(minimum_distance_value + 1, map:get_cell(x, y)))
               end
            end
         end
      end

      map:set_cell(x, y, minimum_distance_value)

      checked[tostring(x) .. "," .. tostring(y)] = true

      if #to_check == 0 then break end
   end

   return map, max
end

function Map:aStar(x1, y1, x2, y2)
   local vonNeuman = Map:getNeighborhood "vonNeuman"
   local aStar_map = Map:new(self.width, self.height, 0)

   local toTravel = {}
   local travelled = {}
   local function MDistance(x1, y1, x2, y2) return math.abs(x1 - x2) + math.abs(y1 - y2) end

   local SEMDistance = MDistance(x1, y1, x2, y2)
   local startNode = { x = x1, y = y1, s = 0, e = SEMDistance, t = SEMDistance }
   table.insert(toTravel, startNode)

   while true do
      local nextNode = nil
      local vertexIndex = nil

      for i, v in ipairs(toTravel) do
         if aStar_map.cells[v.x][v.y] == 0 then
            if nextNode == nil then
               nextNode = v
               vertexIndex = i
            elseif v.t < nextNode.t then
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

      if nextNode.x == x2 and nextNode.y == y2 then break end

      for k, v in ipairs(vonNeuman) do
         if
            self:get_cell(nextNode.x + v[1], nextNode.y + v[2]) ~= 1
            and self:get_cell(nextNode.x + v[1], nextNode.y + v[2]) ~= nil
         then
            local newNode = {}
            newNode.x = nextNode.x + v[1]
            newNode.y = nextNode.y + v[2]
            newNode.s = nextNode.s + 1
            newNode.e = MDistance(newNode.x, newNode.y, x2, y2)
            newNode.t = newNode.s + newNode.e

            local match = nil
            for i, v in ipairs(toTravel) do
               if v.x == newNode.x and v.y == newNode.y then match = { s = v.s, i = i } end
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
      if v.s > furthestS then furthestS = v.s end
   end

   local endNode = { x = x2, y = y2, s = furthestS, e = 0, t = furthestS }
   table.insert(aStar_path, endNode)

   while #aStar_path ~= furthestS + 1 do
      for i, v in ipairs(travelled) do
         if v.s == aStar_path[#aStar_path].s - 1 then
            if MDistance(v.x, v.y, aStar_path[#aStar_path].x, aStar_path[#aStar_path].y) == 1 then
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

-- DLA needs a cleared cell to start from and a space to clear
function Map:DLAInOut(attempts)
   local attempts = attempts or 1000
   local attempt_counter = 0

   local function clamp(n, min, max)
      local n = math.max(math.min(n, max), min)
      return n
   end

   while true do
      local neighbors = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
      local x1, y1 = nil, nil
      local x2, y2 = nil, nil

      repeat
         x1 = love.math.random(2, self.width - 2)
         y1 = love.math.random(2, self.height - 2)
         attempt_counter = attempt_counter + 1
      until self:get_cell(x1, y1) == 0 or attempt_counter > attempts

      local n = 0
      while n ~= 4 do
         local vec = love.math.random(1, 4 - n)
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

   local x1, y1 = nil, nil
   repeat
      x1 = love.math.random(2, self.width - 2)
      y1 = love.math.random(2, self.height - 2)
   until self:get_cell(x1, y1) == 1

   local function clamp(n, min, max)
      local n = math.max(math.min(n, max), min)
      return n
   end
   local neighbors = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
   local x2, y2 = nil, nil

   repeat
      x2, y2 = x1, y1

      local vec = love.math.random(1, 4)
      x1 = clamp(x1 + neighbors[vec][1], 2, self.width - 2)
      y1 = clamp(y1 + neighbors[vec][2], 2, self.height - 2)
   until self:get_cell(x1, y1) == 0

   self:clear_cell(x2, y2)
end

function Map:drunkWalk(x, y, exitFunc)
   local path = Map:new_path()
   path:add_point(vec2(x, y))

   local neighbors = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
   local function clamp(n, min, max)
      local n = math.max(math.min(n, max), min)
      return n
   end

   local i = 0
   repeat
      i = i + 1
      local vec = love.math.random(1, 4)
      x = clamp(x + neighbors[vec][1], 0, self.width)
      y = clamp(y + neighbors[vec][2], 0, self.height)

      path:add_point(vec2(x, y))
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

function Map:tunneler(x1, y1, width, turnThreshold, steps, startingDirection, min_turn)
   local x, y = x1, y1
   local directions = {
      { 1, 0 }, -- Right
      { -1, 0 }, -- Left
      { 0, 1 }, -- Down
      { 0, -1 }, -- Up
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

      if changed then change_direction(x, y, width) end

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
      local queue = { { x = x, y = y } }

      while #queue > 0 do
         local current = table.remove(queue, 1)
         local x, y = current.x, current.y

         if self:get_cell(x, y) ~= 1 then goto continue end

         self:set_cell(x, y, 0)

         local neighbors = {
            { x = x + 1, y = y },
            { x = x - 1, y = y },
            { x = x, y = y + 1 },
            { x = x, y = y - 1 },
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
            for _, v in ipairs { { -1, 0 }, { 1, 0 }, { 0, -1 }, { 0, 1 } } do
               local nx, ny = x + v[1], y + v[2]
               if self:get_cell(nx, ny) == 1 then wall_neighbors = wall_neighbors + 1 end
            end

            if wall_neighbors < 2 then flood_fill(x, y) end
         end
      end
   end
end

function Map:find_wall_tiles_to_remove()
   local wall_tiles_to_remove = {}

   local vonNeuman = {
      n = { 0, -1 },
      e = { 1, 0 },
      s = { 0, 1 },
      w = { -1, 0 },
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
               if
                  self:get_cell(floor1_x, floor1_y) ~= nil
                  and self:get_cell(floor2_x, floor2_y) ~= nil
                  and self:get_cell(floor1_x, floor1_y) == 0
                  and self:get_cell(floor2_x, floor2_y) == 0
               then
                  table.insert(
                     opposite_floor_tiles,
                     { { x = floor1_x, y = floor1_y }, { x = floor2_x, y = floor2_y } }
                  )
               end
            end
            if #opposite_floor_tiles > 0 then
               table.insert(
                  wall_tiles_to_remove,
                  { x = x, y = y, opposite_floor_tiles = opposite_floor_tiles }
               )
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

   if wall_to_remove then self:set_cell(wall_to_remove.x, wall_to_remove.y, 0) end
end

return Map
