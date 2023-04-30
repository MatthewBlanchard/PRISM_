local System = require "core.system"
local vec2 = require "math.vector"

local AnimateSystem = System:extend()
AnimateSystem.name = "Animate"
AnimateSystem.speed = 1

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
      [1] = {
         t = 0, 
         func = function(timeline, i)
            object.x = animation.from.x
            object.y = animation.from.y

            object.sx = math.lerp(1, 1.5, math.ease_in(map(t, timeline[i].t, timeline[i+1].t)))
            object.sy = math.lerp(1, 0.5, math.ease_in(map(t, timeline[i].t, timeline[i+1].t)))

            object.oy = 15
         end
      },
      [2] = {
         t = 0.25, 
         func = function(timeline, i)
            object.x = math.lerp(animation.from.x, animation.to.x, math.ease_inout(map(t, 0.25, 0.5)))
            object.y = 
               math.lerp(animation.from.y, animation.to.y, math.ease_inout(map(t, 0.25, 0.5)))
               - math.sin(math.pi*map(t, 0.25, 0.5))

            object.sx = math.lerp(1.5, 0.5, math.ease_out(map(t, timeline[i].t, timeline[i+1].t)))
            object.sy = math.lerp(0.5, 1.5, math.ease_out(map(t, timeline[i].t, timeline[i+1].t)))
         end
      },
      [3] = {
         t = 0.5, 
         func = function(timeline, i)
            object.x = animation.to.x
            object.y = animation.to.y


            object.sx = math.lerp(0.5, 1.25, math.ease_out(map(t, timeline[i].t, timeline[i+1].t)))
            object.sy = math.lerp(1.5, 0.75, math.ease_out(map(t, timeline[i].t, timeline[i+1].t)))
         end
      },
      [4] = {
         t = 0.75, 
         func = function(timeline, i)
            object.x = animation.to.x
            object.y = animation.to.y

            object.sx = math.lerp(1.25, 1, math.ease_out(map(t, timeline[i].t, timeline[i+1].t)))
            object.sy = math.lerp(0.75, 1, math.ease_out(map(t, timeline[i].t, timeline[i+1].t)))
         end
      },
      [5] = {
         t = 1, 
         func = function(timeline, i)
            object.x = animation.to.x
            object.y = animation.to.y
            object.oy = 7.5

            object.sx = 1
            object.sy = 1
         end
      },
   }

   for i = 1, #timeline - 1 do
      if t > timeline[i].t and t <= timeline[i+1].t then
         timeline[i].func(timeline, i)

         break
      end
   end


   if t == 1 then
      timeline[#timeline].func(timeline, i)
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
         speed = 1,
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