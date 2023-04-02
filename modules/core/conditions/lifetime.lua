local Condition = require "core.condition"
local Tiles = require "display.tiles"

local Lifetime = Condition:extend()
Lifetime.duration = 100
Lifetime.name = "Lifetime"

function Lifetime:onDurationEnd(level, actor)
  local effects_system = level:getSystem("Effects")
  effects_system:addEffect(effects.Character(actor.position.x, actor.position.y, Tiles["poof"], {.4, .4, .4}, 0.3))
  level:removeActor(actor)
end

return Lifetime
