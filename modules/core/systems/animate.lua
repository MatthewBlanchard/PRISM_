local System = require "core.system"
local vec2 = require "math.vector"

local AnimateSystem = System:extend()
AnimateSystem.name = "AnimateSystem"

function AnimateSystem:animate(level, actor)
   local drawable = actor:getComponent(components.Drawable)
   if drawable and drawable.anim_type == "to" then

      drawable.t = math.min(drawable.t + 3*love.timer.getDelta(), 1)
      local x = math.lerp(drawable.last_position.x, drawable.target_position.x, drawable.t^2)
      local y = math.lerp(drawable.last_position.y, drawable.target_position.y, drawable.t^2)
      drawable.current_position = vec2(x, y)
   end
   if drawable and drawable.anim_type == "bounce" then
      drawable.t = math.min(drawable.t + 6*love.timer.getDelta(), 2)
      local x, y
      if drawable.t <= 1 then
         x = math.lerp(drawable.last_position.x, drawable.target_position.x, drawable.t)
         y = math.lerp(drawable.last_position.y, drawable.target_position.y, drawable.t)
      else
         x = math.lerp(drawable.target_position.x, drawable.last_position.x, drawable.t-1)
         y = math.lerp(drawable.target_position.y, drawable.last_position.y, drawable.t-1)
      end

      drawable.current_position = vec2(x, y)
   end
end

function AnimateSystem:onActorAdded(level, actor)
   local drawable = actor:getComponent(components.Drawable)
   if drawable then
      drawable.last_position = actor.position
      drawable.target_position = actor.position
   end
end

function AnimateSystem:onMove(level, actor, from, to)
   local drawable = actor:getComponent(components.Drawable)
   if drawable then
      drawable.anim_type = "to"
      drawable.t = 0
      drawable.last_position = from--drawable.current_position
      drawable.target_position = to
   end
end

function AnimateSystem:beforeAction(level, actor, action)
   local drawable = actor:getComponent(components.Drawable)
   if drawable and action.name == "attack" then
      drawable.anim_type = "bounce"
      drawable.t = 0
      drawable.last_position = actor.position--drawable.current_position
      drawable.target_position = action:getTarget(1).position
   end
end

return AnimateSystem