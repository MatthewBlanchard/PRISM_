local Component = require("core.component")

local Lock = Component:extend()
Lock.name = "Lock"

<<<<<<< HEAD
function Lock:setKey(item) self.key = item end

function Lock:hasKey(actor)
   local inventory = actor:getComponent(components.Inventory)
   return self.key and inventory and inventory:hasItemType(self.key)
=======
function Lock:setKey(item)
	self.key = item
end

function Lock:hasKey(actor)
	local inventory = actor:getComponent(components.Inventory)
	return self.key and inventory and inventory:hasItemType(self.key)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Lock
