local vec2 = require "math.vector"
local Object = require "object"

local Second_Order_Dynamics = Object:extend()
function Second_Order_Dynamics:__new(f, z, r, x0)
   local PI = math.pi

   self.f, self.z, self.r = f, z, r

   self.k1 = z / (PI * f)
   self.k2 = 1 / ((2*PI*f)^2)
   self.k3 = (r * z) / (2*PI*f)

   self.stored = x0
   self.buffered = {}
   self.xp = x0
   self.y = x0
   self.yd = vec2(0, 0)
end

function Second_Order_Dynamics:buffer_input(x, t)
   table.insert(self.buffered, {x = x, t = t or 0})
end

function Second_Order_Dynamics:update_buffer(t)
   if self.buffered[1] then
      self.buffered[1].t = self.buffered[1].t - t
      if self.buffered[1].t <= 0 then
         self.stored = self.buffered[1].x
         table.remove(self.buffered, 1)
      end
   end
end

function Second_Order_Dynamics:set_params(f, z, r)
   local PI = math.pi

   f = f or self.f
   z = z or self.z
   r = r or self.r
   
   self.k1 = z / (PI * f)
   self.k2 = 1 / ((2*PI*f)^2)
   self.k3 = (r * z) / (2*PI*f)
end

function Second_Order_Dynamics:update(t, x, xd)
   if x == nil then x = self.stored end
   if xd == nil then
      xd = xd or ((x - self.xp) / t) -- estimate velocity
      self.xp = x
   end
   local k2_stable = math.max(self.k2, 1.1 * (t*t/4 + t*self.k1/2))
   self.y = self.y + self.yd*t -- integrate position by velocity
   self.yd = self.yd + (x + xd*self.k3 - self.y - self.yd*self.k1) * t / k2_stable

   return self.y
end

return Second_Order_Dynamics