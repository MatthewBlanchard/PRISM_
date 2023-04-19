local Actor = require("core.actor")
local Vector2 = require("math.vector")
local Tiles = require("display.tiles")

local Golem = Actor:extend()

Golem.char = Tiles["golem"]
Golem.name = "crystal golem"
Golem.color = { 0.4, 0.4, 0.8 }

Golem.components = {
<<<<<<< HEAD
   components.Collideable_box(),
   components.Sight { range = 5, fov = true, explored = false },
   components.Move { speed = 100 },
   components.Stats {
      ATK = 2,
      MGK = 0,
      PR = 1,
      MR = 2,
      maxHP = 12,
      AC = 5,
   },
   components.Aicontroller(),
}

function Golem:initialize()
   --self:applyCondition(conditions.Shield())
end

local actUtil = components.Aicontroller
function Golem:act(level) return actUtil.randomMove(level, self) end
=======
	components.Collideable_box(),
	components.Sight({ range = 5, fov = true, explored = false }),
	components.Move({ speed = 100 }),
	components.Stats({
		ATK = 2,
		MGK = 0,
		PR = 1,
		MR = 2,
		maxHP = 12,
		AC = 5,
	}),
	components.Aicontroller(),
}

function Golem:initialize()
	--self:applyCondition(conditions.Shield())
end

local actUtil = components.Aicontroller
function Golem:act(level)
	return actUtil.randomMove(level, self)
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

return Golem
