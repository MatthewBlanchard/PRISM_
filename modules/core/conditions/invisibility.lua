local Condition = require("core.condition")

local Invisible = Condition:extend()
Invisible.name = "invisible"

<<<<<<< HEAD
function Invisible:__new() Condition.__new(self) end

function Invisible:isVisible() return false end
=======
function Invisible:__new()
	Condition.__new(self)
end

function Invisible:isVisible()
	return false
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Invisible
