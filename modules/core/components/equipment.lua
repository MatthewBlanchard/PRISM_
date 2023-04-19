local Component = require("core.component")
local Condition = require("core.condition")

local Equipment = Component:extend()
Equipment.name = "Equipment"

Equipment.requirements = { components.Item }

function Equipment:__new(options)
<<<<<<< HEAD
   self.slot = options.slot
   self.effects = options.effects or {}
end

function Equipment:initialize(actor)
   local item_component = actor:getComponent(components.Item)
   if item_component then item_component.stackable = false end
=======
	self.slot = options.slot
	self.effects = options.effects or {}
end

function Equipment:initialize(actor)
	local item_component = actor:getComponent(components.Item)
	if item_component then
		item_component.stackable = false
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Equipment
