local Component = require "core.component"

local Drawable = Component:extend()
Drawable.name = "Drawable"

function Drawable:__new(options)
   options = options or {}
   self.sheet = options.sheet
end

function Drawable:initialize(actor)
   self.position = actor.position
   self.t = 0
   self.speed = 1

   self.animations = {}
end

return Drawable