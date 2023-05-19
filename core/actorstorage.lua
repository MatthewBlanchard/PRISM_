--- The 'ActorStorage' is a container for 'Actors' that maintains a list, spatial map, and component cache.
-- It is used by the 'Level' class to store and retrieve actors, and is returned by a few Level methods.
-- You should rarely, if ever, need to use this class directly. It is returned by methods like Level:getAOE()
-- and Level:getActorsAt().
-- It is currently unused.
-- @classmod ActorStorage

local Object = require "object"
local SparseMap = require "structures.sparsemap"

local ActorStorage = Object:extend()

--- The constructor for the 'ActorStorage' class.
-- Initializes the list, spatial map, and component cache.
function ActorStorage:__new()
    self.actors = {}
    self.sparse_map = SparseMap()
    self.componentCache = {}
end

--- Adds an actor to the storage, updating the spatial map and component cache.
-- @tparam Actor actor The actor to add.
function ActorStorage:addActor(actor)
   table.insert(self.actors, actor)
   self:updateComponentCache(actor)
   self:insertSparseMapEntries(actor)
end

--- Removes an actor from the storage, updating the spatial map and component cache.
-- @tparam Actor actor The actor to remove.
function ActorStorage:removeActor(actor)
   self:removeComponentCache(actor)
   self:removeSparseMapEntries(actor)

   for k, v in ipairs(self.actors) do
      if v == actor then return table.remove(self.actors, k) end
   end
end

--- Returns whether the storage contains the specified actor.
-- @tparam Actor actor The actor to check.
-- @treturn boolean True if the storage contains the actor, false otherwise.
function ActorStorage:hasActor(actor)
   for _, candidate_actor in ipairs(self.actors) do
      if candidate_actor == actor then return true end
   end

   return false
end

--- Returns whether the storage contains an actor with the specified component.
-- @tparam Component component The component to check.
-- @treturn boolean True if the storage contains an actor with the component, false otherwise.
function ActorStorage:hasActorWithComponent(component)
   for _, _ in self:eachActor(component) do
      return true
   end

   return false
end

local dummy = {}
--- Returns an iterator over the tiles occupied by the specified actor. This is a convenience method.
-- You can also use the actor's 'Collideable' component directly.
-- @tparam Actor actor The actor to iterate over.
-- @treturn function An iterator over the tiles occupied by the actor.
function ActorStorage:eachActorTile(actor)
   local count = 0

   local collideable_component = actor:getComponent(components.Collideable)
   if not collideable_component then
      count = 1
      dummy[1] = actor.position
      return ipairs(dummy)
   end

   return collideable_component:eachCellGlobal(actor)
end

--- Returns an iterator over the actors in the storage. If a component is specified, only actors with that 
-- component will be returned.
-- @tparam[opt] Component ... The components to filter by.
-- @treturn function An iterator over the actors in the storage.
function ActorStorage:eachActor(...)
   local n = 1
   local comp = { ... }

   if #comp == 1 and self.componentCache[comp[1]] then
      local currentComponentCache = self.componentCache[comp[1]]
      local key = next(currentComponentCache, nil)

      return function()
         if not key then return end

         local ractor, rcomp = key, key:getComponent(comp[1])
         key = next(currentComponentCache, key)

         return ractor, rcomp
      end
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

--- Returns an iterator over the actors in the storage that have the specified prototype.
-- @tparam Prototype prototype The prototype to filter by.
-- @treturn function An iterator over the actors in the storage.
function ActorStorage:getActorByType(prototype)
   for i = 1, #self.actors do
      if self.actors[i]:is(prototype) then return self.actors[i] end
   end
end

--- Returns a table of actors in the storage at the given position.
-- TODO: Return an ActorStorage object instead of a table.
-- @tparam number x The x-coordinate to check.
-- @tparam number y The y-coordinate to check.
-- @treturn table A table of actors at the given position.
function ActorStorage:getActorsAt(x, y)
   local actorsAtPosition = {}
   for actor, _ in pairs(self.sparse_map:get(x, y)) do
      table.insert(actorsAtPosition, actor)
   end

   return actorsAtPosition
end

--- Returns an iterator over the actors in the storage at the given position.
-- @tparam number x The x-coordinate to check.
-- @tparam number y The y-coordinate to check.
-- @treturn function An iterator over the actors at the given position.
function ActorStorage:eachActorAt(x, y)
   local key, _
   local actors = self.sparse_map:get(x, y)
   local function iterator()
      key, _ = next(actors, key)
      return key
   end
   return iterator
end

--- Removes the specified actor from the spatial map.
-- @tparam Actor actor The actor to remove.
function ActorStorage:removeSparseMapEntries(actor)
    for vec in self:eachActorTile(actor) do
       self.sparse_map:remove(vec.x, vec.y, actor)
       if actor:getComponent(components.Opaque) then self:updateOpacityCache(vec.x, vec.y) end
    end
 end
 
--- Inserts the specified actor into the spatial map.
-- @tparam Actor actor The actor to insert.
function ActorStorage:insertSparseMapEntries(actor)
   for vec in self:eachActorTile(actor) do
      self.sparse_map:insert(vec.x, vec.y, actor)
      if actor:getComponent(components.Opaque) then self:updateOpacityCache(vec.x, vec.y) end
   end
end

--- Updates the opacity cache for the specified actor.
-- @tparam Actor actor The actor to update the opacity cache for.
function ActorStorage:updateComponentCache(actor)
   for _, component in pairs(components) do
      if not self.componentCache[component] then self.componentCache[component] = {} end

      if actor:hasComponent(component) then
         self.componentCache[component][actor] = true
      else
         self.componentCache[component][actor] = nil
      end
   end
end

--- Removes the specified actor from the component cache.
-- @tparam Actor actor The actor to remove from the component cache.
function ActorStorage:removeComponentCache(actor)
   for _, component in pairs(components) do
      if self.componentCache[component] then self.componentCache[component][actor] = nil end
   end
end

return ActorStorage