local Component = require "core.component"

local Drawable = Component:extend()
Drawable.name = "Drawable"

function Drawable:__new(options)
   options = options or {}
   self.sheet = options.sheet
end

function Drawable:initialize(actor)
   self.last_position = actor.position
   self.current_position = actor.position
   self.target_position = actor.position
   self.t = 1
end

return Drawable