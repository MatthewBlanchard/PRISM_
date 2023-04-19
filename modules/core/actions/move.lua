local Action = require("core.action")

local Move = Action:extend()
Move.name = "move"
Move.silent = true
Move.targets = { targets.Point }

function Move:__new(owner, direction)
	Action.__new(self, owner, { direction })
end

function Move:perform(level)
	local direction = self:getTarget(1)

	if not direction or direction:length() == 0 then
		-- we've effectively taken a wait action
		-- this should lead to an error or warning in the future
		-- since we now have a wait action
		return
	end

	level:moveActorChecked(self.owner, direction)
end

return Move
