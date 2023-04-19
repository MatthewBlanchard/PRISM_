local Actor = require("core.actor")
local Action = require("core.action")
local Tiles = require("display.tiles")

local Read = actions.Read:extend()
Read.name = "read"
Read.targets = { targets.Item }

function Read:perform(level)
<<<<<<< HEAD
   actions.Read.perform(self, level)

   local sight_component = self.owner:getComponent(components.Sight)
   if not sight_component then return end

   for x = 1, level.width do
      for y = 1, level.height do
         sight_component.explored:set(x, y, level:getCell(x, y))
      end
   end
=======
	actions.Read.perform(self, level)

	local sight_component = self.owner:getComponent(components.Sight)
	if not sight_component then
		return
	end

	for x = 1, level.width do
		for y = 1, level.height do
			sight_component.explored:set(x, y, level:getCell(x, y))
		end
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

local Scroll = Actor:extend()
Scroll.name = "Scroll of Mapping"
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
