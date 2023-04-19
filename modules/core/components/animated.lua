local Component = require "core.component"

local Animated = Component:extend()
Animated.name = "Animated"

function Animated:__new(options)
   options = options or {}
   self.sheet = options.sheet
end

return Animated
