local Component = require "core.component"
local Object = require "object"
local vec2 = require "math.vector"

local GraphicsObject = Object:extend()

function GraphicsObject:__new(actor, options)
   self.drawable = actor.char
   self.shader_callback = options.shader_callback
   self.colors = {fg = options.fg, bg = options.bg}

   self.ox = 7.5
   self.oy = 7.5

   self.x = 0
   self.y = 0

   self.r = 0
   
   self.sx = 1
   self.sy = 1

   self.kx = 0
   self.ky = 0
   
   self.transform = love.math.newTransform()
end

function GraphicsObject:set_pos(grid_space_vec)
   self.x = grid_space_vec.x
   self.y = grid_space_vec.y
end

function GraphicsObject:get_pos()
   return vec2(self.x, self.y)
end

function GraphicsObject:set(name, arg)

end

function GraphicsObject:update_transform()
   self.transform:setTransformation(
      self.ox + (self.x-1)*15, self.oy + (self.y-1)*15,
      self.r,
      self.sx, self.sy,
      self.ox, self.oy,
      self.kx, self.ky
   )
end

local Drawable = Component:extend()
Drawable.name = "Drawable"

function Drawable:__new(options)
   options = options or {}
   self.options = options
   self.sheet = options.sheet
end

function Drawable:initialize(actor)
   self.object = GraphicsObject(actor, self.options)

   self.shader = love.graphics.newShader("display/shaders/outline_shader.glsl")
   self.object.shader_callback = function(quad)
      self.shader:send("viewport", {quad:getViewport()})
      love.graphics.setShader(self.shader)
   end

   self.t = 0
   self.speed = 1
   self.animations = {}
end

return Drawable