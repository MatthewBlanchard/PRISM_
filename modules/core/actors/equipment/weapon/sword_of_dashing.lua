local Actor = require "core.actor"
local Tiles = require "display.tiles"
local Condition = require "core.condition"

local DashEffect = function(start, target)
   local vec = target - start
   local t = 0
   return function(dt, interface)
      local vertical = vec.x == 0
      local positive = vertical and vec.y > 0 or vec.x > 0

      for i = positive and 1 or -1, vertical and vec.y or vec.x, positive and 1 or -1 do
         local x = vertical and start.x or start.x + i
         local y = vertical and start.y + i or start.y
         interface:write_plain(Tiles["poof"], x, y)
      end
      t = t + dt
      if t > 0.2 then return true end
   end
end

local Dash = Condition:extend()
Dash:onAction(actions.Move, function(self, level, actor, action)
   local target
   local direction = action.direction
   local i = 1

   local actors = {}
   for i = 1, #level.actors do
      if
         level.actors[i]:hasComponent(components.Stats)
         and level.actors[i]:hasComponent(components.Aicontroller)
      then
         table.insert(actors, level.actors[i])
      end
   end

   while true do
      local pos = actor.position + (action.direction * i)
      i = i + 1
      if not level:getCellPassable(pos.x, pos.y) then
         for i, actor in ipairs(actors) do
            if actor.position == pos then
               target = actor
               break
            end
         end
         break
      end
   end

   if target then
      local old = actor.position
      local pos = actor.position + (action.direction * (i - 2))
      actor.position = pos
      level:performAction(actions.Attack(actor, { target }))
      level:addEffect(level, DashEffect(old, pos))
   end
end)

local Sword = Actor:extend()
Sword.char = Tiles["shortsword"]
Sword.name = "Sword of Dashing"

Sword.components = {
   components.Item(),
   components.Weapon {
      stat = "ATK",
      name = "Sword of Dashing",
      dice = "1d6",
      effects = { Dash() },
   },
   components.Cost { rarity = "common" },
}

return Sword
