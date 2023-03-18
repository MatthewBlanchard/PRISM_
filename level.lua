local Object = require "object"
local Actor = require "actor"
local System = require "system"
local Scheduler = require "scheduler"
local populateMap = require "populater"
local SparseMap = require "sparsemap"
local Vector2 = require "vector"

local Cell = require "cell"
local Wall = require "cells/wall"

local Level = Object:extend()

function Level:__new(map)
  self.systems = {}

  self.actors = {}
  self.sparseMap = SparseMap() -- holds a sparse map of actors in the scene by position

  -- Initialize our scheduler. This is used to keep track of time and
  -- actor turns.
  self.scheduler = Scheduler()

  -- we add a special tick to the scheduler that's used for durations and
  -- damage over time effects
  self.scheduler:add("tick")
  self.exit = false

  -- let's create our map and fill it with the info from the supplied
  -- rotLove map
  self.map = {}
  self.width = map._width
  self.height = map._height
  self.__map = map
end

--- Update is the main game loop for a level. It's a coroutine that yields
--- back to the main thread when it needs to wait for input from the player.
--- This function is the heart of the game loop.
function Level:run()
  -- we need to initialize all of our systems
  for _, system in pairs(self.systems) do
    system:initialize(self)
  end

  self.__map:create(self:getMapCallback())
  populateMap(self, self.__map)

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


function Level:addActor(actor)
  -- some sanity checks
  assert(actor:is(Actor), "Attemped to add a non-actor object to the level with addActor")

  actor:initialize(self)
  table.insert(self.actors, actor)
  
  for vec in self:eachActorTile(actor) do
    self.sparseMap:insert(vec.x, vec.y, actor)
  end

  if actor:hasComponent(components.Aicontroller) or
      actor:hasComponent(components.Controller)
  then
    self.scheduler:add(actor)
  end

  for _, system in ipairs(self.systems) do
    system:onActorAdded(self, actor)
  end

  self.map[actor.position.x][actor.position.y]:onEnter(self, actor)
end

function Level:removeActor(actor)
  for vec in self:eachActorTile(actor) do
    self.sparseMap:remove(vec.x, vec.y, actor)
  end

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

function Level:eachActorTile(actor, callback)
  local list = {}

  local collideable_component = actor:getComponent(components.Collideable)
  if collideable_component then
    for vec in collideable_component.boundingBox:eachCell(actor.position) do
      table.insert(list, vec)
    end
  else
    table.insert(list, actor.position)
  end

  return function()
    while #list > 0 do
      return table.remove(list)
    end
  end
end

function Level:getActorsAtPosition(x, y)
  local actorsAtPosition = {}
  for i = 1, #self.actors do
    local actorPosition = self.actors[i].position

    if actorPosition.x == x and actorPosition.y == y then
      table.insert(actorsAtPosition, self.actors[i])
    end
  end

  return actorsAtPosition
end

function Level:moveActor(actor, pos)
  assert(pos.is and pos:is(Vector2), "Expected a Vector2 for pos in Level:moveActor.")

  for vec in self:eachActorTile(actor) do
    self.sparseMap:remove(vec.x, vec.y, actor)
  end
  
  local oldpos = actor.position
  -- we copy the position here so that the caller doesn't have to worry about
  -- allocating a new table
  actor.position = pos:copy()

  local suppressOnLeave = false
  for _, system in ipairs(self.systems)  do
    suppressOnLeave = suppressOnLeave or system:beforeMove(self, actor, oldpos, pos)
  end

  for vec in self:eachActorTile(actor) do
    self.sparseMap:insert(vec.x, vec.y, actor)
  end

  self.map[oldpos.x][oldpos.y]:onLeave(self, actor)
  self.map[pos.x][pos.y]:onEnter(self, actor)
  
  for _, system in ipairs(self.systems) do
    system:onMove(self, actor, oldpos, pos)
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
      if other:getRange("box", position) <= range then
        table.insert(seenActors, other)
      end
    end

    return nil, seenActors
  end
end



function Level:setCell(x, y, cell)
  self.map[x][y] = cell
end

function Level:getCell(x, y)
  if self.map[x] then
    return self.map[x][y]
  end

  return nil
end

function Level:getCellPassable(x, y, actor)
  if not self:getCell(x, y).passable then
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

function Level:getCellPass(x, y)
  return self:getCell(x, y).passable
end

function Level:getCellVisibility(x, y)
  if not self:getCell(x, y) or  self:getCell(x, y).opaque then
    return false
  else
    for actor, _ in pairs(self.sparseMap:get(x, y)) do
      if actor.blocksVision == true then
        return false
      end
    end

    return true
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
    if not self.map[x] then self.map[x] = {} end
    
    if val == 0 then
      self.map[x][y] = Cell()
    else
      self.map[x][y] = Wall()
    end
  end
end

function Level:createVisibilityClosure()
  return function(fov, x, y)
      return self:getCellVisibility(x, y)
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

return Level
