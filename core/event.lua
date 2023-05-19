
--- A private class that is exclusively instantiated by `Condition`.
-- It's returned by `Condition`'s "onX" function cycle.
-- @classmod Event
local Event = Object:extend()

--- Initializes a new instance of the `Event` class.
-- @tparam Action action The action type that triggers this event.
-- @tparam function resolutionFunc The function to be called when this event is fired.
function Event:__new(action, resolutionFunc)
   self.action = action
   self.resolve = resolutionFunc
   self.conditionals = {}
end

--- Fires the event.
-- @tparam Condition condition The condition that the event belongs to.
-- @tparam Level level The level where the event took place.
-- @tparam Actor actor The actor that triggered the event.
-- @tparam Action action The action that triggered the event.
-- @treturn boolean The result of the event's resolution function.
function Event:fire(condition, level, actor, action)
   return self.resolve(condition, level, actor, action)
end

--- Determines whether this event should be fired based on the action and the conditionals.
-- @tparam Level level The level where the action took place.
-- @tparam Action action The action that might trigger the event.
-- @treturn boolean Whether this event should be fired.
function Event:shouldFire(level, action)
   if not action:is(self.action) then return false end

   if #self.conditionals > 0 then
      for k, conditional in pairs(self.conditionals) do
         if not conditional(self.owner.owner, level, action) then return false end
      end

      return true
   end

   if not (self.owner.owner == action.owner) then return false end

   return true
end

--- Adds an additional and arbitrary requirement to this event.
-- @tparam function condFunc The conditional function to add.
function Event:where(condFunc) table.insert(self.conditionals, condFunc) end