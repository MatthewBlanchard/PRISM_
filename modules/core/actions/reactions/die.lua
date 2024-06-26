local Reaction = require "core.reaction"

local Die = Reaction:extend()
Die.name = "die"
Die.messageIgnoreTarget = true

function Die:__new(owner, dealer, damage)
   Reaction.__new(self, owner, nil)
   self.dealer = dealer
   self.damage = damage
end

function Die:perform(level) level:removeActor(self.owner) end

return Die
