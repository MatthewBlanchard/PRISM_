local Object = require "object"
local Actor = require "core.actor"
local System = require "core.system"
local Scheduler = require "core.scheduler"
local SparseMap = require "structures.sparsemap"
local Vector2 = require "math.vector"
local DenseMap = require "structures.densemap"

local Grid = require "structures.grid"
local Cell = require "core.cell"
local Wall = require "modules.core.cells.wall"

local Level = Object:extend()

function Level:__new(map, populater)
  self.systems = {}

  self.actors = {}
  self.sparseMap = SparseMap() -- holds a sparse map of actors in the scene by position
  self.componentCache = {} -- holds submaps of actors by component type

  -- Initialize our scheduler. This is used to keep track of time and
  -- actor turns.
  self.scheduler = Scheduler()

  -- we add a special tick to the scheduler that's used for durations and
  -- damage over time effects
  self.scheduler:add("tick")
  self.exit = false

  -- let's create our map and fill it with the info from the supplied
  -- rotLove map
  self.map = Grid(map._width + 1, map._height + 1, Wall())
  self.width = map._width + 1
  self.height = map._height + 1
  self.__map = map
  self.populater = populater

  self.cellOpacityCache = DenseMap(map._width + 1, map._height + 1) -- holds a cache of cell's opacity
  self.opacityCache = DenseMap(map._width + 1, map._height + 1) -- holds a cache of actor's opacity
end

--- Update is the main game loop for a level. It's a coroutine that yields
--- back to the main thread when it needs to wait for input from the player.
--- This function is the heart of the game loop.
function Level:run()
  self.__map = self.__map:create(self:getMapCallback())

  self:initializeOpacityCache()

  -- we need to initialize all of our systems
  for _, system in pairs(self.systems) do
    system:initialize(self)
  end

  self.populater(self, self.__map)

  for _, system in ipairs(self.systems) do
    system:postInitialize(self)
  end

  -- no brakes baby
  while true do
    -- check if we should quit before we move onto the next actor
    if self.shouldQuit then return end

    -- ok I lied there are brakes. We return "descend" back to the main 'thread'.
    -- That signals that we're done and that it should scrap this 'thread' and
    -- spin up a new level.
    if self.exit == true then
      for _, system in ipairs(self.systems) do
        system:onDescend(self)
      end

      -- we need to loop through our actors and call any onDescend methods in their conditions
      for _, actor in ipairs(self.actors) do
        for _, condition in ipairs(actor:getConditions()) do
          if condition.onDescend then
            condition:onDescend(self, actor)
          end
        end
      end
      
      return "descend"
    end

    local actor = self.scheduler:next()

    assert(actor == "tick" or actor:is(Actor), "Found a scheduler entry that wasn't an actor or tick.")

    if actor == "tick" then
      -- Tick is used by various Conditions and Systems to keep track of time
      -- and durations. A hunger System might use it to tick down a hunger
      -- meter. A poison condition might deal damage every tick.
      self.scheduler:addTime(actor, 100)

      for _, system in ipairs(self.systems) do
        system:onTick(self)
      end
      
      self:triggerActionEvents("onTicks")
    else
      for _, system in ipairs(self.systems) do
        system:onTurn(self, actor)
      end

      local action
      local controller = self:getActorController(actor)
      if controller then
        -- if we find a player controlled actor we set self.waitingFor and yield it to main
        -- this hands things off to the interface which generates a command for the actor
        _, action = coroutine.yield(actor)
      else

        -- if we don't have a player controlled actor we ask the actor for it's
        -- next action through it's controller
        -- TODO: don't provide act with level
        action = actor:act(self)
      end

      -- we make sure we got an action back from the controller for sanity's sake
      assert(action, "Actor " .. actor.name .. " returned nil from act()")

      self:performAction(action)
    end
  end
end

function Level:getActorController(actor)
  for _, condition in ipairs(actor:getConditions()) do
    if condition.overrideController then
      return condition:overrideController(self, actor)
    end
  end

  return actor:getComponent(components.Controller)
end

--
-- Systems
--


function Level:addSystem(system)
  assert(system.name, "System must have a name.")
  assert(not self.systems[system.name], "System with name " .. system.name .. " already exists. System names must be unique.")

  -- Check our requirements and make sure we have all the systems we need
  if system.requirements and #system.requirements > 1 then
    for _, requirement in ipairs(system.requires) do
      assert(self.systems[requirement], "System " .. system.name .. " requires system " .. requirement .. " but it is not present.")
    end
  end

  -- Check the soft requirements of all previous systems and make sure we don't have any out
  -- of order systems
  for _, existingSystem in pairs(self.systems) do
    if existingSystem.softRequirements and #existingSystem.softRequirements > 0 then
      for _, softRequirement in ipairs(existingSystem.softRequirements) do
        if softRequirement == system.name then
          error("System " .. system.name .. " is out of order. It must be added before " .. existingSystem.name .. " because it is a soft requirement.")
        end
      end
    end
  end

  -- We've succeeded and we insert the system into our systems table
  system.owner = self
  table.insert(self.systems, system)
end

function Level:getSystem(system_name)
  for _, system in ipairs(self.systems) do
    if system.name == system_name then
      return system
    end
  end
end

--
-- Actors
--

function Level:updateComponentCache(actor)
  for _, component in pairs(components) do
    if not self.componentCache[component] then
      self.componentCache[component] = {}
    end

    if actor:hasComponent(component) then
      self.componentCache[component][actor] = true
    else
      self.componentCache[component][actor] = nil
    end
  end
end

function Level:addActor(actor)
  -- some sanity checks
  assert(actor:is(Actor), "Attemped to add a non-actor object to the level with addActor")

  self:updateComponentCache(actor)

  actor:initialize(self)
  table.insert(self.actors, actor)
  
  self:insertSparseMapEntries(actor)

  if actor:hasComponent(components.Aicontroller) or
      actor:hasComponent(components.Controller)
  then
    self.scheduler:add(actor)
  end

  for _, system in ipairs(self.systems) do
    system:onActorAdded(self, actor)
  end

  self:getCell(actor.position.x, actor.position.y):onEnter(self, actor)
end

function Level:removeActor(actor)
  self:updateComponentCache(actor)

  self:removeSparseMapEntries(actor)

  self.scheduler:remove(actor)

  for k, v in ipairs(self.actors) do
    if v == actor then
      table.remove(self.actors, k)
    end
  end

  for _, system in ipairs(self.systems) do
    system:onActorRemoved(self, actor)
  end

  for _, condition in ipairs(actor:getConditions()) do
    condition:onActorRemoved(self, actor)
  end
end

function Level:removeComponent(actor, component)
  actor:__removeComponent(component)
  self:updateComponentCache(actor)
end

function Level:addComponent(actor, component)
  actor:__addComponent(component)
  self:updateComponentCache(actor)
end

--- A utility function that returns true if the level contains the given
--- actor.
function Level:hasActor(actor)
  for _, candidate_actor in ipairs(self.actors) do
    if candidate_actor == actor then
      return true
    end
  end

  return false
end

--- A utility function that returns the first actor of a given type
--- that it finds. This is useful for finding the player or the stairs
--- in a level.
function Level:getActorByType(type)
  for i = 1, #self.actors do
    if self.actors[i]:is(type) then
      return self.actors[i]
    end
  end
end

--- This method returns an iterator that will return all actors in the level
--- that have the given components. If no components are given it will return
--- all actors in the level.
function Level:eachActor(...)
  local n = 1
  local comp = { ... }
  
  if #comp == 1 and self.componentCache[comp[1]] then
    local currentComponentCache = self.componentCache[comp[1]]
    local key = next(currentComponentCache, key)

    local function iterator()
      while key do
        local ractor, rcomp = key, key:getComponent(comp[1])
        key = next(currentComponentCache, key)
        
        return ractor, rcomp
      end
    end

    return iterator
  end

  return function()
    for i = n, #self.actors do
      n = i + 1

      if #comp == 0 then
        return self.actors[i]
      end

      local components = {}
      local hasComponents = false
      for j = 1, #comp do
        if self.actors[i]:hasComponent(comp[j]) then
          hasComponents = true
          table.insert(components, self.actors[i]:getComponent(comp[j]))
        else
          hasComponents = false
          break
        end
      end

      if hasComponents then
        return self.actors[i], unpack(components)
      end
    end

    return nil
  end
end

local dummy = {}
function Level:eachActorTile(actor)
  local count = 0

  local collideable_component = actor:getComponent(components.Collideable)
  if collideable_component then
    for vec in collideable_component:eachCellGlobal(actor) do
      count = count + 1
      dummy[count] = vec
    end
  else
    count = 1
    dummy[1] = actor.position
  end

  local i = 1
  return function()
    while i <= count do
      local ret = dummy[i]
      i = i + 1
      return ret
    end
  end
end

function Level:getActorsAt(x, y)
  local actorsAtPosition = {}
  for actor, _ in pairs(self.sparseMap:get(x, y)) do
    table.insert(actorsAtPosition, actor)
  end

  return actorsAtPosition
end

function Level:eachActorAt(x, y)
  local key
  local actors = self.sparseMap:get(x, y)
  local function iterator()
    key, _ = next(actors, key)
    if key then
      return key
    end
  end
  return iterator
end

function Level:moveActor(actor, pos, skipSparseMap)
  assert(pos.is and pos:is(Vector2), "Expected a Vector2 for pos in Level:moveActor.")

  local oldpos = actor.position
  -- we copy the position here so that the caller doesn't have to worry about
  -- allocating a new table
  actor.position = pos:copy()

  for _, system in ipairs(self.systems)  do
    system:beforeMove(self, actor, oldpos, pos)
  end

  -- if the actor isn't in the level, we don't do anything
  if not self:hasActor(actor) then
    return
  end

  if not skipSparseMap then
    self:removeSparseMapEntries(actor)
  end

  if not skipSparseMap then
    self:insertSparseMapEntries(actor)
  end

  self:getCell(oldpos.x, oldpos.y):onLeave(self, actor)
  self:getCell(pos.x, pos.y):onEnter(self, actor)
  
  for _, system in ipairs(self.systems) do
    system:onMove(self, actor, oldpos, pos)
  end
end

-- moveActor doesn't do any checking for overlaps or collisions
-- this function does and handles moving multi-tile actors. Soon
-- I want to make this the default moveActor function and have
-- moveActorUnchecked be a special case.
function Level:moveActorChecked(actor, direction)
  local newPosition = actor.position + direction

  local accepted = {}
  local rejected = {}

  local collideable = actor:getComponent(components.Collideable)
  if collideable then 
    for cell in collideable:moveCandidate(self, actor, direction) do
      local blockSelf = actor
      
      if collideable and collideable.blockSelf then
        blockSelf = nil
      end

      if not self:getCellPassable(cell.x, cell.y, blockSelf) then
        table.insert(rejected, cell)
      else 
        table.insert(accepted, cell)
      end
    end
  else
    if not self:getCellPassableNoActors(newPosition.x, newPosition.y, actor) then
      return
    end
  end

  if #rejected > 0 then
    local trySqueeze, new_origin = collideable:trySqueeze(self, actor, direction, rejected, accepted)
    -- we didn't come up with a squeeze so we should abort
    if not trySqueeze then
      return
    end

    local squeeze_success = true
    for cell in trySqueeze do
      if not self:getCellPassable(cell.x, cell.y, actor) then
        squeeze_success = false
      else
      end
    end

    if squeeze_success then
      self:removeSparseMapEntries(actor)

      collideable:acceptedSqueeze(self, actor, direction, rejected, accepted)
      
      self:moveActor(actor, new_origin, true)

      self:insertSparseMapEntries(actor)
    end

    return
  end

  self:removeSparseMapEntries(actor)
  -- we use the unchecked move actor here but pass in true to skip the
  -- sparse map update. We do this because we're going to update the
  -- sparse map ourselves.
  self:moveActor(actor, newPosition, true)

  if collideable and #rejected == 0 then
    collideable:acceptedCandidate(self, actor, direction)
  end

  self:insertSparseMapEntries(actor)
end

function Level:removeSparseMapEntries(actor)
  for vec in self:eachActorTile(actor) do
    self.sparseMap:remove(vec.x, vec.y, actor)

    local opaque = false
    for actor, _ in pairs(self.sparseMap:get(vec.x, vec.y)) do
      opaque = opaque or actor.opaque
      if actor.opaque then
        break
      end
    end

    opaque = opaque or self.cellOpacityCache:get(vec.x, vec.y)
    self.opacityCache:set(vec.x, vec.y, opaque)
  end
end

function Level:insertSparseMapEntries(actor)
  for vec in self:eachActorTile(actor) do
    self.sparseMap:insert(vec.x, vec.y, actor)

    local opaque = false
    for actor, _ in pairs(self.sparseMap:get(vec.x, vec.y)) do
      opaque = opaque or actor.opaque
      if actor.opaque then
        break
      end
    end

    opaque = opaque or self.cellOpacityCache:get(vec.x, vec.y)
    self.opacityCache:set(vec.x, vec.y, opaque)
  end
end

function Level:performAction(action, free, animationToPlay)
  -- this happens sometimes if one effect kills an entity and a second effect
  -- tries to damage it for instance.
  if not self:hasActor(action.owner) then return end

  -- we call the beforeAction method on all systems
  for _, system in ipairs(self.systems) do
    system:beforeAction(self, action.owner, action)
  end

  self:triggerActionEvents("onActions", action)

  action:perform(self)

  -- we call the afterAction method on all systems
  for _, system in ipairs(self.systems) do
    system:afterAction(self, action.owner, action)
  end

  self:triggerActionEvents("afterActions", action)
  self:triggerActionEvents("setTimes", action)


  -- if this isn't a reaction or free action and the level contains the acting actor
  -- we update it's place in the scheduler
  if not action.reaction and not free and self:hasActor(action.owner) then
    self.scheduler:addTime(action.owner, action.time)
  end
end

local dummy = {} -- just to avoid making garbage
function Level:triggerActionEvents(onType, action)
  if onType == "onTicks" then
    for _, actor in ipairs(self.actors) do
      for _, condition in ipairs(actor:getConditions()) do
        local e = condition:getActionEvents(onType, self) or dummy
        for _, event in ipairs(e) do
          event:fire(condition, self, actor)
        end
      end
    end

    return
  end

  if not action then return nil end

  for k, condition in ipairs(action.owner:getConditions()) do
    local e = condition:getActionEvents(onType, self, action)
    if e then
      for k, event in ipairs(e) do
        event:fire(condition, self, action.owner, action)
      end
    end
  end

  if not action:getTargets() then return end

  for k, actor in ipairs(action:getTargets()) do
    if actor.getConditions then
      for k, condition in ipairs(actor:getConditions()) do
        local e = condition:getActionEvents(onType, self, action)
        if e then
          for k, event in ipairs(e) do
            event:fire(condition, self, actor, action)
          end
        end
      end
    end
  end
end

function Level:getAOE(type, position, range)
  assert(position:is(Vector2) )
  local seenActors = {}

  if type == "fov" then
    local fov = {}
    local fovCalculator = ROT.FOV.Recursive(self:createVisibilityClosure())
    fovCalculator:compute(position.x, position.y, range, self:getAOEFOVCallback(fov))
    for k, other in ipairs(self.actors) do
      if fov[other.position.x] and
          fov[other.position.x][other.position.y]
      then
        table.insert(seenActors, other)
      end
    end

    return fov, seenActors
  elseif type == "box" then
    for k, other in ipairs(self.actors) do
      if other:getRangeVec("box", position) <= range then
        table.insert(seenActors, other)
      end
    end

    return nil, seenActors
  end
end



function Level:setCell(x, y, cell)
  self.cellOpacityCache:set(x, y, cell.opaque and 1 or 0)
  self.map:set(x, y, cell)
end

function Level:getCell(x, y)
  return self.map:get(x, y)
end

function Level:getCellPassable(x, y, actor)
  if self:getCell(x, y) and not self:getCell(x, y).passable then
    return false
  else
    for other, _ in pairs(self.sparseMap:get(x, y)) do
      if actor ~= other and other:hasComponent(components.Collideable) then
        return false
      end
    end

    return true
  end
end

function Level:getCellPassableNoActors(x, y)
  return self:getCell(x, y).passable
end

function Level:getCellOpaque(x, y)
  return self.opacityCache:get(x, y)
end

function Level:getOpacityCache()
  return self.opacityCache
end

function Level:initializeOpacityCache()
  for x = 1, self.width do
    for y = 1, self.height do
      self.opacityCache:set(x, y, self.cellOpacityCache:get(x, y))
    end
  end
end

-- TODO: Replace with global system.
function Level:quit()
  self.shouldQuit = true
end

-- Some simple callback generation stuff.

-- TODO: There should be a Map object that handles this. ROT provides one,
-- but I'd rather get off their generation and spit out maps that can just
-- be used directly.
function Level:getMapCallback()
  return function(x, y, val)    
    if val == 0 then
      self:setCell(x, y, Cell())
    else
      self:setCell(x, y, Wall())
    end
  end
end

function Level:createVisibilityClosure()
  return function(fov, x, y)
      return not self:getCellOpaque(x, y)
  end
end

function Level:getAOEFOVCallback(aoeFOV)
  return function(x, y, z)
      if not self:getCell(x, y).passable then return end

      if not aoeFOV[x] then aoeFOV[x] = {} end
      aoeFOV[x][y] = self:getCell(x, y)
  end
end

function Level:getRandomWalkableTile()
  while true do
    local x, y = ROT.RNG:random(1, self.width), ROT.RNG:random(1, self.height)
    if self:getCellPassable(x, y) then
      return x, y
    end
  end
end

function Level:yield(...)
  for _, system in ipairs(self.systems) do
    system:onYield(self, ...)
  end

  coroutine.yield(...)
end

return Level
