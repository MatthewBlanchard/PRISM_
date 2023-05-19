--- The `Component` class represents a component that can be attached to actors.
-- Components are used to add functionality to actors. For instance, the `Moveable` component
-- allows an actor to move around the map.
-- @classmod Component

local Object = require "object"

local Component = Object:extend()

--- A table of requirements that must be met for this component to function.
-- @tfield table requirements
Component.requirements = {}

--- Initializes a new instance of the Component class.
function Component:initialize() end

--- Checks whether an actor has the required components to attach this component.
-- @tparam Actor actor The actor to check the requirements against.
-- @treturn boolean true if the actor meets all requirements, false otherwise.
function Component:checkRequirements(actor)
   local foundreqs = {}

   for k, component in pairs(actor.components) do
      for k, req in pairs(self.requirements) do
         if component:is(req) then table.insert(foundreqs, component) end
      end
   end

   if #foundreqs == #self.requirements then return true end

   return false
end

return Component
