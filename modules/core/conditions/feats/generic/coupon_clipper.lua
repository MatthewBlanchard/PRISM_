local Condition = require("core.condition")

local CouponClipper = Condition:extend()
CouponClipper.name = "Coupon Clipper"
CouponClipper.description = "25% off all items in the store! Please don't call my manager!"

<<<<<<< HEAD
CouponClipper:onAction(
   actions.Buy,
   function(self, level, actor, action)
      action.price = action.price - math.floor(action.price * 0.25)
   end
)
=======
CouponClipper:onAction(actions.Buy, function(self, level, actor, action)
	action.price = action.price - math.floor(action.price * 0.25)
end)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return CouponClipper
