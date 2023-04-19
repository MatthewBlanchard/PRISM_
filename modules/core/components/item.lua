local Component = require("core.component")

local Item = Component:extend()
Item.name = "Item"

<<<<<<< HEAD
function Item:__new(options) self.stackable = options and options.stackable or false end
=======
function Item:__new(options)
	self.stackable = options and options.stackable or false
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Item
