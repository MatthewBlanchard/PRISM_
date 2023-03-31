local System = require "system"
local Grid = require "grid"
local LightColor = require "lighting.lightcolor"
local LightBuffer = require "lighting.lightbuffer"
local SparseMap = require "sparsemap"

local LightingSystem = System:extend()
LightingSystem.name = "Lighting"

LightingSystem.__lights = nil
LightingSystem.__submaps = nil
LightingSystem.__lightMap = nil

function LightingSystem:__new(level)
    self.__lights = SparseMap()
    self.__temporaryLights = {}
    self.__opaqueCache = {}
    self.rebuilt = false
end

function LightingSystem:initialize(level)
    self.__lightMap = LightBuffer(level.width, level.height)
    self.__effectLightMap = LightBuffer(level.width, level.height)
    self.__fov = ROT.FOV.Recursive(self:createVisibilityClosure(level))
    self:forceRebuildLighting(level)
end

function LightingSystem:beforeAction(level, actor, action)
    for actor in level:eachActor() do
        self.__opaqueCache[actor] = actor.blocksVision
    end
end
-- called when an Actor takes an Action
function LightingSystem:afterAction(level, actor, action)
    local force_rebuild = false
    for actor in level:eachActor() do
        if self.__opaqueCache[actor] ~= actor.blocksVision then
            force_rebuild = true
        end
        self.__opaqueCache[actor] = nil
    end

    if force_rebuild then
        self:forceRebuildLighting(level)
    else
        self:rebuildLighting(level)
    end
end

-- called after an actor has moved
function LightingSystem:onMove(level, actor) self:rebuildLighting(level) end

function LightingSystem:onActorAdded(level, actor) self:rebuildLighting(level) end

function LightingSystem:onActorRemoved(level, actor) self:rebuildLighting(level) end

function LightingSystem:getLight(x, y, dt)
    local lightMap = self.__lightMap
    if dt then
        print "YEET"
        lightMap = self.__effectLightMap
    end

    return lightMap:getLight(x, y)
end

function LightingSystem:getLightingAt(x, y, fov, dt)
    local foundOpaqueActor = false

    if fov[x] and fov[x][y] and self.owner:getCellVisibility(x, y) then
        return self:getLight(x, y, dt)
    end

    local cols = {}

    for i = -1, 1, 1 do
        for j = -1, 1, 1 do
            if not (i == 0 and j == 0) then
                if fov[x + i] and fov[x + i][y + j] and self.owner:getCellVisibility(x + i, y + j) then
                    table.insert(cols, self:getLight(x + i, y + j, dt))
                end
            end
        end
    end

    local finalCol = {0, 0, 0}
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
end

-- Returns the actual lights that are in the level not the lightmap which holds post-spread light values.
function LightingSystem:getLights(level) return self.__lights end

--- Creates a list of all of the light components in the level and returns it.
function LightingSystem:__buildLightList(level)
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

    -- Find new lights or lights that have changed position
    for x, y, candidate_cell in candidate:each() do
        if not self.__lights:has(x, y, candidate_cell) or (dt and candidate_cell.effect) then
            table.insert(needs_update, {x, y, candidate_cell})
        end
    end

    local should_rebuild = #needs_update > 0

    if candidate_count < light_count then
        should_rebuild = true
    end

    return should_rebuild, needs_update
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
    local should_update, needs_update = self:__checkLightList(candidate, dt)
    if not should_update and not dt then
        self.rebuilt = false
        return
    end

    self.__needsUpdate = needs_update

    self.__lights = candidate
    self:__rebuild(level, dt)

    if level:getSystem("Sight") then
        for actor in level:eachActor() do
            level:getSystem("Sight"):updateFOV(level, actor)
        end
    end
end

function LightingSystem:__rebuild(level, dt)
    local lightMap = self.__lightMap
    if dt then
        lightMap = self.__effectLightMap
    end

    self.rebuilt = true
    lightMap:clear()

    if self.__needsUpdate == nil then
        for x, y, light in self.__lights:each() do
            light.__cache = LightBuffer(61, 61)
            self.x = x
            self.y = y
            local color = light.color
            if dt and light.effect then
                color = light.effect(dt, light.color)
            end
            self:__spreadLight(level, 31, 31, x - 31, y - 31, color, light.__cache, light.falloff)
        end
    else
        for _, updateEntry in pairs(self.__needsUpdate) do
            local x, y, light = updateEntry[1], updateEntry[2], updateEntry[3]
            light.__cache = LightBuffer(61, 61)
            local color = light.color
            if dt and light.effect then
                color = light.effect(dt, light.color)
            end
            self:__spreadLight(level, 31, 31, x - 31, y - 31, color, light.__cache, light.falloff)
        end
    end

    for x, y, light in self.__lights:each() do
        lightMap:accumulate_buffer(x - 30, y - 30, light.__cache)
    end
end

function LightingSystem:__isOpaque(level, row, col)
    return not level:getCellVisibility(row, col)
end

function LightingSystem:__getLightReduction(level, row, col)
    return level:getCell(row, col).lightReduction or 1
end

local rowDirections = {-1, 1, 0, 0, -1, -1, 1, 1}
local colDirections = {0, 0, -1, 1, -1, 1, -1, 1}

function LightingSystem:__spreadLight(level, row, col, offsetx, offsety, lightLevel, lightMap, falloffFactor)
    local queue = {{row, col, lightLevel, 0}}
    local visited = ROT.Type.Grid:new()

    local function processCell(curRow, curCol, curLightLevel, depth)
        if self:__isOpaque(level, curRow + offsetx, curCol + offsety) or visited:getCell(curRow, curCol) then return end

        lightMap:setWithFFIStruct(curRow, curCol, curLightLevel)
        visited:setCell(curRow, curCol, true)

        for i = 1, 8 do
            local newRow = curRow + rowDirections[i]
            local newCol = curCol + colDirections[i]
            if not visited:getCell(newRow, newCol) then
                local reducedLightLevel = curLightLevel:subtract_scalar(
                    math.floor(depth * falloffFactor) + self:__getLightReduction(level, curRow + offsetx, curCol + offsety)
                )

                if reducedLightLevel.r > 0 or reducedLightLevel.g > 0 or reducedLightLevel.b > 0 then
                    table.insert(queue, {newRow, newCol, reducedLightLevel, depth + 1})
                end
            end
        end
    end

    while #queue > 0 do
        local current = table.remove(queue, 1)
        local curRow, curCol, curLightLevel, depth = current[1], current[2], current[3], current[4]
        processCell(curRow, curCol, curLightLevel, depth + 1)
    end
end

function LightingSystem:createVisibilityClosure(level)
    return function(fov, x, y) return level:getCellVisibility(x, y) end
end

return LightingSystem
