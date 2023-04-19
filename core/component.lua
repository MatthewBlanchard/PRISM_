local Object = require("object")

local Component = Object:extend()
Component.requirements = {}

function Component:initialize() end

function Component:checkRequirements(actor)
<<<<<<< HEAD
   local foundreqs = {}

   for k, component in pairs(actor.components) do
      for k, req in pairs(self.requirements) do
         if component:is(req) then table.insert(foundreqs, component) end
      end
   end

   if #foundreqs == #self.requirements then return true end

   return false
=======
	local foundreqs = {}

	for k, component in pairs(actor.components) do
		for k, req in pairs(self.requirements) do
			if component:is(req) then
				table.insert(foundreqs, component)
			end
		end
	end

	if #foundreqs == #self.requirements then
		return true
	end

	return false
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Component
