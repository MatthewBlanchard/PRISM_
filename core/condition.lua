--- A `Condition` is an event handler that is attached to an actor.
-- It can listen to events such as an actor taking an action, moving, or a tick of time.
-- This can be used for things like buffs, debuffs, poisons, and other actor-specific mechanics.
-- @classmod Condition
local Event = require "core.event"
local Object = require "object"

local Condition = Object:extend()

--- A table of events that trigger when an action is taken.
Condition.onActions = {}

--- A table of events that trigger after an action is taken.
Condition.afterActions = {}

--- A table of events that trigger when a tick of time passes.
Condition.onTicks = {}

Condition.setTimes = {}

function Condition:extend()
   local self = Object.extend(self)

   -- Since we're defining these as static elements in a table that shouldn't be changed
   -- on instantiated objects we have to copy these tables or all changes will end up on the base
   -- class.
   local oldOnActions, oldAfterActions, oldSetTime =
      self.onActions, self.afterActions, self.setTimes
   local oldOnTick = self.onTicks
   self.onActions = {}
   self.afterActions = {}
   self.setTimes = {}
   self.onTicks = {}
   self.onScrys = {}

   for k, v in pairs(oldOnActions) do
      self.onActions[k] = v
   end

   for k, v in pairs(oldAfterActions) do
      self.afterActions[k] = v
   end

   for k, v in pairs(oldSetTime) do
      self.setTimes[k] = v
   end

   for k, v in pairs(oldOnTick) do
      self.onTicks[k] = v
   end

   return self
end

--- This function is called when the condition is applied. Can be overridden by child classes.
function Condition:onApply() end

--- This function is called when the condition is removed. Can be overridden by child classes.
function Condition:onRemove() end

--- Sets the duration of the condition and adds a tick event to remove the condition after the duration has passed.
-- @tparam number duration The duration of the condition.
function Condition:setDuration(duration)
   self:onTick(function(self, level, actor)
      self.time = (self.time or 0) + 100

      if self.time > duration then
         if self.onDurationEnd then self:onDurationEnd(level, actor) end
         actor:removeCondition(self)
      end
   end)
end

function Condition:getActionEvents(type, level, action)
   local e = {}
   local shouldret = false

   if not self[type] then return false end

   for k, event in pairs(self[type]) do
      event.owner = self
      if type == "onTicks" or type == "onScrys" or event:shouldFire(level, action) then
         table.insert(e, event)
         shouldret = true
      end
   end

   return shouldret and e or false
end

--- Adds an event that triggers when a specific action is performed.
-- @tparam Action action The action that triggers the event.
-- @tparam function func The function to be called when the event is fired.
-- @treturn Event The created event.
function Condition:onAction(action, func)
   local e = Event(action, func)

   table.insert(self.onActions, e)
   return e
end

--- Adds an event that triggers each tick.
-- @tparam function func The function to be called when the event is fired.
-- @treturn Event The created event.
function Condition:onTick(func)
   local e = Event(nil, func)

   table.insert(self.onTicks, e)
   return e
end

--- Adds an event that triggers when a scrying is performed in the sight system.
-- @tparam function func The function to be called when the event is fired.
-- @treturn Event The created event.
function Condition:onScry(func)
   local e = Event(nil, func)

   table.insert(self.onScrys, e)
   return e
end

--- Adds an event that triggers when a specific reaction is performed.
-- @tparam Reaction reaction The reaction that triggers the event.
-- @tparam function func The function to be called when the event is fired.
-- @treturn Event The created event.
function Condition:onReaction(reaction, func) self:onAction(reaction, func) end

--- Adds an event that triggers after a specific action is performed.
-- @tparam Action action The action that triggers the event.
-- @tparam function func The function to be called when the event is fired.
-- @treturn Event The created event.
function Condition:afterAction(action, func)
   local e = Event(action, func)
   table.insert(self.afterActions, e)
   return e
end

--- Adds an event that triggers at a specific time.
-- @tparam Action action The action that triggers the event.
-- @tparam function func The function to be called when the event is fired.
-- @treturn Event The created event.
function Condition:setTime(action, func)
   local e = Event(action, func)

   table.insert(self.setTimes, e)
   return e
end

--- This function is called when the actor associated with the condition is removed from the level.
function Condition:onActorRemoved(level) end

--- Adds an event that triggers after a specific reaction is performed.
-- @tparam Reaction reaction The reaction that triggers the event.
-- @tparam function func The function to be called when the event is fired.
-- @treturn Event The created event.
function Condition:afterReaction(reaction, func) return self:afterAction(reaction, func) end

--- Returns whether the owner of the condition is the target of the action.
-- @tparam Actor actor The owner of the condition.
-- @tparam Level level The level where the action took place.
-- @tparam Action action The action to check.
-- @treturn boolean Whether the owner of the condition is the target of the action.
function Condition.ownerIsTarget(actor, level, action) return action:hasTarget(actor) end

return Condition
