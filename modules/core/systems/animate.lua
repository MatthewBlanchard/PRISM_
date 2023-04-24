local System = require "core.system"
local vec2 = require "math.vector"

local AnimateSystem = System:extend()
AnimateSystem.name = "AnimateSystem"
AnimateSystem.speed = 2

function AnimateSystem:updateTimers()
   local dt = love.timer.getDelta()

   for _, actor in ipairs(game.level.actors) do
      local drawable = actor:getComponent(components["Drawable"])
      if drawable then
         drawable.t = drawable.t + (dt * drawable.speed * self.speed)
      end
   end
end

function AnimateSystem:animate(level, actor)
   local drawable = actor:getComponent(components.Drawable)
   if drawable then
      local reached = 0
      for _, v in pairs(drawable.animations) do
         for _, v2 in ipairs(v) do
            local finished = v2:func(drawable)
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

local anim_func = function(animation, drawable)
   local t = (drawable.t-animation.start)*animation.speed

   animation.drawable.position = math.lerp(animation.from, animation.to, math.min(t, 1))
   if t >= 1 then
      return true
   end
end

function AnimateSystem:beforeAction(_, actor, action)
   local drawable = actor:getComponent(components.Drawable)
   if drawable then
      local buffered_animations = #drawable.animations.position
      if buffered_animations == 0 then
         drawable.speed = 1
      else
         drawable.speed = math.max(drawable.speed, buffered_animations)
      end
   end
end

function AnimateSystem:onMove(_, actor, from, to)
   local drawable = actor:getComponent(components.Drawable)
   if drawable then
      local start
      for i, v in ipairs(drawable.animations.position) do
         if i == 1 then start = v.start end
         start = start + 1/v.speed
      end
      start = start or drawable.t

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

return AnimateSystem