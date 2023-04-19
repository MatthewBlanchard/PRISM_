local Reaction = require("core.reaction")

local Die = Reaction:extend()
Die.name = "die"
Die.messageIgnoreTarget = true

function Die:__new(owner, dealer, damage)
<<<<<<< HEAD
   Reaction.__new(self, owner, nil)
   self.dealer = dealer
   self.damage = damage
end

function Die:perform(level) level:removeActor(self.owner) end
=======
	Reaction.__new(self, owner, nil)
	self.dealer = dealer
	self.damage = damage
end

function Die:perform(level)
	level:removeActor(self.owner)
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Die
