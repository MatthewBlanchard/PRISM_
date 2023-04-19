local Actor = require "core.actor"
local Tiles = require "display.tiles"

local Cube = Actor:extend()
Cube.name = "Cube"
Cube.char = Tiles["player"]
Cube.color = { 0.5, 0.5, 0.8 }

Cube.components = {
   components.Collideable_bfs(9),
   components.Move { speed = 150 },
   components.Sight { range = 5, fov = true, explored = false },
   components.Stats {
      ATK = 0,
      MGK = 0,
      PR = 0,
      MR = 0,
      maxHP = 10,
      AC = 0,
   },
   components.Aicontroller(),
}

local actUtil = components.Aicontroller
function Cube:act(level)
   local target = actUtil.closestSeenActorByFaction(self, "player")

   if target then return actUtil.moveToward(self, target) end

   return self:getAction(actions.Wait)(self)
end

return Cube
