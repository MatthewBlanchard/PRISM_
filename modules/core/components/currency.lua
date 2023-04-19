local Component = require("core.component")

local Currency = Component:extend()
Currency.name = "Currency"

<<<<<<< HEAD
function Currency:__new(options) self.worth = options and options.worth or 1 end
=======
function Currency:__new(options)
	self.worth = options and options.worth or 1
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Currency
