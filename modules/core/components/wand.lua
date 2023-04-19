local Component = require("core.component")

local Wand = Component:extend()
Wand.name = "Wand"

Wand.requirements = {
<<<<<<< HEAD
   components.Usable,
}

function Wand:__new(options)
   assert(options.zap:is(actions.Zap))
   self.maxCharges = options.maxCharges
   self.charges = options.charges or self.maxCharges
   self.zap = options.zap
end

function Wand:initialize(actor)
   actor.charges = self.charges
   actor.maxCharges = self.maxCharges
   actor.modifyCharges = self.modifyCharges
   actor.zap = self.zap

   actor:addUseAction(actor.zap)
end

function Wand:modifyCharges(n)
   self.charges = math.min(math.max(self.charges + n, 0), self.maxCharges)

   local hasZap = self:getUseAction(actions.Zap)
   if self.charges == 0 and hasZap then
      self.zap = hasZap
      self:removeUseAction(hasZap)
   elseif self.charges > 0 and not hasZap then
      self:addUseAction(self.zap)
   end
=======
	components.Usable,
}

function Wand:__new(options)
	assert(options.zap:is(actions.Zap))
	self.maxCharges = options.maxCharges
	self.charges = options.charges or self.maxCharges
	self.zap = options.zap
end

function Wand:initialize(actor)
	actor.charges = self.charges
	actor.maxCharges = self.maxCharges
	actor.modifyCharges = self.modifyCharges
	actor.zap = self.zap

	actor:addUseAction(actor.zap)
end

function Wand:modifyCharges(n)
	self.charges = math.min(math.max(self.charges + n, 0), self.maxCharges)

	local hasZap = self:getUseAction(actions.Zap)
	if self.charges == 0 and hasZap then
		self.zap = hasZap
		self:removeUseAction(hasZap)
	elseif self.charges > 0 and not hasZap then
		self:addUseAction(self.zap)
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Wand
