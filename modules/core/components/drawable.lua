local Component = require "core.component"

local Drawable = Component:extend()
Drawable.name = "Drawable"

function Drawable:__new(options)
   options = options or {}
   self.sheet = options.sheet
end

function Drawable:initialize(actor)
   self.image = actor.char
   self.shader = love.graphics.newShader("display/outline_shader.glsl")
   self.shaderFunc = function(quad)
      self.shader:send("viewport", {quad:getViewport()})
      love.graphics.setShader(self.shader)
   end
   self.transform = {
      ox = 7.5, oy = 7.5,
   }
   self.t = 0
   self.speed = 1

   self.animations = {}
end

return Drawable