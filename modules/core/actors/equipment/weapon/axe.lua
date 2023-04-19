local Actor = require("core.actor")
local Tiles = require("display.tiles")
local Vector2 = require("math.vector")
local Condition = require("core.condition")

local directions = {
<<<<<<< HEAD
   [Vector2.UP] = { Vector2.UP_RIGHT, Vector2.UP_LEFT },
   [Vector2.RIGHT] = { Vector2.UP_RIGHT, Vector2.DOWN_RIGHT },
   [Vector2.DOWN] = { Vector2.DOWN_RIGHT, Vector2.DOWN_LEFT },
   [Vector2.LEFT] = { Vector2.UP_LEFT, Vector2.DOWN_LEFT },
   [Vector2.UP_RIGHT] = { Vector2.UP, Vector2.RIGHT },
   [Vector2.UP_LEFT] = { Vector2.LEFT, Vector2.UP },
   [Vector2.DOWN_RIGHT] = { Vector2.RIGHT, Vector2.DOWN },
   [Vector2.DOWN_LEFT] = { Vector2.DOWN, Vector2.LEFT },
}

local function getDirections(vec)
   for k, v in pairs(directions) do
      if vec == k then return v end
   end
=======
	[Vector2.UP] = { Vector2.UP_RIGHT, Vector2.UP_LEFT },
	[Vector2.RIGHT] = { Vector2.UP_RIGHT, Vector2.DOWN_RIGHT },
	[Vector2.DOWN] = { Vector2.DOWN_RIGHT, Vector2.DOWN_LEFT },
	[Vector2.LEFT] = { Vector2.UP_LEFT, Vector2.DOWN_LEFT },
	[Vector2.UP_RIGHT] = { Vector2.UP, Vector2.RIGHT },
	[Vector2.UP_LEFT] = { Vector2.LEFT, Vector2.UP },
	[Vector2.DOWN_RIGHT] = { Vector2.RIGHT, Vector2.DOWN },
	[Vector2.DOWN_LEFT] = { Vector2.DOWN, Vector2.LEFT },
}

local function getDirections(vec)
	for k, v in pairs(directions) do
		if vec == k then
			return v
		end
	end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

local Swing = conditions.Onattack:extend()

function Swing:onAttack(level, attacker, defender)
<<<<<<< HEAD
   local directionsToHit = getDirections(defender.position - attacker.position)

   level:suppressEffects()
   for i = 1, 2 do
      local target = directionsToHit[i] + attacker.position
      local actorsToHit = level:getActorsAt(target.x, target.y)

      for j = 1, #actorsToHit do
         level:performAction(attacker:getAction(actions.Attack)(attacker, actorsToHit[j]))
      end
   end
   level:resumeEffects()
=======
	local directionsToHit = getDirections(defender.position - attacker.position)

	level:suppressEffects()
	for i = 1, 2 do
		local target = directionsToHit[i] + attacker.position
		local actorsToHit = level:getActorsAt(target.x, target.y)

		for j = 1, #actorsToHit do
			level:performAction(attacker:getAction(actions.Attack)(attacker, actorsToHit[j]))
		end
	end
	level:resumeEffects()
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

local Axe = Actor:extend()
Axe.char = Tiles["axe"]
Axe.name = "Axe"

Axe.components = {
<<<<<<< HEAD
   components.Item(),
   components.Weapon {
      stat = "ATK",
      name = "Axe",
      dice = "2d6",
      time = 150,
      effects = {
         Swing,
      },
   },
   components.Cost {},
=======
	components.Item(),
	components.Weapon({
		stat = "ATK",
		name = "Axe",
		dice = "2d6",
		time = 150,
		effects = {
			Swing,
		},
	}),
	components.Cost({}),
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
}

return Axe
