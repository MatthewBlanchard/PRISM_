local Object = require "object"
local System = require "core.system"
local vec2 = require "math.vector"
local Second_Order_Dynamics = require "math.ode"

local AnimateSystem = System:extend()
AnimateSystem.name = "Animate"
AnimateSystem.speed = 1

local function map(input, in_start, in_end, out_start, out_end)
   local out_start = out_start or 0
   local out_end = out_end or 1
   local slope = (out_end - out_start) / (in_end - in_start)
   return out_start + slope * (input - in_start)
end



function AnimateSystem:updateTimers()
   local dt = love.timer.getDelta()

   for _, actor in ipairs(game.level.actors) do
      local drawable = actor:getComponent(components.Drawable)
      if drawable then
         local object = drawable.object
         object.ode:update_buffer(dt)
      end
   end
end

function AnimateSystem:animate(level, actor)
   local drawable = actor:getComponent(components.Drawable)
   if drawable then
      local object = drawable.object
      object:set_pos(
         object.ode:update(
            love.timer.getDelta()
         )
      )
   end
end

function AnimateSystem:onActorAdded(level, actor)
   local drawable = actor:getComponent(components.Drawable)
   if drawable then
      drawable.object:set_pos(actor.position)
      drawable.object.ode = Second_Order_Dynamics(1, 1, 2, actor.position)
   end
end

function AnimateSystem:beforeAction(_, actor, action)

   if self.animation_by_action[action.name] then
      self.animation_by_action[action.name](actor, action)
   end

end

AnimateSystem.animation_by_action = {}
AnimateSystem.animation_by_action["attack"] = function(actor, action)
   local drawable = actor:getComponent(components.Drawable)
   if drawable then
      local object = drawable.object
      local to = (action:getTarget(1).position - actor.position) / 2 + actor.position
      object.ode:clear_buffer()
      object.ode:buffer_input(to, 0)
      object.ode:buffer_input(actor.position, 0.2)
      object.ode:set_params(2, 0.5, -2)
   end
end

function AnimateSystem:onMove(_, actor, from, to)
   local drawable = actor:getComponent(components.Drawable)
   if drawable then
      local object = drawable.object
      object.ode:clear_buffer()
      object.ode:buffer_input(to, 0)
      object.ode:set_params(1, 1, 2)
   end
end

return AnimateSystem