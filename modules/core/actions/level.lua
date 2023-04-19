local Action = require("core.action")

local LevelUp = Action:extend()
LevelUp.time = 0
LevelUp.silent = true

function LevelUp:__new(owner, feat)
<<<<<<< HEAD
   Action.__new(self, owner)
   self.feat = feat
end

function LevelUp:perform(level)
   local actor = self.owner

   actor:applyCondition(self.feat())
=======
	Action.__new(self, owner)
	self.feat = feat
end

function LevelUp:perform(level)
	local actor = self.owner

	actor:applyCondition(self.feat())
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return LevelUp
