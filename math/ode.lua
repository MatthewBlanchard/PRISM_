local vec2 = require "math.vector"
local Object = require "object"

local Second_Order_Dynamics = Object:extend()
function Second_Order_Dynamics:__new(f, z, r, x0)
   local PI = math.pi

   self.k1 = z / (PI * f)
   self.k2 = 1 / ((2*PI*f)^2)
   self.k3 = (r * z) / (2*PI*f)

   self.xp = x0
   self.y = x0
   self.yd = vec2(0, 0)
end

function Second_Order_Dynamics:update(t, x, xd)
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