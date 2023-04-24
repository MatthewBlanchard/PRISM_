local System = require "core.system"
local vec2 = require "math.vector"

local AnimateSystem = System:extend()
AnimateSystem.name = "AnimateSystem"
AnimateSystem.t = 0
AnimateSystem.speed = 2

function AnimateSystem:updateTimer()
   self.t = self.t+(love.timer.getDelta()*self.speed)
end

function AnimateSystem:animate(level, actor)
   local drawable = actor:getComponent(components.Drawable)
   if drawable then
      local reached = 0
      for _, v in pairs(drawable.animations) do
         for _, v2 in ipairs(v) do
            local finished = v2:func()
            if not finished then
               break
            end
            reached = reached + 1
         end
         for i = reached, 1, -1 do
            table.remove(v, i)
         end
      end
   end
end

function AnimateSystem:onActorAdded(level, actor)
   local drawable = actor:getComponent(components.Drawable)
   if drawable then
      drawable.position = actor.position
   end
end

local anim_func = function(animation)
   local t = (AnimateSystem.t-animation.start)*animation.speed

   animation.drawable.position = math.lerp(animation.from, animation.to, math.min(t, 1))
   if t >= 1 then
      return true
   end
end

function AnimateSystem:onMove(level, actor, from, to)
   local drawable = actor:getComponent(components.Drawable)
   if drawable then
      local start
      for i, v in ipairs(drawable.animations.position) do
         if i == 1 then start = v.start end
         start = start + 1/v.speed
      end
      start = start or self.t

      local animation = {
         drawable = drawable,
         from = from,
         to = to,
         speed = 2,
         start = start,
         func = anim_func
      }

      table.insert(drawable.animations.position, animation)
   end
end

function AnimateSystem:beforeAction(level, actor, action)
end

return AnimateSystem