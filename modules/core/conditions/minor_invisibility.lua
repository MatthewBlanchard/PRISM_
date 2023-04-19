local Condition = require("core.condition")
local Invisibility = require("modules.core.conditions.invisibility")
local Tiles = require("display.tiles")

local MinorInvisibility = Invisibility:extend()
MinorInvisibility.name = "MinorInvisibility"

<<<<<<< HEAD
MinorInvisibility:onAction(
   actions.Attack,
   function(self, level, actor, action) action:addDiceBonus "1d6" end
)

MinorInvisibility:afterAction(actions.Attack, function(self, level, actor, action)
   if action.hit then self:breakInvisibility(level, actor) end
=======
MinorInvisibility:onAction(actions.Attack, function(self, level, actor, action)
	action:addDiceBonus("1d6")
end)

MinorInvisibility:afterAction(actions.Attack, function(self, level, actor, action)
	if action.hit then
		self:breakInvisibility(level, actor)
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end)

MinorInvisibility:onAction(actions.Zap, MinorInvisibility.breakInvisibility)

<<<<<<< HEAD
function MinorInvisibility:breakInvisibility(level, actor) actor:removeCondition(self) end

function MinorInvisibility:onApply()
   self.storedChar = self.owner.char
   self.owner.char = Tiles["inivs_player"]
end

function MinorInvisibility:onRemove() self.owner.char = self.storedChar end
=======
function MinorInvisibility:breakInvisibility(level, actor)
	actor:removeCondition(self)
end

function MinorInvisibility:onApply()
	self.storedChar = self.owner.char
	self.owner.char = Tiles["inivs_player"]
end

function MinorInvisibility:onRemove()
	self.owner.char = self.storedChar
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return MinorInvisibility
