--- The 'Level' holds all of the actors and systems, and runs the game loop.
-- @classmod Level

local Object = require "object"
local Actor = require "core.actor"
local ActorStorage = require "core.actorstorage"
local Scheduler = require "core.scheduler"
local Vector2 = require "math.vector"
local DenseMap = require "structures.densemap"

local Grid = require "structures.grid"
local Cell = require "core.cell"
local Wall = require "modules.core.cells.wall"

local Level = Object:extend()

--- Constructor for the Level class.
-- @tparam rotLove.Map map The rotLove map to use for the level.
-- @tparam function populater A function that takes a level and a map and populates the level with actors.
function Level:__new(map, populater)
   self.systems = {}

   self.actors = ActorStorage() -- holds all actors in the level

   -- Initialize our scheduler. This is used to keep track of time and
   -- actor turns.
   self.scheduler = Scheduler()

   -- we add a special tick to the scheduler that's used for durations and
   -- damage over time effects
   self.scheduler:add "tick"
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
-- @treturn string "descend" if the player has descended to the next level.
-- @treturn string "quit" if the player has quit the game.
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
               if condition.onDescend then condition:onDescend(self, actor) end
            end
         end

         return "descend"
      end

      local actor = self.scheduler:next()

      assert(
         actor == "tick" or actor:is(Actor),
         "Found a scheduler entry that wasn't an actor or tick."
      )

      if actor == "tick" then
         -- Tick is used by various Conditions and Systems to keep track of time
         -- and durations. A hunger System might use it to tick down a hunger
         -- meter. A poison condition might deal damage every tick.
         self.scheduler:addTime(actor, 100)

         for _, system in ipairs(self.systems) do
            system:onTick(self)
         end

         self:triggerActionEvents "onTicks"
      else
         for _, system in ipairs(self.systems) do
            system:onTurn(self, actor)
         end

         local _, action
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

--- Gets the actor's controller. This is a utility function that checks the
--- actor's conditions for an override controller and returns it if it exists.
--- Otherwise it returns the actor's normal controller.
-- @tparam Actor actor The actor to get the controller for.
-- @treturn Controller The actor's controller.
function Level:getActorController(actor)
   for _, condition in ipairs(actor:getConditions()) do
      if condition.overrideController then return condition:overrideController(self, actor) end
   end

   return actor:getComponent(components.Controller)
end

--
-- Systems
--

--- Attaches a system to the level. This function will error if the system
--- doesn't have a name or if a system with the same name already exists, or if
--- the system has a requirement that hasn't been attached yet.
-- @tparam System system The system to add.
function Level:addSystem(system)
   assert(system.name, "System must have a name.")
   assert(
      not self.systems[system.name],
      "System with name " .. system.name .. " already exists. System names must be unique."
   )

   -- Check our requirements and make sure we have all the systems we need
   if system.requirements and #system.requirements > 1 then
      for _, requirement in ipairs(system.requires) do
         assert(
            self.systems[requirement],
            "System "
               .. system.name
               .. " requires system "
               .. requirement
               .. " but it is not present."
         )
      end
   end

   -- Check the soft requirements of all previous systems and make sure we don't have any out
   -- of order systems
   for _, existingSystem in pairs(self.systems) do
      if existingSystem.softRequirements and #existingSystem.softRequirements > 0 then
         for _, softRequirement in ipairs(existingSystem.softRequirements) do
            if softRequirement == system.name then
               error(
                  "System "
                     .. system.name
                     .. " is out of order. It must be added before "
                     .. existingSystem.name
                     .. " because it is a soft requirement."
               )
            end
         end
      end
   end

   -- We've succeeded and we insert the system into our systems table
   system.owner = self
   table.insert(self.systems, system)
end

--- Gets a system by name.
-- @tparam string system_name The name of the system to get.
-- @treturn System The system with the given name.
function Level:getSystem(system_name)
   for _, system in ipairs(self.systems) do
      if system.name == system_name then return system end
   end
end

--
-- Actors
--

--- This function updates the component cache for the level. It should be called
--- whenever an actor's components change. It's called by the addActor and addComponent
--- functions.
-- @tparam Actor actor The actor to update the component cache for.
function Level:updateComponentCache(actor)
   for _, component in pairs(components) do
      if not self.componentCache[component] then self.componentCache[component] = {} end

      if actor:hasComponent(component) then
         self.componentCache[component][actor] = true
      else
         self.componentCache[component][actor] = nil
      end
   end
end

--- This function removes an actor from the component cache. It's called be the
--- removeActor function.
-- @tparam Actor actor The actor to remove from the component cache.
function Level:removeComponentCache(actor)
   for _, component in pairs(components) do
      if self.componentCache[component] then self.componentCache[component][actor] = nil end
   end
end

--- Adds an actor to the level. Handles updating the component cache and
--- inserting the actor into the sparse map. It will also add the actor to the
--- scheduler if it has a controller.
-- @tparam Actor actor The actor to add.
function Level:addActor(actor)
   -- some sanity checks
   assert(actor:is(Actor), "Attemped to add a non-actor object to the level with addActor")

   self:updateComponentCache(actor)

   actor:initialize(self)
   table.insert(self.actors, actor)

   self:insertSparseMapEntries(actor)

   if actor:hasComponent(components.Aicontroller) or actor:hasComponent(components.Controller) then
      self.scheduler:add(actor)
   end

   for _, system in ipairs(self.systems) do
      system:onActorAdded(self, actor)
   end

   self:getCell(actor.position.x, actor.position.y):onEnter(self, actor)
end

--- Removes an actor from the level. Handles updating the component cache and
--- removing the actor from the sparse map. It will also remove the actor from
--- the scheduler if it has a controller.
-- @tparam Actor actor The actor to remove.
function Level:removeActor(actor)
   self:removeComponentCache(actor)

   self:removeSparseMapEntries(actor)

   self.scheduler:remove(actor)

   for k, v in ipairs(self.actors) do
      if v == actor then table.remove(self.actors, k) end
   end

   for _, system in ipairs(self.systems) do
      system:onActorRemoved(self, actor)
   end

   for _, condition in ipairs(actor:getConditions()) do
      condition:onActorRemoved(self, actor)
   end
end

--- A utility function that removes a component from an actor. It handles
--- updating the component cache and the opacity cache. You can do this manually, but
--- it's easier to use this function.
-- @tparam Actor actor The actor to remove the component from.
-- @tparam Component component The component to remove.
function Level:removeComponent(actor, component)
   actor:__removeComponent(component)
   self:updateComponentCache(actor)

   if component:is(components.Opaque) then
      self:updateOpacityCache(actor.position.x, actor.position.y)
   end
end

--- A utility function that adds a component to an actor. It handles updating
--- the component cache and the opacity cache. You can do this manually, but
--- it's easier to use this function.
-- @tparam Actor actor The actor to add the component to.
-- @tparam Component component The component to add.
function Level:addComponent(actor, component)
   actor:__addComponent(component)
   self:updateComponentCache(actor)
   print(component.name)
   if component:is(components.Opaque) then
      self:updateOpacityCache(actor.position.x, actor.position.y)
   end
end

--- Returns true if the level contains the given actor, false otherwise.
-- @tparam Actor actor The actor to check for.
function Level:hasActor(actor)
   for _, candidate_actor in ipairs(self.actors) do
      if candidate_actor == actor then return true end
   end

   return false
end

--- Returns true if the level contains an actor with the given component, false otherwise.
-- @tparam Component component The component to check for.
function Level:hasActorWithComponent(component)
   for _, _ in self:eachActor(component) do
      return true
   end

   return false
end

--- Returns the first actor that extends the given prototype, or nil if no actor
--- is found.
-- @tparam Prototype prototype The prototype to check for.
function Level:getActorByType(type)
   for i = 1, #self.actors do
      if self.actors[i]:is(type) then return self.actors[i] end
   end
end

--- This method returns an iterator that will return all actors in the level
--- that have the given components. If no components are given it will return
--- all actors in the level.
-- @tparam Component ... The components to filter by.
-- @treturn function An iterator that returns the next actor that matches the given components.
function Level:eachActor(...)
   local n = 1
   local comp = { ... }

   if #comp == 1 and self.componentCache[comp[1]] then
      local currentComponentCache = self.componentCache[comp[1]]
      local key = next(currentComponentCache, nil)

      local function iterator()
         if not key then return end

         local ractor, rcomp = key, key:getComponent(comp[1])
         key = next(currentComponentCache, key)

         return ractor, rcomp
      end

      return iterator
   end

   return function()
      for i = n, #self.actors do
         n = i + 1

         if #comp == 0 then return self.actors[i] end

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

         if hasComponents then return self.actors[i], unpack(components) end
      end

      return nil
   end
end

local dummy = {}
--- Returns an iterator that will return all tiles that the given actor occupies.
-- @tparam Actor actor The actor to get the tiles for.
-- @treturn function An iterator that returns the next tile that the actor occupies.
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
      if i <= count then
         local ret = dummy[i]
         i = i + 1
         return ret
      end
   end
end

--- Returns a list of all actors at the given position.
-- @tparam number x The x component of the position to check.
-- @tparam number y The y component of the position to check.
-- @treturn table A list of all actors at the given position.
function Level:getActorsAt(x, y)
   local actorsAtPosition = {}
   for actor, _ in pairs(self.sparseMap:get(x, y)) do
      table.insert(actorsAtPosition, actor)
   end

   return actorsAtPosition
end

--- Returns an iterator that will return all actors at the given position.
-- @tparam number x The x component of the position to check.
-- @tparam number y The y component of the position to check.
-- @treturn function An iterator that returns the next actor at the given position.
function Level:eachActorAt(x, y)
   local key, _
   local actors = self.sparseMap:get(x, y)
   local function iterator()
      key, _ = next(actors, key)
      return key
   end
   return iterator
end

--- Moves an actor to the given position. This function doesn't do any checking
--- for overlaps or collisions. It's used by the moveActorChecked function.
-- @tparam Actor actor The actor to move.
-- @tparam Vector2 pos The position to move the actor to.
-- @tparam boolean skipSparseMap If true the sparse map won't be updated.
function Level:moveActor(actor, pos, skipSparseMap)
   assert(pos.is and pos:is(Vector2), "Expected a Vector2 for pos in Level:moveActor.")
   assert(
      math.floor(pos.x) == pos.x and math.floor(pos.y) == pos.y,
      "Expected integer values for pos in Level:moveActor."
   )

   for _, system in ipairs(self.systems) do
      system:beforeMove(self, actor, actor.position, pos)
   end

   -- if the actor isn't in the level, we don't do anything
   if not self:hasActor(actor) then return end

   if not skipSparseMap then self:removeSparseMapEntries(actor) end

   local previous_position = actor.position
   -- we copy the position here so that the caller doesn't have to worry about
   -- allocating a new table
   actor.position = pos:copy()

   if not skipSparseMap then self:insertSparseMapEntries(actor) end

   self:getCell(previous_position.x, previous_position.y):onLeave(self, actor)
   self:getCell(pos.x, pos.y):onEnter(self, actor)

   for _, system in ipairs(self.systems) do
      system:onMove(self, actor, previous_position, pos)
   end
end

--- This function does and handles moving multi-tile actors. Soon
--- I want to make this the default moveActor function and have
--- moveActorUnchecked be a special case.
-- @tparam Actor actor The actor to move.
-- @tparam Vector2 direction The direction to move the actor in.
function Level:moveActorChecked(actor, direction)
   local newPosition = actor.position + direction

   local accepted = {}
   local rejected = {}

   local collideable = actor:getComponent(components.Collideable)
   if collideable then
      for cell in collideable:moveCandidate(self, actor, direction) do
         local blockSelf = actor

         if collideable and collideable.blockSelf then blockSelf = nil end

         if not self:getCellPassable(cell.x, cell.y, blockSelf) then
            table.insert(rejected, cell)
         else
            table.insert(accepted, cell)
         end
      end
   else
      if not self:getCellPassableNoActors(newPosition.x, newPosition.y, actor) then return end
   end

   if #rejected > 0 then
      local trySqueeze, new_origin =
         collideable:trySqueeze(self, actor, direction, rejected, accepted)
      -- we didn't come up with a squeeze so we should abort
      if not trySqueeze then return end

      local squeeze_success = true
      for cell in trySqueeze do
         if not self:getCellPassable(cell.x, cell.y, actor) then squeeze_success = false end
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

   if collideable and #rejected == 0 then collideable:acceptedCandidate(self, actor, direction) end

   self:insertSparseMapEntries(actor)
end

--- This function removes the actor's entries from the sparse map and opacity cache.
-- @tparam Actor actor The actor to remove.
function Level:removeSparseMapEntries(actor)
   for vec in self:eachActorTile(actor) do
      self.sparseMap:remove(vec.x, vec.y, actor)
      if actor:getComponent(components.Opaque) then self:updateOpacityCache(vec.x, vec.y) end
   end
end

--- This function inserts the actor's entries into the sparse map and opacity cache.
-- @tparam Actor actor The actor to insert.
function Level:insertSparseMapEntries(actor)
   for vec in self:eachActorTile(actor) do
      self.sparseMap:insert(vec.x, vec.y, actor)
      if actor:getComponent(components.Opaque) then self:updateOpacityCache(vec.x, vec.y) end
   end
end

--- Executes an Action, updating the level's state and triggering any events on 'Conditions' or 'Systems'
--- attached to the 'Actor' or 'Level' respectively. It also updates the 'Scheduler' if the action isn't
--- a reaction or free action. Lastly, it calls the 'onAction' method on the 'Cell' that the 'Actor' is
--- standing on.
-- @tparam Action action The action to perform.
-- @tparam boolean free If true the action is a free action and won't update the scheduler.
function Level:performAction(action, free)
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

   self:getCell(action.owner.position.x, action.owner.position.y):onAction(self, action.owner) -- Dim: placement tbd
end

--- This function triggers events on 'Conditions' and 'Systems' attached to the 'Actor' or 'Level' respectively.
-- @tparam string onType The type of event to trigger.
-- @tparam Action ?action The action to trigger the event with.
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

--- Returns a list of all actors that are within the given range of the given
--- position. The type parameter determines the type of range to use. Currently
--- only "fov" and "box" are supported. The fov type uses a field of view
--- algorithm to determine what actors are visible from the given position. The
--- box type uses a simple box around the given position.
-- @tparam string type The type of range to use.
-- @tparam Vector2 position The position to check from.
-- @tparam number range The range to check.
function Level:getAOE(type, position, range)
   assert(position:is(Vector2))
   local seenActors = {}

   if type == "fov" then
      local fov = {}
      local fovCalculator = ROT.FOV.Recursive(self:createVisibilityClosure())
      fovCalculator:compute(position.x, position.y, range, self:getAOEFOVCallback(fov))
      for k, other in ipairs(self.actors) do
         local x, y = other.position.x, other.position.y
         if fov[x] and fov[x][y] then table.insert(seenActors, other) end
      end

      return fov, seenActors
   elseif type == "box" then
      for k, other in ipairs(self.actors) do
         if other:getRangeVec("box", position) <= range then table.insert(seenActors, other) end
      end

      return nil, seenActors
   end
end

--- Sets the cell at the given position to the given cell.
-- @tparam number x The x component of the position to set.
-- @tparam number y The y component of the position to set.
-- @tparam Cell cell The cell to set.
function Level:setCell(x, y, cell)
   self.cellOpacityCache:set(x, y, cell.opaque and 1 or 0)
   self.map:set(x, y, cell)
end

--- Gets the cell at the given position.
-- @tparam number x The x component of the position to get.
-- @tparam number y The y component of the position to get.
-- @treturn Cell The cell at the given position.
function Level:getCell(x, y) return self.map:get(x, y) end

--- Returns true if the cell at the given position is passable, false otherwise. Considers
--- actors in the sparse map as well as the cell's passable property.
-- @tparam number x The x component of the position to check.
-- @tparam number y The y component of the position to check.
-- @tparam Actor ?actor The actor to ignore when checking the sparse map.
function Level:getCellPassable(x, y, actor)
   if self:getCell(x, y) and not self:getCell(x, y).passable then
      return false
   else
      for other, _ in pairs(self.sparseMap:get(x, y)) do
         if actor ~= other and other:hasComponent(components.Collideable) then return false end
      end

      return true
   end
end

--- Returns true if the cell at the given position is passable, false otherwise.
--- Considers only the cell's passable property.
-- @tparam number x The x component of the position to check.
-- @tparam number y The y component of the position to check.
-- @treturn boolean True if the cell is passable, false otherwise.
function Level:getCellPassableNoActors(x, y) return self:getCell(x, y).passable end

--- Returns true if the cell at the given position is opaque, false otherwise.
-- @tparam number x The x component of the position to check.
-- @tparam number y The y component of the position to check.
-- @treturn boolean True if the cell is opaque, false otherwise.
function Level:getCellOpaque(x, y) return self.opacityCache:get(x, y) end

--- Returns the opacity cache for the level. This generally shouldn't be used
--- outside of systems that need to know about opacity.
-- @treturn DenseMap The opacity cache for the level.
function Level:getOpacityCache() return self.opacityCache end

--- Initialize the opacity cache. This should be called after the level is
--- created and before the game loop starts. It will initialize the opacity
--- cache with the cell opacity cache. This is handled automatically by the
--- Level class.
function Level:initializeOpacityCache()
   for x = 1, self.width do
      for y = 1, self.height do
         self.opacityCache:set(x, y, self.cellOpacityCache:get(x, y))
      end
   end
end

--- Updates the opacity cache at the given position. This should be called
--- whenever an actor moves or a cell's opacity changes. This is handled
--- automatically by the Level class.
-- @tparam number x The x component of the position to update.
-- @tparam number y The y component of the position to update.
function Level:updateOpacityCache(x, y)
   local opaque = false
   for actor, _ in pairs(self.sparseMap:get(x, y)) do
      opaque = opaque or actor:hasComponent(components.Opaque)
      if opaque then break end
   end

   opaque = opaque or self.cellOpacityCache:get(x, y)
   self.opacityCache:set(x, y, opaque)

   for _, system in ipairs(self.systems) do
      system:afterOpacityChanged(self, x, y)
   end
end

-- TODO: Replace with global system.
--- Quits the game. This is a utility function that should be called by
--- systems that need to quit the game.
function Level:quit() self.shouldQuit = true end

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
   return function(fov, x, y) return not self:getCellOpaque(x, y) end
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
      if self:getCellPassable(x, y) then return x, y end
   end
end

--- Yields to the main thread. This is called in run, and a few systems. Any time you want
--- the interface to update you should call this. Avoid calling coroutine.yield directly,
--- as this function will call the onYield method on all systems.
-- @param ... Any arguments to pass to the main thread. This will be replaced with the message class in the future.
function Level:yield(...)
   for _, system in ipairs(self.systems) do
      system:onYield(self, ...)
   end

   coroutine.yield(...)
end

return Level
