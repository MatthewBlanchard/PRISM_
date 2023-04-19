local Actor = require("core.actor")
local Tiles = require("display.tiles")

local Zap = actions.Zap:extend()
Zap.name = "zap"
Zap.targets = { targets.Item }

function Zap:perform(level)
<<<<<<< HEAD
   actions.Zap.perform(self, level)

   local zapper = self.owner
   level:removeActor(zapper)

   local spider = actors.Webweaver()
   spider.position = zapper.position:copy()

   local condition = conditions.Polymorph(zapper)
   condition:setDuration(1000)
   spider:applyCondition(condition)
   level:addActor(spider)
=======
	actions.Zap.perform(self, level)

	local zapper = self.owner
	level:removeActor(zapper)

	local spider = actors.Webweaver()
	spider.position = zapper.position:copy()

	local condition = conditions.Polymorph(zapper)
	condition:setDuration(1000)
	spider:applyCondition(condition)
	level:addActor(spider)
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

-- Actual item definition all the way down here
local WandOfLight = Actor:extend()
WandOfLight.name = "Wand of Polymorph"
WandOfLight.color = { 1, 0.753, 0.796, 1 }
WandOfLight.char = Tiles["wand_gnarly"]

WandOfLight.components = {
<<<<<<< HEAD
   components.Item { stackable = false },
   components.Usable(),
   components.Wand {
      maxCharges = 3,
      zap = Zap,
   },
=======
	components.Item({ stackable = false }),
	components.Usable(),
	components.Wand({
		maxCharges = 3,
		zap = Zap,
	}),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return WandOfLight
