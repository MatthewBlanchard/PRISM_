local Actor = require("core.actor")
local Tiles = require("display.tiles")
local OnCrit = require("modules.core.conditions.oncrit")
local LightColor = require("structures.lighting.lightcolor")

local WandSword = Actor:extend()
WandSword.char = Tiles["shortsword"]
WandSword.name = "Sword of Wand Recovery"
WandSword.color = { 0.627, 0.125, 0.941, 1 }

--need to add an interface here to allow you to select a single wand to recharge
local WandRecovery = OnCrit:extend()
function WandRecovery:OnCrit(level, actor)
<<<<<<< HEAD
   local inventory_component = actor:getComponent(components.Inventory)
   for _, item in ipairs(inventory_component:getItems()) do
      if item:hasComponent(components.Wand) then item:modifyCharges(1) end
   end
end

WandSword.components = {
   components.Item(),
   components.Weapon {
      stat = "MGK",
      name = "WandSword",
      dice = "1d4",
      bonus = 1,
      time = 100,
      effects = { WandRecovery() },
   },
   components.Light {
      color = LightColor(20, 4, 28),
      effect = { components.Light.effects.pulse, { 0.5, 0.2 } },
   },
   components.Cost { rarity = "rare" },
=======
	local inventory_component = actor:getComponent(components.Inventory)
	for _, item in ipairs(inventory_component:getItems()) do
		if item:hasComponent(components.Wand) then
			item:modifyCharges(1)
		end
	end
end

WandSword.components = {
	components.Item(),
	components.Weapon({
		stat = "MGK",
		name = "WandSword",
		dice = "1d4",
		bonus = 1,
		time = 100,
		effects = { WandRecovery() },
	}),
	components.Light({
		color = LightColor(20, 4, 28),
		effect = { components.Light.effects.pulse, { 0.5, 0.2 } },
	}),
	components.Cost({ rarity = "rare" }),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return WandSword
