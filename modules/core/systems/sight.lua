local System = require "core.system"
local Vector2 = require "math.vector"
local Actor = require "core.actor"

--- The Sight System manages the sight of actors. It is responsible for updating the FOV of actors, and
--- keeping track of which actors are visible to each other.
local SightSystem = System:extend()
SightSystem.name = "Sight"

-- We want to run the sight system after the lighting system so that we can use the lighting system's
-- data to determine fov with darkvision. The sight system will still run if the lighting system is not
-- available.
SightSystem.softRequirements = {
    "Lighting"
}

--- Before an actor takes an action their visibility is tracked in the cache. After the action is taken
--- the visibility is compared to the cache to see if the actor's visibility has changed. After checking
--- the visibility the cache is cleared for that actor.
SightSystem.__visibilityCheck = nil

function SightSystem:onTurn(level, actor)
    if actor:hasComponent(components.Sight) then
        self:updateFOV(level, actor)
    end
end

function SightSystem:onYield(level)
    for actor in level:eachActor(components.Controller) do
        self:updateFOV(level, actor)
    end
end

function SightSystem:onActorAdded(level, actor)    
    self:updateFOV(level, actor)
end

function SightSystem:onDescend(level)
    for _, sight_component in level:eachActor(components.Sight) do
        if sight_component.explored then
            sight_component.explored = {}
        end
    end
end

-- These functions update the fov and visibility of actors on the level.
function SightSystem:updateFOV(level, actor)    
    -- check if actor has a sight component and if not return
    local sight_component = actor:getComponent(components.Sight)
    if not sight_component then 
        return 
    end

    local fovCalculator = ROT.FOV.Recursive(self:createVisibilityClosure(level))

    -- clear the actor visibility cache
    sight_component.seenActors = {}
  
    local sightLimit = sight_component.sight
    local darkvision = 0
    
    -- we have to check the actor's conditions to see if they modify their darkvision
    for _, condition in ipairs(actor:getConditions()) do
        if condition.modifyDarkvision then
          darkvision = condition:modifyDarkvision(self, actor, darkvision)
        end
    end

    -- we check if the sight component has a fov and if so we clear it
    if sight_component.fov then
        sight_component.raw_fov = {}
        sight_component.fov = {}

        local sightLimit = sight_component.range
        -- we check if the cell has a sight limit and if so we set the sight limit to the lowest sight limit
        -- between the actor and the cell
        if level:getCell(actor.position.x, actor.position.y).sightLimit then
            sightLimit = math.min(sightLimit, level:getCell(actor.position.x, actor.position.y).sightLimit)
        end
    
        fovCalculator:compute(actor.position.x, actor.position.y, sightLimit, self:createFOVClosure(level, sight_component))
    else
        -- we have a sight component but no fov which essentially means the actor has blind sight and can see
        -- all cells within a certain radius only generally only simple actors have this vision type
        for x = actor.position.x - sightLimit, actor.position.x + sightLimit do
            for y = actor.position.y - sightLimit, actor.position.y + sightLimit do
                if not sight_component.raw_fov[x] then sight_component.raw_fov[x] = {} end
                sight_component.raw_fov[x][y] = level:getCell(x, y)
            end
        end
    end
  
    self:updateLighting(level, actor)
    self:updateExplored(actor)
    self:updateSeenActors(level, actor)
    self:updateScryActors(level, actor)
end

function SightSystem:updateSeenActors(level, actor)
    -- if we don't have a sight component we return
    local sight_component = actor:getComponent(components.Sight)
    if not sight_component then return end

    -- clear the actor visibility cache
    sight_component.seenActors = {}

    for x, _ in pairs(sight_component.fov) do
        for y, _ in pairs(sight_component.fov[x]) do
            -- we loop through all the actors on the level and check if they are visible to the actor
            for other in level:eachActorAt(x, y) do
                -- Check visibility for each tile of the actor
                local isVisible = false
                local other_cell = level:getCell(other.position.x, other.position.y)
                local actor_cell = level:getCell(actor.position.x, actor.position.y)
                if  (other:isVisible() or actor == other) and
                    actor_cell:visibleFromCell(level, other_cell) and
                    other_cell:visibleFromCell(level, actor_cell)
                then
                    isVisible = true
                end

                if isVisible then
                    table.insert(sight_component.seenActors, other)
                end
            end
        end
      end

    self:updateRememberedActors(level, actor)
end

-- this is called by the lighting system when the lighting changes it removes
-- any cells that are in darkness from the fov unless they are within 1 cell
-- of the actor
function SightSystem:updateLighting(level, actor)
    local sight_component = actor:getComponent(components.Sight)

    -- if the level has the lighting system we check if the actor has a darkvision value and if so we update the fov
    -- to remove any cells that are in darkness
    local light_system = level:getSystem("Lighting")
    if light_system and sight_component.darkvision ~= 0 then 
        for x, _ in pairs(sight_component.raw_fov) do
            for y, _ in pairs(sight_component.raw_fov[x]) do
                local fov = sight_component.raw_fov
                local lightval = light_system:getLightingAt(x, y, fov):average_brightness()
                local darkvision = sight_component.darkvision
                if lightval > darkvision or actor:getRangeVec("box", Vector2(x, y)) == 1 then
                    if not sight_component.fov[x] then sight_component.fov[x] = {} end
                    sight_component.fov[x][y] = sight_component.raw_fov[x][y]
                end
            end
        end
    else
        for x, _ in pairs(sight_component.raw_fov) do
            for y, _ in pairs(sight_component.raw_fov[x]) do
                if not sight_component.fov[x] then sight_component.fov[x] = {} end
                sight_component.fov[x][y] = sight_component.raw_fov[x][y]
            end
        end
    end
end

function SightSystem:updateRememberedActors(level, actor)
    local sight_component = actor:getComponent(components.Sight)
    if not sight_component then return end

    for x, _ in pairs(sight_component.fov) do
        for y, _ in pairs(sight_component.fov[x]) do
            sight_component.rememberedActors:removeCell(x, y)
        end
    end

    for _, actor in ipairs(sight_component.seenActors) do
        if actor.remembered then
            sight_component.rememberedActors:setCell(actor.position.x, actor.position.y, actor)
        end
    end
end

function SightSystem:updateExplored(actor)
    local sight_component = actor:getComponent(components.Sight)

    for x, _ in pairs(sight_component.fov) do
        for y, tile in pairs(sight_component.fov[x]) do
            if sight_component.explored then
                sight_component:setCellExplored(x, y, tile)
            end
        end
    end
end


function SightSystem:updateScryActors(level, actor)
    local sight_component = actor:getComponent(components.Sight)
    sight_component.scryActors = {}
  
    -- we'll use this temporary table to remove duplicates
    local scryed = {}
  
    local dummy = {}
    for i, condition in ipairs(actor:getConditions()) do
      local e = condition:getActionEvents("onScrys", self) or dummy
      for i, event in ipairs(e) do
        local scryedActors = event:fire(condition, level, actor)
  
        for _, scryedActor in ipairs(scryedActors) do
          scryed[scryedActor] = true
        end
      end
    end
  
    for scryActor, _ in pairs(scryed) do
        table.insert(sight_component.scryActors, scryActor)
    end
end
  
-- Little factories for some callback functions we need to pass to the FOV calculator
function SightSystem:createVisibilityClosure(level)
    return function(fov, x, y)
        return level:getCellVisibility(x, y)
    end
end

function SightSystem:createFOVClosure(level, sight_component)
    return function(x, y, z)
        if not sight_component.raw_fov[x] then sight_component.raw_fov[x] = {} end
        sight_component.raw_fov[x][y] = level:getCell(x, y)
    end
end

return SightSystem