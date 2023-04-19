local Actor = require("core.actor")
local Action = require("core.action")
local Tiles = require("display.tiles")
local Condition = require("core.condition")

local Scrying = Condition:extend()
Scrying.name = "Scrying"
Scrying.damage = 1

<<<<<<< HEAD
Scrying:onScry(function(self, level, actor) return { level:getActorByType(actors.Prism) } end)
=======
Scrying:onScry(function(self, level, actor)
	return { level:getActorByType(actors.Prism) }
end)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

local Read = actions.Read:extend()
Read.name = "read"
Read.targets = { targets.Item }

function Read:perform(level)
<<<<<<< HEAD
   actions.Read.perform(self, level)
   self.owner:applyCondition(Scrying())
=======
	actions.Read.perform(self, level)
	self.owner:applyCondition(Scrying())
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

local Scroll = Actor:extend()
Scroll.name = "Scroll of Enlightenment"
Scroll.color = { 0.8, 0.8, 0.8, 1 }
Scroll.char = Tiles["scroll"]

Scroll.components = {
<<<<<<< HEAD
   components.Item(),
   components.Usable(),
   components.Readable { read = Read },
   components.Cost(),
=======
	components.Item(),
	components.Usable(),
	components.Readable({ read = Read }),
	components.Cost(),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return Scroll
