local System = require "core.system"
local vec2 = require "math.vector"

local AnimateSystem = System:extend()
AnimateSystem.name = "Animate"
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
      local is_finished = true
      for _, v in ipairs(drawable.animations) do

         for _, v2 in ipairs(v) do
            if not v2:func(drawable) then
               is_finished = false
            end
         end

         if not is_finished then
            break
         end
         reached = reached + 1
      end
      for i = reached, 1, -1 do
         table.remove(drawable.animations, i)
      end
   end
end

function AnimateSystem:onActorAdded(level, actor)
   local drawable = actor:getComponent(components.Drawable)
   if drawable then
      drawable.transform.x = actor.position.x + drawable.transform.ox
      drawable.transform.y = actor.position.y + drawable.transform.oy

      drawable.transform.r = drawable.transform.r or 0
   end
end



function AnimateSystem:beforeAction(_, actor, action)
   local drawable = actor:getComponent(components.Drawable)
   if drawable then
      table.insert(drawable.animations, {})

      local buffered_animations = #drawable.animations
      if buffered_animations == 1 then
         drawable.speed = 1
      else
         drawable.speed = math.max(drawable.speed, buffered_animations)
      end
   end

   if self.animation_by_action[action.name] then
      self.animation_by_action[action.name](actor, action)
   end

end

local anim_func = function(animation, drawable)
   local t = math.clamp( (drawable.t-animation.start)*animation.speed, 0, 1)

   animation.drawable.transform.x = math.lerp(animation.from.x, animation.to.x, animation.easing(t)) + animation.drawable.transform.ox
   animation.drawable.transform.y = math.lerp(animation.from.y, animation.to.y, animation.easing(t)) + animation.drawable.transform.oy
   animation.drawable.transform.r = math.lerp(0, math.pi*2, animation.easing(t))
   if t == 1 then
      return true
   end
end

local function get_start_time(drawable)
   local start
   local last_turn = drawable.animations[#drawable.animations-1]
   if last_turn then
      if last_turn[1] then
         -- might need tweaking with a turn of different anim speeds and starts
         start = last_turn[1].start + (1 / last_turn[1].speed )
      end
   end
   return start or drawable.t
end

AnimateSystem.animation_by_action = {}
AnimateSystem.animation_by_action["attack"] = function(actor, action)
   local drawable = actor:getComponent(components.Drawable)
   if drawable then

      local animation = {
         drawable = drawable,
         from = actor.position,
         to = action:getTarget(1).position,
         speed = 2,
         start = get_start_time(drawable),
         easing = mathx.pingpong,
         func = anim_func
      }

      table.insert(drawable.animations[#drawable.animations], animation)
   end
end

-- Until the move action only triggers when a valid move occurs, this stays off.
-- AnimateSystem.animation_by_action["move"] = function(actor, action)
--    local drawable = actor:getComponent(components.Drawable)
--    if drawable then
--       local animation = {
--          drawable = drawable,
--          from = actor.position,
--          to = actor.position + action:getTarget(1),
--          speed = 2,
--          start = get_start_time(drawable),
--          easing = function(f) return f end,
--          func = anim_func
--       }

--       table.insert(drawable.animations[#drawable.animations], animation)
--    end
-- end

function AnimateSystem:onMove(_, actor, from, to)
   local drawable = actor:getComponent(components.Drawable)
   if drawable then

      local animation = {
         drawable = drawable,
         from = from,
         to = to,
         speed = 2,
         start = get_start_time(drawable),
         easing = function(f) return f*f / (2.0 * (f*f - f) + 1.0) end,--mathx.ease_inout,--function(f) return f end,
         func = anim_func
      }

      table.insert(drawable.animations[#drawable.animations], animation)
   end
end

return AnimateSystem