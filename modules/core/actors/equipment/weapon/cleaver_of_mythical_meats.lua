local Actor = require("core.actor")
local Tiles = require("display.tiles")

local meatOnKill = conditions.Onkill:extend()

function meatOnKill:onKill(level, killer, killed)
<<<<<<< HEAD
   if not killed:hasComponent(components.Aicontroller) then return end
   if love.math.random() > 0.66 then
      local steak = actors.Steak()
      steak.position.x, steak.position.y = killed.position.x, killed.position.y
      level:addActor(steak)
   end
=======
	if not killed:hasComponent(components.Aicontroller) then
		return
	end
	if love.math.random() > 0.66 then
		local steak = actors.Steak()
		steak.position.x, steak.position.y = killed.position.x, killed.position.y
		level:addActor(steak)
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

local CleaverMythical = Actor:extend()
CleaverMythical.char = Tiles["cleaver"]
CleaverMythical.name = "Cleaver of Meats"
CleaverMythical.description = "Reduce your opponents to delicious and mysterious meats!"

CleaverMythical.components = {
<<<<<<< HEAD
   components.Item(),
   components.Weapon {
      stat = "ATK",
      name = "Cleaver of Meats",
      dice = "1d6",
      bonus = 1,
      time = 100,
      effects = {
         meatOnKill,
      },
   },
   components.Cost { rarity = "rare" },
=======
	components.Item(),
	components.Weapon({
		stat = "ATK",
		name = "Cleaver of Meats",
		dice = "1d6",
		bonus = 1,
		time = 100,
		effects = {
			meatOnKill,
		},
	}),
	components.Cost({ rarity = "rare" }),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return CleaverMythical
