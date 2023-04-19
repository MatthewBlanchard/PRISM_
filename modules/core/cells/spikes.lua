local Cell = require("core.cell")
local Tiles = require("display.tiles")

local Spikes = Cell:extend()
Spikes.name = "Spikes"
Spikes.passable = true
Spikes.opaque = false
Spikes.tile = Tiles["spikes_1"]

function Spikes:onEnter(level, actor) -- called when an actor enters the cell
<<<<<<< HEAD
   local stats = actor:getComponent(components.Stats)
   if stats then
      local damage = 1
      local damage = actor:getReaction(reactions.Damage)(actor, {}, damage)
      level:performAction(damage)
   end
=======
	local stats = actor:getComponent(components.Stats)
	if stats then
		local damage = 1
		local damage = actor:getReaction(reactions.Damage)(actor, {}, damage)
		level:performAction(damage)
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return Spikes
