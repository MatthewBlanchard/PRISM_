local Action = require("core.action")

local ChooseClass = Action:extend()
ChooseClass.time = 0
ChooseClass.silent = true

function ChooseClass:__new(owner, class)
<<<<<<< HEAD
   Action.__new(self, owner)
   self.class = class
end

function ChooseClass:perform(level)
   local actor = self.owner

   level:addComponent(actor, self.class())
=======
	Action.__new(self, owner)
	self.class = class
end

function ChooseClass:perform(level)
	local actor = self.owner

	level:addComponent(actor, self.class())
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return ChooseClass
