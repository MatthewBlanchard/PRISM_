local Actor = require("core.actor")
local Action = require("core.action")
local Condition = require("core.condition")
local Tiles = require("display.tiles")
local LightColor = require("structures.lighting.lightcolor")
-- The light actor
-- Not super reusable so we define the light actor here.
local Orb = Actor:extend()
Orb.char = Tiles["pointy_poof"]
Orb.name = "Orb of light"

Orb.components = {
	components.Light({
		color = LightColor(26, 26, 30),
	}),
	components.Lifetime({ duration = 3000 }),
}

-- Let's get our zap target going.
local ZapTarget = targets.Point:extend()
ZapTarget.name = "ZapTarget"
ZapTarget.range = 6

-- Define our custom zap
local Zap = actions.Zap:extend()
Zap.name = "zap"
Zap.targets = { targets.Item, ZapTarget }
Zap.aoeRange = 3

function Zap:perform(level)
	actions.Zap.perform(self, level)

	local effects_system = level:getSystem("Effects")

	local target = self.targetActors[2]
	local orb = Orb()
	orb.position = target
	level:addActor(orb)

	local fov, actors = level:getAOE("fov", target, self.aoeRange)

	for _, actor in ipairs(actors) do
		if actor:getComponent(components.Stats) then
			if actor:hasComponent(components.Stats) then
				effects_system:addEffect(
					level,
					effects.CharacterDynamic(actor, 0, -1, Tiles["bubble_stun"], { 1, 1, 1 }, 0.5)
				)
				level.scheduler:addTime(actor, 600)
			end
		end
	end
end

-- Actual item definition all the way down here
local WandOfLight = Actor:extend()
WandOfLight.name = "Wand of Light"
WandOfLight.color = { 0.7, 0.7, 0.7, 1 }
WandOfLight.char = Tiles["wand_pointy"]

WandOfLight.components = {
	components.Item({ stackable = false }),
	components.Usable(),
	components.Wand({
		maxCharges = 5,
		zap = Zap,
	}),
	components.Cost({ rarity = "common" }),
}

return WandOfLight
