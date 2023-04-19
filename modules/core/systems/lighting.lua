local System = require("core.system")
local Grid = require("structures.grid")
local LightColor = require("structures.lighting.lightcolor")
local LightBuffer = require("structures.lighting.lightbuffer")
local SparseMap = require("structures.sparsemap")
local BoundingBox = require("math.bounding_box")

local LightingSystem = System:extend()
LightingSystem.name = "Lighting"

LightingSystem.__lights = nil
LightingSystem.__submaps = nil
LightingSystem.__lightMap = nil

function LightingSystem:__new(level)
<<<<<<< HEAD
   self.__lights = SparseMap()
   self.__temporaryLights = {}
   self.__opaqueCache = {}
   self.rebuilt = false
end

function LightingSystem:initialize(level)
   self.__lightMap = LightBuffer(level.width, level.height)
   self.__effectLightMap = LightBuffer(level.width, level.height)
end

function LightingSystem:postInitialize(level)
   -- rebuild the lighting map after all actors have been added
   -- we pass in a dt of 0 to trigger the effect lighting map rebuild
   self:forceRebuildLighting(level)
   self:forceRebuildLighting(level, 0)
end

function LightingSystem:afterOpacityChanged(level, x, y) self:forceRebuildLighting(level) end
=======
	self.__lights = SparseMap()
	self.__temporaryLights = {}
	self.__opaqueCache = {}
	self.rebuilt = false
end

function LightingSystem:initialize(level)
	self.__lightMap = LightBuffer(level.width, level.height)
	self.__effectLightMap = LightBuffer(level.width, level.height)
end

function LightingSystem:postInitialize(level)
	-- rebuild the lighting map after all actors have been added
	-- we pass in a dt of 0 to trigger the effect lighting map rebuild
	self:forceRebuildLighting(level)
	self:forceRebuildLighting(level, 0)
end

function LightingSystem:afterOpacityChanged(level, x, y)
	self:forceRebuildLighting(level)
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

-- called when an Actor takes an Action
function LightingSystem:afterAction(level, actor, action)
	self:rebuildLighting(level)
end

-- called after an actor has moved
function LightingSystem:onMove(level, actor)
	self:rebuildLighting(level)
end

function LightingSystem:onActorAdded(level, actor)
	self:rebuildLighting(level)
end

function LightingSystem:onActorRemoved(level, actor)
	self:rebuildLighting(level)
end

function LightingSystem:getLight(x, y, dt)
<<<<<<< HEAD
   local lightMap = self.__lightMap
   if dt then lightMap = self.__effectLightMap end

   return lightMap:getLight(x, y)
end

function LightingSystem:getLightingAt(x, y, fov, dt)
   local foundOpaqueActor = false

   if fov:get(x, y) and not self.owner:getCellOpaque(x, y) then return self:getLight(x, y, dt) end

   local cols = {}

   for i = -1, 1, 1 do
      for j = -1, 1, 1 do
         if not (i == 0 and j == 0) then
            if fov:get(x + i, y + j) and not self.owner:getCellOpaque(x + i, y + j) then
               table.insert(cols, self:getLight(x + i, y + j, dt))
            end
         end
      end
   end

   local finalCol = { 0, 0, 0 }
   local count = #cols
   for _, col in ipairs(cols) do
      finalCol[1] = finalCol[1] + col.r
      finalCol[2] = finalCol[2] + col.g
      finalCol[3] = finalCol[3] + col.b
   end

   if count > 0 then
      finalCol[1] = math.floor(finalCol[1] / count)
      finalCol[2] = math.floor(finalCol[2] / count)
      finalCol[3] = math.floor(finalCol[3] / count)
   end

   return LightColor(finalCol[1], finalCol[2], finalCol[3])
end

function LightingSystem:getBrightness(x, y, fov, seen)
   local lcolor = self:getLightingAt(x, y, fov, seen)
   return lcolor:average_brightness()
end

function LightingSystem:invalidateLighting(level)
   if not self.light or not self.lighting.setFOV then return end -- check if lighting is initialized

   -- This resets our lighting. rotLove doesn't offer a better way to do this.
   self:updateLighting(false)
=======
	local lightMap = self.__lightMap
	if dt then
		lightMap = self.__effectLightMap
	end

	return lightMap:getLight(x, y)
end

function LightingSystem:getLightingAt(x, y, fov, dt)
	local foundOpaqueActor = false

	if fov:get(x, y) and not self.owner:getCellOpaque(x, y) then
		return self:getLight(x, y, dt)
	end

	local cols = {}

	for i = -1, 1, 1 do
		for j = -1, 1, 1 do
			if not (i == 0 and j == 0) then
				if fov:get(x + i, y + j) and not self.owner:getCellOpaque(x + i, y + j) then
					table.insert(cols, self:getLight(x + i, y + j, dt))
				end
			end
		end
	end

	local finalCol = { 0, 0, 0 }
	local count = #cols
	for _, col in ipairs(cols) do
		finalCol[1] = finalCol[1] + col.r
		finalCol[2] = finalCol[2] + col.g
		finalCol[3] = finalCol[3] + col.b
	end

	if count > 0 then
		finalCol[1] = math.floor(finalCol[1] / count)
		finalCol[2] = math.floor(finalCol[2] / count)
		finalCol[3] = math.floor(finalCol[3] / count)
	end

	return LightColor(finalCol[1], finalCol[2], finalCol[3])
end

function LightingSystem:getBrightness(x, y, fov, seen)
	local lcolor = self:getLightingAt(x, y, fov, seen)
	return lcolor:average_brightness()
end

function LightingSystem:invalidateLighting(level)
	if not self.light or not self.lighting.setFOV then
		return
	end -- check if lighting is initialized

	-- This resets our lighting. rotLove doesn't offer a better way to do this.
	self:updateLighting(false)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

-- Returns the actual lights that are in the level not the lightmap which holds post-spread light values.
function LightingSystem:getLights(level)
	return self.__lights
end

--- Creates a list of all of the light components in the level and returns it.
function LightingSystem:__buildLightList(level)
<<<<<<< HEAD
   local lights = SparseMap()

   for actor, light_component in level:eachActor(components.Light) do
      local x, y = actor.position.x, actor.position.y
      lights:insert(x, y, light_component)
   end

   for _, system in ipairs(level.systems) do
      if system.registerLights then
         -- Systems can register their own lights by implementing a registerLights function
         -- TODO: move from actors with light components to a system that registers lights
         -- directly with the lighting system.
         for _, light_tuple in ipairs(system:registerLights(level)) do
            local light_component = light_tuple[3]
            local x, y = light_tuple[1], light_tuple[2]

            lights:insert(x, y, light_component)
         end
      end
   end

   return lights
end

function LightingSystem:__checkLightList(candidate, dt)
   local candidate_count = candidate:count()
   local light_count = self.__lights:count()

   local needs_update = {}
   local previous = {}
   local missing = {}

   for x, y, cell in self.__lights:each() do
      if not candidate:has(x, y, cell) then table.insert(missing, { x, y, cell }) end
   end

   -- Find new lights or lights that have changed position
   for x, y, candidate_cell in candidate:each() do
      if not self.__lights:has(x, y, candidate_cell) or (dt and candidate_cell.effect) then
         table.insert(needs_update, { x, y, candidate_cell })
      end
   end

   local should_rebuild = #needs_update > 0

   if candidate_count < light_count then should_rebuild = true end

   return should_rebuild, needs_update, missing
end

function LightingSystem:forceRebuildLighting(level, dt)
   self.__needsUpdate = nil
   self.__lights = self:__buildLightList(level)
   self:__rebuild(level, dt)
end

function LightingSystem:rebuildLighting(level, dt)
   local candidate = self:__buildLightList(level)
   self.__needsUpdate = nil

   -- if our light list hasn't changed, we don't need to rebuild the lighting
   -- looping through the qctors and building a list is way cheaper than rebuilding the lighting
   -- so we do this check first.
   local should_update, needs_update, missing = self:__checkLightList(candidate, dt)
   if not should_update and not dt then
      self.rebuilt = false
      return
   end

   self.__needsUpdate = needs_update
   self.__missing = missing
   self.__lights = candidate
   self:__rebuild(level, dt)
end

function LightingSystem:__rebuild(level, dt)
   local lightMap = self.__lightMap
   if dt then lightMap = self.__effectLightMap end

   self.rebuilt = true

   local rects = {}

   if self.__needsUpdate == nil then
      for x, y, light in self.__lights:each() do
         -- If we have a cache clear it, if not create one.
         if light.__cache == nil then
            light.__cache = LightBuffer(61, 61)
         else
            light.__cache:clear()
         end

         self.x = x
         self.y = y
         local color = light.color
         if dt and light.effect then color = light.effect(dt, light.color) end

         local falloff = light.falloff
         local cache = light.__cache
         light.__bounds = self:__spreadLight(level, 31, 31, x - 31, y - 31, color, cache, falloff)
      end
   else
      for _, updateEntry in ipairs(self.__needsUpdate) do
         local x, y, light = updateEntry[1], updateEntry[2], updateEntry[3]
         local bounds = light.__bounds

         -- If we have a cache clear it, if not create one.
         if light.__cache == nil then
            light.__cache = LightBuffer(61, 61)
         else
            light.__cache:clear()
         end

         local color = light.color
         if dt and light.effect then color = light.effect(dt, light.color) end

         local falloff = light.falloff
         local cache = light.__cache
         light.__bounds = self:__spreadLight(level, 31, 31, x - 31, y - 31, color, cache, falloff)

         if bounds then
            table.insert(rects, bounds:union(light.__bounds))
         else
            table.insert(rects, light.__bounds)
         end
      end
   end

   if missing then
      for _, missing in ipairs(self.__missing) do
         local x, y, light = missing[1], missing[2], missing[3]
         local bounds = light.__bounds

         if bounds then table.insert(rects, bounds) end
      end
   end

   if #rects == 0 then
      lightMap:clear()
      for x, y, light in self.__lights:each() do
         lightMap:accumulate_buffer(x - 30, y - 30, light.__cache)
      end
   else
      for _, rect in ipairs(rects) do
         lightMap:clear_rect(rect)
         for x, y, light in self.__lights:each() do
            if rect:intersects(light.__bounds) then
               lightMap:accumulate_buffer_masked(x - 30, y - 30, light.__cache, rect)
            end
         end
      end
   end
end

function LightingSystem:__getLightReduction(level, row, col)
   if not level:getCell(row, col) then return 0 end
   local reduction = level:getCell(row, col).lightReduction or 0
   local actors = level:getActorsAt(row, col)

   for _, actor in ipairs(actors) do
      local lightOccluderComponent = actor:getComponent(components.Light_occluder)
      if lightOccluderComponent then reduction = reduction + lightOccluderComponent.reduction end
   end

   return reduction
end

local rowDirections = { -1, 1, 0, 0, -1, -1, 1, 1 }
local colDirections = { 0, 0, -1, 1, -1, 1, -1, 1 }

function LightingSystem:__spreadLight(
   level,
   row,
   col,
   offsetx,
   offsety,
   lightLevel,
   lightMap,
   falloffFactor
)
   local queue = { { row, col, lightLevel, 0 } }
   local visited = ROT.Type.Grid:new()

   local minRow, maxRow, minCol, maxCol = row, row, col, col

   local function processCell(curRow, curCol, curLightLevel, depth)
      if
         level:getCellOpaque(curRow + offsetx, curCol + offsety)
         or visited:getCell(curRow, curCol)
      then
         return
      end

      lightMap:setWithFFIStruct(curRow, curCol, curLightLevel)
      visited:setCell(curRow, curCol, true)

      minRow, maxRow = math.min(minRow, curRow), math.max(maxRow, curRow)
      minCol, maxCol = math.min(minCol, curCol), math.max(maxCol, curCol)

      for i = 1, 8 do
         local newRow = curRow + rowDirections[i]
         local newCol = curCol + colDirections[i]
         if not visited:getCell(newRow, newCol) then
            local reducedLightLevel

            reducedLightLevel = curLightLevel:subtract_scalar(
               math.floor(depth * falloffFactor)
                  + self:__getLightReduction(level, curRow + offsetx, curCol + offsety)
            )

            if reducedLightLevel.r > 0 or reducedLightLevel.g > 0 or reducedLightLevel.b > 0 then
               table.insert(queue, { newRow, newCol, reducedLightLevel, depth + 1 })
            end
         end
      end
   end

   while #queue > 0 do
      local current = table.remove(queue, 1)
      local curRow, curCol, curLightLevel, depth = current[1], current[2], current[3], current[4]
      processCell(curRow, curCol, curLightLevel, depth + 1)
   end

   local minRow = minRow + offsetx
   local minCol = minCol + offsety
   local maxRow = maxRow + offsetx
   local maxCol = maxCol + offsety
   return BoundingBox(minRow, minCol, maxRow, maxCol)
=======
	local lights = SparseMap()

	for actor, light_component in level:eachActor(components.Light) do
		local x, y = actor.position.x, actor.position.y
		lights:insert(x, y, light_component)
	end

	for _, system in ipairs(level.systems) do
		if system.registerLights then
			-- Systems can register their own lights by implementing a registerLights function
			-- TODO: move from actors with light components to a system that registers lights
			-- directly with the lighting system.
			for _, light_tuple in ipairs(system:registerLights(level)) do
				local light_component = light_tuple[3]
				local x, y = light_tuple[1], light_tuple[2]

				lights:insert(x, y, light_component)
			end
		end
	end

	return lights
end

function LightingSystem:__checkLightList(candidate, dt)
	local candidate_count = candidate:count()
	local light_count = self.__lights:count()

	local needs_update = {}
	local previous = {}
	local missing = {}

	for x, y, cell in self.__lights:each() do
		if not candidate:has(x, y, cell) then
			table.insert(missing, { x, y, cell })
		end
	end

	-- Find new lights or lights that have changed position
	for x, y, candidate_cell in candidate:each() do
		if not self.__lights:has(x, y, candidate_cell) or (dt and candidate_cell.effect) then
			table.insert(needs_update, { x, y, candidate_cell })
		end
	end

	local should_rebuild = #needs_update > 0

	if candidate_count < light_count then
		should_rebuild = true
	end

	return should_rebuild, needs_update, missing
end

function LightingSystem:forceRebuildLighting(level, dt)
	self.__needsUpdate = nil
	self.__lights = self:__buildLightList(level)
	self:__rebuild(level, dt)
end

function LightingSystem:rebuildLighting(level, dt)
	local candidate = self:__buildLightList(level)
	self.__needsUpdate = nil

	-- if our light list hasn't changed, we don't need to rebuild the lighting
	-- looping through the qctors and building a list is way cheaper than rebuilding the lighting
	-- so we do this check first.
	local should_update, needs_update, missing = self:__checkLightList(candidate, dt)
	if not should_update and not dt then
		self.rebuilt = false
		return
	end

	self.__needsUpdate = needs_update
	self.__missing = missing
	self.__lights = candidate
	self:__rebuild(level, dt)
end

function LightingSystem:__rebuild(level, dt)
	local lightMap = self.__lightMap
	if dt then
		lightMap = self.__effectLightMap
	end

	self.rebuilt = true

	local rects = {}

	if self.__needsUpdate == nil then
		for x, y, light in self.__lights:each() do
			-- If we have a cache clear it, if not create one.
			if light.__cache == nil then
				light.__cache = LightBuffer(61, 61)
			else
				light.__cache:clear()
			end

			self.x = x
			self.y = y
			local color = light.color
			if dt and light.effect then
				color = light.effect(dt, light.color)
			end

			local falloff = light.falloff
			local cache = light.__cache
			light.__bounds = self:__spreadLight(level, 31, 31, x - 31, y - 31, color, cache, falloff)
		end
	else
		for _, updateEntry in ipairs(self.__needsUpdate) do
			local x, y, light = updateEntry[1], updateEntry[2], updateEntry[3]
			local bounds = light.__bounds

			-- If we have a cache clear it, if not create one.
			if light.__cache == nil then
				light.__cache = LightBuffer(61, 61)
			else
				light.__cache:clear()
			end

			local color = light.color
			if dt and light.effect then
				color = light.effect(dt, light.color)
			end

			local falloff = light.falloff
			local cache = light.__cache
			light.__bounds = self:__spreadLight(level, 31, 31, x - 31, y - 31, color, cache, falloff)

			if bounds then
				table.insert(rects, bounds:union(light.__bounds))
			else
				table.insert(rects, light.__bounds)
			end
		end
	end

	if missing then
		for _, missing in ipairs(self.__missing) do
			local x, y, light = missing[1], missing[2], missing[3]
			local bounds = light.__bounds

			if bounds then
				table.insert(rects, bounds)
			end
		end
	end

	if #rects == 0 then
		lightMap:clear()
		for x, y, light in self.__lights:each() do
			lightMap:accumulate_buffer(x - 30, y - 30, light.__cache)
		end
	else
		for _, rect in ipairs(rects) do
			lightMap:clear_rect(rect)
			for x, y, light in self.__lights:each() do
				if rect:intersects(light.__bounds) then
					lightMap:accumulate_buffer_masked(x - 30, y - 30, light.__cache, rect)
				end
			end
		end
	end
end

function LightingSystem:__getLightReduction(level, row, col)
	if not level:getCell(row, col) then
		return 0
	end
	local reduction = level:getCell(row, col).lightReduction or 0
	local actors = level:getActorsAt(row, col)

	for _, actor in ipairs(actors) do
		local lightOccluderComponent = actor:getComponent(components.Light_occluder)
		if lightOccluderComponent then
			reduction = reduction + lightOccluderComponent.reduction
		end
	end

	return reduction
end

local rowDirections = { -1, 1, 0, 0, -1, -1, 1, 1 }
local colDirections = { 0, 0, -1, 1, -1, 1, -1, 1 }

function LightingSystem:__spreadLight(level, row, col, offsetx, offsety, lightLevel, lightMap, falloffFactor)
	local queue = { { row, col, lightLevel, 0 } }
	local visited = ROT.Type.Grid:new()

	local minRow, maxRow, minCol, maxCol = row, row, col, col

	local function processCell(curRow, curCol, curLightLevel, depth)
		if level:getCellOpaque(curRow + offsetx, curCol + offsety) or visited:getCell(curRow, curCol) then
			return
		end

		lightMap:setWithFFIStruct(curRow, curCol, curLightLevel)
		visited:setCell(curRow, curCol, true)

		minRow, maxRow = math.min(minRow, curRow), math.max(maxRow, curRow)
		minCol, maxCol = math.min(minCol, curCol), math.max(maxCol, curCol)

		for i = 1, 8 do
			local newRow = curRow + rowDirections[i]
			local newCol = curCol + colDirections[i]
			if not visited:getCell(newRow, newCol) then
				local reducedLightLevel

				reducedLightLevel = curLightLevel:subtract_scalar(
					math.floor(depth * falloffFactor)
						+ self:__getLightReduction(level, curRow + offsetx, curCol + offsety)
				)

				if reducedLightLevel.r > 0 or reducedLightLevel.g > 0 or reducedLightLevel.b > 0 then
					table.insert(queue, { newRow, newCol, reducedLightLevel, depth + 1 })
				end
			end
		end
	end

	while #queue > 0 do
		local current = table.remove(queue, 1)
		local curRow, curCol, curLightLevel, depth = current[1], current[2], current[3], current[4]
		processCell(curRow, curCol, curLightLevel, depth + 1)
	end

	local minRow = minRow + offsetx
	local minCol = minCol + offsety
	local maxRow = maxRow + offsetx
	local maxCol = maxCol + offsety
	return BoundingBox(minRow, minCol, maxRow, maxCol)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return LightingSystem
