local Collideable = require("modules.core.components.collideable")
local Vector2 = require("math.vector")

local CollideableBFS = Collideable:extend()
CollideableBFS.name = "CollideableBFS"

function CollideableBFS:__new(size)
<<<<<<< HEAD
   self.size = size or 1
   self.occupiedTiles = { Vector2(0, 0) }
end

function CollideableBFS:eachCellGlobal(actor)
   local index = 1

   return function()
      if index <= #self.occupiedTiles then
         local value = self.occupiedTiles[index] + actor.position
         index = index + 1
         return value
      end
   end
end

function CollideableBFS:eachCell()
   local index = 1

   return function()
      if index <= #self.occupiedTiles then
         local value = self.occupiedTiles[index]
         index = index + 1
         return value
      end
   end
end

local function hash(x, y)
   return x and y * 0x4000000 + x or false --  26-bit x and y
end

function CollideableBFS:floodFill(level, origin, max_tiles, actor, biasDirection)
   local visited = {}
   local queue = {}
   local count = 0
   local directions = {
      Vector2(1, 0),
      Vector2(-1, 0),
      Vector2(0, 1),
      Vector2(0, -1),
      Vector2(1, 1),
      Vector2(-1, 1),
      Vector2(1, -1),
      Vector2(-1, -1),
   }

   if direction then
      table.sort(directions, function(a, b)
         local distanceA = (a - biasDirection):length()
         local distanceB = (b - biasDirection):length()
         return distanceA > distanceB
      end)
   end

   table.insert(queue, origin)
   visited[hash(origin.x, origin.y)] = true
   count = count + 1

   while #queue > 0 do
      local current = table.remove(queue, 1)

      local neighbors = {}
      for _, dir in ipairs(directions) do
         local neighbor = current + dir
         if
            not visited[hash(neighbor.x, neighbor.y)]
            and level:getCellPassable(neighbor.x, neighbor.y, actor)
         then
            table.insert(neighbors, neighbor)
         end
      end

      for _, neighbor in ipairs(neighbors) do
         visited[hash(neighbor.x, neighbor.y)] = true
         table.insert(queue, neighbor)
         count = count + 1

         if count >= max_tiles then break end
      end

      if count >= max_tiles then break end
   end

   local tiles = {}
   for k, v in pairs(visited) do
      local x = k % 0x4000000
      local y = (k - x) / 0x4000000
      table.insert(tiles, Vector2(x, y))
   end

   return tiles
end

function CollideableBFS:moveCandidate(level, actor, direction)
   local max_tiles = self.size
   local list =
      self:floodFill(level, actor.position + direction, max_tiles, actor, direction * 1000)

   assert(#list == max_tiles, "too many tiles visited")
   return function() return table.remove(list, 1) end
end

function CollideableBFS:acceptedCandidate(level, actor, direction)
   local max_tiles = self.size

   local visited = self:floodFill(level, actor.position, max_tiles, actor, direction * 1000)
   assert(#visited == max_tiles, "too many tiles visited")
   for i = 1, #visited do
      visited[i] = visited[i] - actor.position
   end

   self.occupiedTiles = visited
end

-- called if our moveCandidate is blocked by another actor
function CollideableBFS:trySqueeze(level, actor, direction, rejected) return nil end
=======
	self.size = size or 1
	self.occupiedTiles = { Vector2(0, 0) }
end

function CollideableBFS:eachCellGlobal(actor)
	local index = 1

	return function()
		if index <= #self.occupiedTiles then
			local value = self.occupiedTiles[index] + actor.position
			index = index + 1
			return value
		end
	end
end

function CollideableBFS:eachCell()
	local index = 1

	return function()
		if index <= #self.occupiedTiles then
			local value = self.occupiedTiles[index]
			index = index + 1
			return value
		end
	end
end

local function hash(x, y)
	return x and y * 0x4000000 + x or false --  26-bit x and y
end

function CollideableBFS:floodFill(level, origin, max_tiles, actor, biasDirection)
	local visited = {}
	local queue = {}
	local count = 0
	local directions = {
		Vector2(1, 0),
		Vector2(-1, 0),
		Vector2(0, 1),
		Vector2(0, -1),
		Vector2(1, 1),
		Vector2(-1, 1),
		Vector2(1, -1),
		Vector2(-1, -1),
	}

	if direction then
		table.sort(directions, function(a, b)
			local distanceA = (a - biasDirection):length()
			local distanceB = (b - biasDirection):length()
			return distanceA > distanceB
		end)
	end

	table.insert(queue, origin)
	visited[hash(origin.x, origin.y)] = true
	count = count + 1

	while #queue > 0 do
		local current = table.remove(queue, 1)

		local neighbors = {}
		for _, dir in ipairs(directions) do
			local neighbor = current + dir
			if not visited[hash(neighbor.x, neighbor.y)] and level:getCellPassable(neighbor.x, neighbor.y, actor) then
				table.insert(neighbors, neighbor)
			end
		end

		for _, neighbor in ipairs(neighbors) do
			visited[hash(neighbor.x, neighbor.y)] = true
			table.insert(queue, neighbor)
			count = count + 1

			if count >= max_tiles then
				break
			end
		end

		if count >= max_tiles then
			break
		end
	end

	local tiles = {}
	for k, v in pairs(visited) do
		local x = k % 0x4000000
		local y = (k - x) / 0x4000000
		table.insert(tiles, Vector2(x, y))
	end

	return tiles
end

function CollideableBFS:moveCandidate(level, actor, direction)
	local max_tiles = self.size
	local list = self:floodFill(level, actor.position + direction, max_tiles, actor, direction * 1000)

	assert(#list == max_tiles, "too many tiles visited")
	return function()
		return table.remove(list, 1)
	end
end

function CollideableBFS:acceptedCandidate(level, actor, direction)
	local max_tiles = self.size

	local visited = self:floodFill(level, actor.position, max_tiles, actor, direction * 1000)
	assert(#visited == max_tiles, "too many tiles visited")
	for i = 1, #visited do
		visited[i] = visited[i] - actor.position
	end

	self.occupiedTiles = visited
end

-- called if our moveCandidate is blocked by another actor
function CollideableBFS:trySqueeze(level, actor, direction, rejected)
	return nil
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return CollideableBFS
