local System = require "core.system"
local vec2 = require "math.vector"

local AnimateSystem = System:extend()
AnimateSystem.name = "Animate"
AnimateSystem.speed = 0.25

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
            if not v2:func() then
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
      drawable.object:set_pos(actor.position)
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

local anim_func = function(animation)
   local drawable = animation.drawable
   local object = drawable.object
   local t = math.clamp( (drawable.t-animation.start)*animation.speed, 0, 1)

   local dir = (animation.to - animation.from):sign()

   local function map(input, in_start, in_end, out_start, out_end)
      local out_start = out_start or 0
      local out_end = out_end or 1
      local slope = (out_end - out_start) / (in_end - in_start)
      return out_start + slope * (input - in_start)
   end

   local timeline = {
      0, 0.25, 0.5, 0.75, 1
   }
   local keyframes_sx = {
      1, 1.5, 1, 0.5, 1
   }
   local keyframes_sy = {
      1, 0.5, 1, 1.5, 1
   }

   for i = 1, #timeline - 1 do
      if t > timeline[i] and t <= timeline[i+1] then
         object.sx =
            math.lerp(keyframes_sx[i], keyframes_sx[i+1], math.ease_inout(map(t, timeline[i], timeline[i+1])))

         object.sy =
            math.lerp(keyframes_sy[i], keyframes_sy[i+1], math.ease_inout(map(t, timeline[i], timeline[i+1])))

         object.y = object.y - object.sy
         break
      end
   end

   local timeline = {
      0, 0.25
   }
   local keyframes_xy = {
      animation.from, animation.from
   }

   for i = 1, #timeline - 1 do
      if t > timeline[i] and t <= timeline[i+1] then
            object.x = math.lerp(keyframes_xy[i].x, keyframes_xy[i+1].x, math.ease_inout(map(t, timeline[i], timeline[i+1])))
            object.y = math.lerp(keyframes_xy[i].y, keyframes_xy[i+1].y, math.ease_inout(map(t, timeline[i], timeline[i+1])))
         break
      end
   end

   local timeline = {
      0.25, 1
   }
   local keyframes_xy = {
      animation.from, animation.to
   }

   for i = 1, #timeline - 1 do
      if t > timeline[i] and t <= timeline[i+1] then

         object.x =
            math.lerp(keyframes_xy[i].x, keyframes_xy[i+1].x, math.ease_inout(map(t, timeline[i], timeline[i+1])))

         object.y =
            math.lerp(keyframes_xy[i].y, keyframes_xy[i+1].y, math.ease_inout(map(t, timeline[i], timeline[i+1])))
            --- math.sin(math.pi*map(t, timeline[i], timeline[i+1]))
         break
      end
   end



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

      drawable.object.x = actor.position.x
      drawable.object.y = actor.position.y

      local animation = {
         drawable = drawable,
         from = from,
         to = to,
         speed = 2,
         start = get_start_time(drawable),
         easing =
         mathx.ease_inout,
         --function(f) return f end,
         func = anim_func
      }

      table.insert(drawable.animations[#drawable.animations], animation)
   end
end

return AnimateSystem