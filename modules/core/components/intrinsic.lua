local Component = require("core.component")
local Action = require("core.action")

local IntrinsicAction = Component:extend()
IntrinsicAction.name = "IntrinsicAction"

IntrinsicAction.requirements = {
<<<<<<< HEAD
   components.Aicontroller,
}

function IntrinsicAction:__new(options)
   assert(options.action:is(Action))
   self.action = options.action
end

function IntrinsicAction:initialize(actor) actor:addAction(self.action) end
=======
	components.Aicontroller,
}

function IntrinsicAction:__new(options)
	assert(options.action:is(Action))
	self.action = options.action
end

function IntrinsicAction:initialize(actor)
	actor:addAction(self.action)
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return IntrinsicAction
