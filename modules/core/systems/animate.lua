local Object = require "object"
local System = require "core.system"
local vec2 = require "math.vector"
local Second_Order_Dynamics = require "math.ode"

local AnimateSystem = System:extend()
AnimateSystem.name = "Animate"
AnimateSystem.speed = 1



function AnimateSystem:updateTimers()
end

function AnimateSystem:animate(level, actor)
   local drawable = actor:getComponent(components.Drawable)
   if drawable then
      drawable.object:set_pos(
         drawable.object.ode:update(
            love.timer.getDelta(),
            actor.position
         )
      )
   end
end

function AnimateSystem:onActorAdded(level, actor)
   local drawable = actor:getComponent(components.Drawable)
   if drawable then
      drawable.object:set_pos(actor.position)
      drawable.object.ode = Second_Order_Dynamics(1, 1, 1, actor.position)
   end
end

function AnimateSystem:onMove(_, actor, from, to)
end

return AnimateSystem