--- Core module
-- @module Core

local Object = require "object"
local Vector2 = require "math.vector"
local Tiles = require "display.tiles"
local Component = require "core.component"
local Action = require "core.action"
local Reaction = require "core.reaction"

--- Represents entities in the game, including the player, enemies, and items.
--- Actors are composed of Components that define their state and behavior.
--- For example, an actor may have a Sight component that determines their field of vision, explored tiles, and other related aspects.
--- The Sight System handles the mechanics of an actor's sight.
-- @type Actor
local Actor = Object:extend()

--- A collection of the actor's innate actions. This is used mostly for
--- actions that are 'instrinsic' to the actor, such as a spider casting a web.
--- It might be better to use a component for this, and I may change it in the future.
-- @tfield table actions
Actor.actions = nil

--- A collection of the actor's innate reactions. This is hardly ever used
--- and marked for removal.
-- @tfield table reactions
Actor.reactions = nil

-- An actor's Conditions, event handlers that modify the actor's state and actions.
-- @tfield table conditions
Actor.conditions = nil

--- The position of the actor on the map.
-- @tfield Vector2 position
Actor.position = nil

--- The name of the actor.
-- @tfield string name
Actor.name = "actor"

--- Defines whether the actor can be seen.
-- @tfield boolean passable
Actor.visible = true

--- Defines the actor's base color.
-- @tfield table color
Actor.color = { 1, 1, 1, 1 }

--- Defines whether the actor's color should be used instead of it's lit color.
-- @tfield boolean emissive
Actor.emissive = false

--- Defines the actor's offset in the sprite sheet.
-- @field offset integer
Actor.char = Tiles["player_1"]

--- Whether to conjugate verbs when referring to the actor. Currently non-functional.
-- @tfield conjugate boolean
Actor.conjugate = true

--- The pronoun to use when referring to the actor. Currently non-functional.
-- @tfield string pronoun
Actor.pronoun = "it" -- the pronoun for the actor

--- The article to use when referring to the actor. Currently non-functional.
-- @tfield string article
Actor.article = "a" -- the article for the actor

--- Constructor for an actor.
-- Initializes and copies the actor's fields from it's prototype.
-- @function Actor:__new
function Actor:__new()
   self.position = Vector2(1, 1)
   self.lposition = self.position
   self.actions = self.actions or {}
   self.reactions = self.reactions or {}
   self.conditions = {}

   for k, v in pairs(self.actions) do
      self.actions[k] = v:extend()
   end

   local components = self.components
   self.components = {}
   self.componentCache = {}
   if self.components then
      for k, component in ipairs(components) do
         component.owner = self
         self:__addComponent(component:extend())
      end
   end
end

--- Called after an actor is added to a level and it's components are initialized. This will
--- happen either at level start or when an actor is spawned.
-- @function Actor:initialize
-- @tparam Level level The level the actor is being added to.
function Actor:initialize(level)
   -- you should implement this in your own actor for things like
   -- applying conditions that are innate to the actor.
end

--
-- Components
--

--- Initializes the actor's components. Components shouldn't need a reference to the
--- level so this is called in Actor:__new.
-- @function Actor:initializeComponents
function Actor:initializeComponents()
   for k, component in ipairs(self.components) do
      component:initialize(self)
   end
end

--- Adds a component to the actor. This function will check if the component's
--- prerequisites are met and will throw an error if they are not.
-- @function Actor:__addComponent
-- @tparam Component component The component to add to the actor.
function Actor:__addComponent(component)
   assert(component:is(Component), "Expected argument component to be of type Component!")
   assert(component.name, "Component must have name field!")

   for k, v in pairs(components) do
      if component:is(v) then
         if self.componentCache[v] then error("Actor already has component " .. v.name .. "!") end
         self.componentCache[v] = component
      end
   end

   if not component:checkRequirements(self) then error "Unsupported component added to actor!" end

   if self:hasComponent(component) then
      error("Actor already has component " .. component.name .. "!")
   end

   component.owner = self
   table.insert(self.components, component)
   component:initialize(self)
end

--- Removes a component from the actor. This function will throw an error if the
--- component is not present on the actor.
-- @function Actor:__removeComponent
-- @tparam Component component The component to remove from the actor.
function Actor:__removeComponent(component)
   assert(component:is(Component), "Expected argument component to be of type Component!")

   for k, v in pairs(components) do
      if component:is(v) then
         if not self.componentCache[v] then
            error("Actor does not have component " .. v.name .. "!")
         end

         for cached_component, _ in pairs(self.componentCache) do
            if cached_component:is(v) then self.componentCache[cached_component] = nil end
         end
      end
   end

   for i = 1, #self.components do
      if self.components[i]:is(getmetatable(component)) then
         local component = table.remove(self.components, i)
         component.owner = nil
         return component
      end
   end
end

--- Returns a bool indicating whether the actor has a component of the given type.
-- @function Actor:hasComponent
-- @tparam Component type The prototype of the component to check for.
function Actor:hasComponent(type)
   assert(type:is(Component), "Expected argument type to be inherited from Component!")

   return self.componentCache[type] ~= nil
end

-- Returns the first component of the given type that the actor has.
-- @function Actor:getComponent
-- @tparam Component type The type of the component to return.
function Actor:getComponent(type) return self.componentCache[type] end

--
-- Actions
--

--- Get a list of actions from the actor and all of its components.
-- @function Actor:getActions
-- @treturn table total_actions Returns a table of all actions.
function Actor:getActions()
   local total_actions = {}

   for k, action in pairs(self.actions) do
      table.insert(total_actions, action)
   end

   for k, component in pairs(self.components) do
      if component.actions then
         for k, action in pairs(component.actions) do
            table.insert(total_actions, action)
         end
      end
   end

   return total_actions
end

--- Add an action to the actor.
-- This function will throw an error if the action is already present on the actor.
-- @function Actor:addAction
-- @tparam Action action The action to add to the actor.
function Actor:addAction(action)
   assert(action:is(Action), "Expected argument action to be of type Action!")

   for k, v in pairs(self.actions) do
      if v:is(action) then error "Attempted to add existing action to actor!" end
   end
   table.insert(self.actions, action)
end

--- Remove an action from the actor.
-- @function Actor:removeAction
-- @tparam Action action The action to remove from the actor.
function Actor:removeAction(action)
   for k, v in pairs(self.actions) do
      if v:is(action) then
         table.remove(self.actions, k)
         return
      end
   end
end

--- Get's an action from the actor.
-- This function will check the actor's actions and all of its components for the action.
-- @function Actor:getAction
-- @tparam Action prototype The prototype of the action to get.
function Actor:getAction(prototype)
   assert(prototype:is(Action), "Expected argument prototype to be of type Action!")

   for _, action in pairs(self.actions) do
      if action:is(prototype) then return action end
   end

   for _, component in pairs(self.components) do
      if component.actions then
         for _, action in pairs(component.actions) do
            if action:is(prototype) then return action end
         end
      end
   end
end

--- Adds a reaction to the actor.
-- @function Actor:addReaction
-- @tparam Reaction reaction The reaction to add to the actor.
function Actor:addReaction(reaction)
   assert(reaction:is(Reaction), "Expected argument reaction to be of type Reaction!")

   table.insert(self.reactions, reaction)
end

--- Gets the first reaction of the given type that the actor has.
-- @function Actor:getReaction
-- @tparam Reaction reaction The type of the reaction to get.
function Actor:getReaction(reaction)
   for k, v in pairs(self.reactions) do
      if v:is(reaction) then return v end
   end
end

--
-- Conditions
--

--- Attaches a condition to the actor.
-- If the actor already has a condition of the same type and the condition is not stackable, the old condition will
-- be removed.
-- @function Actor:applyCondition
-- @tparam Condition condition The condition to apply to the actor.
function Actor:applyCondition(condition)
   if self:hasCondition(getmetatable(condition)) and condition.stackable == false then
      self:removeCondition(condition)
   end

   table.insert(self.conditions, condition)
   condition.owner = self

   condition:onApply()
end

--- Checks if the actor has a condition of the given type.
-- @function Actor:hasCondition
-- @tparam Condition condition The type of the condition to check.
function Actor:hasCondition(condition)
   for i = 1, #self.conditions do
      if self.conditions[i]:is(condition) then return true end
   end

   return false
end

--- Removes a condition from the actor. 
-- Returns a bool indicating whether the condition was removed.
-- @function Actor:removeCondition
-- @tparam Condition condition The type of the condition to remove.
function Actor:removeCondition(condition)
   for i = 1, #self.conditions do
      if self.conditions[i]:is(condition) then
         self.conditions[i]:onRemove()
         table.remove(self.conditions, i)
         return true
      end
   end

   return false
end

--- Returns a list of all conditions that the actor has.
-- @function Actor:getConditions
-- @treturn table conditions Returns a table of all conditions.
function Actor:getConditions() return self.conditions end

--
-- Utility
--

--- Returns the current position of the actor.
-- @function Actor:getPosition
-- @treturn Vector2 Returns a copy of the actor's current position.
function Actor:getPosition() return Vector2(self.position.x, self.position.y) end

--- Get the range from this actor to another actor.
-- @function Actor:getRange
-- @tparam string type The type of range calculation to use.
-- @tparam Actor actor The other actor to get the range to.
-- @treturn number Returns the calculated range.
function Actor:getRange(type, actor)
   local lowest = math.huge

   local collideable_component = self:getComponent(components.Collideable)
   local other_collideable_component = actor:getComponent(components.Collideable)

   if collideable_component and other_collideable_component then
      if collideable_component.size == 1 and other_collideable_component.size == 1 then
         return self.position:getRange(type, actor.position)
      end

      for vec in collideable_component:eachCellGlobal(self) do
         for other_vec in other_collideable_component:eachCellGlobal(actor) do
            local range = vec:getRange(type, other_vec)
            if range < lowest then lowest = range end
         end
      end
   else
      return self.position:getRange(type, actor.position)
   end

   return lowest
end

--- Get the range from this actor to a given vector.
-- @function Actor:getRangeVec
-- @tparam string type The type of range calculation to use.
-- @tparam Vector2 vector The vector to get the range to.
-- @treturn number Returns the calculated range.
function Actor:getRangeVec(type, vector) return self.position:getRange(type, vector) end

--- A utility function that returns a bool if the actor is visible.
-- @function Actor:isVisible
-- @treturn boolean Returns a boolean indicating if the actor is visible.
function Actor:isVisible()
   local visible = not self.visible
   for k, cond in pairs(self:getConditions()) do
      if cond.isVisible then visible = visible or not cond.isVisible() end
   end

   return not visible
end

return Actor
