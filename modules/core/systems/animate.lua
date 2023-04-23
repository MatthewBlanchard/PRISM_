local System = require "core.system"

local AnimateSystem = System:extend()
AnimateSystem.name = "AnimateSystem"

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
      drawable.t = 0
      drawable.last_position = from--drawable.current_position
      drawable.target_position = to
   end
end

return AnimateSystem