local Action = require("core.action")

local Wait = Action:extend()
Wait.name = "Wait"
Wait.silent = true

<<<<<<< HEAD
function Wait:__new(owner) Action.__new(self, owner, {}) end
=======
function Wait:__new(owner)
	Action.__new(self, owner, {})
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

function Wait:perform(level) end

return Wait
