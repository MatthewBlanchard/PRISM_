local System = require("core.system")

--- The Effects system handles messaging the interface about events. This is sort of a kludge.
-- @type Effects
local Effects = System:extend()
Effects.name = "Effects"

<<<<<<< HEAD
function Effects:__new() self.effects = {} end

function Effects:afterAction(level, actor, action)
   if self.effectAfterAction then
      self:addEffect(level, self.effectAfterAction)
      self.effectAfterAction = nil
   end
end

function Effects:addEffect(level, effect)
   -- we push the effect onto the effects stack and then the interface
   -- resolves these
   table.insert(self.effects, effect)

   if self.suppressEffect then return end
   level:yield "effect"
end

function Effects:addEffectAfterAction(effect) self.effectAfterAction = effect end
=======
function Effects:__new()
	self.effects = {}
end

function Effects:afterAction(level, actor, action)
	if self.effectAfterAction then
		self:addEffect(level, self.effectAfterAction)
		self.effectAfterAction = nil
	end
end

function Effects:addEffect(level, effect)
	-- we push the effect onto the effects stack and then the interface
	-- resolves these
	table.insert(self.effects, effect)

	if self.suppressEffect then
		return
	end
	level:yield("effect")
end

function Effects:addEffectAfterAction(effect)
	self.effectAfterAction = effect
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

-- these functions are used to suppress effects from being sent to the interface
-- a good example of this is a fireball where we want all the damage effects to
-- play at the same time
<<<<<<< HEAD
function Effects:suppressEffects() self.suppressEffect = true end
=======
function Effects:suppressEffects()
	self.suppressEffect = true
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

-- Once this is called all of the effects that have been suppressed will be sent
-- to the interface
function Effects:resumeEffects(level)
<<<<<<< HEAD
   self.suppressEffect = false
   level:yield "effect"
=======
	self.suppressEffect = false
	level:yield("effect")
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Effects
