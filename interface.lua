local Object = require "object"
local Vector2 = require "math.vector"
local Tiles = require "display.tiles"

local Panel = require "panels.panel"
local Level = require "panels.level"
local Inventory = require "panels.inventory"
local Status = require "panels.status"
local Message = require "panels.message"
local Selector = require "panels.selector"
local SparseGrid = require "structures.sparsegrid"

local Interface = Panel()

function Interface:__new(display)
   Panel.__new(self, display)
   self.levelPanel = Level(display)
   self.statusPanel = Status(display)
   self.messagePanel = Message(display)
   self.defaultBackgroundColor = self.display.defaultBackgroundColor
   self.stack = {}
   self.t = 0

   self.waitTime = nil

   self.fov = {}
end

function Interface:update(dt)
   self.levelPanel:update(dt)

   self.t = (self.t + dt)
   self.dt = dt

   if self.waitTime then
      self.waitTime = self.waitTime - dt
      if self.waitTime <= 0 then self.waitTime = nil end
   end

   self.messagePanel:update(dt)

   self.fov = SparseGrid()
   self.seenActors = {}

   for actor, sight_component in game.level:eachActor(components.Sight) do
      if game.level:getActorController(actor) then
         for _, actor in pairs(sight_component.seenActors) do
            local found = false
            for _, other in ipairs(self.seenActors) do
               if actor == other then found = true end
            end

            if not found then table.insert(self.seenActors, actor) end
         end

         for x, y, cell in sight_component.fov:each() do
            self.fov:set(x, y, cell)
         end
      end
   end

   if not self:peek() then return end
   self:peek():update(dt)
end

local function value(c) return (c[1] + c[2] + c[3]) / 3 end

local function clerp(start, finish, t)
   local c = {}
   for i = 1, 4 do
      if not start[i] or not finish[i] then break end
      c[i] = (1 - t) * start[i] + t * finish[i]
   end

   return c
end

local function shouldDrawExplored(explored, x, y)
   local cell = explored:get(x, y)
   if not cell then return false end
   if cell.passable then return true end

   for i = -1, 1 do
      for j = -1, 1 do
         local neighbor = explored:get(x + i, y + j)
         if neighbor and neighbor.passable then return true end
      end
   end
end

local ambientColor = { 0.175, 0.175, 0.175 }
function Interface:draw()
   self.levelPanel:draw()

   self.statusPanel:draw()
   self.messagePanel:draw()

   self.display:draw()

   if not self:peek() then return end
   self:peek():draw()
end

Interface.movementTranslation = {
   -- cardinal
   w = Vector2(0, -1),
   s = Vector2(0, 1),
   a = Vector2(-1, 0),
   d = Vector2(1, 0),

   -- diagonal disable these and change the target in the Move action
   -- if you want to disable diagonal movement
   q = Vector2(-1, -1),
   e = Vector2(1, -1),
   z = Vector2(-1, 1),
   c = Vector2(1, 1),

   x = "wait",
}

Interface.keybinds = {
   ["tab"] = "inventory",
   p = "pickup",
   l = "log",
   m = "map",
   ["space"] = "classAbility",
}

function Interface:clearEffects()
   local effect_system = game.level:getSystem "Effects"
   effect_system.effects = {}
end

function Interface:handleKeyPress(keypress)
   if self:peek() then
      self:peek():handleKeyPress(keypress)
      return nil
   end

   if game.curActor:hasComponent(components.Inventory) then
      if self.keybinds[keypress] == "inventory" then self:push(Inventory(self.display, self)) end

      if self.keybinds[keypress] == "log" then self.messagePanel:toggleHeight() end

      if self.keybinds[keypress] == "pickup" then
         local sight_component = game.curActor:getComponent(components.Sight)
         local item
         for k, i in pairs(sight_component.seenActors) do
            if actions.Pickup:validateTarget(1, game.curActor, i) then
               return self:setAction(game.curActor:getAction(actions.Pickup)(game.curActor, { i }))
            end
         end
      end

      if self.keybinds[keypress] == "map" then
         self.levelPanel.transform.sx = self.levelPanel.transform.sx == 1 and 2 or 1
         self.levelPanel.transform.sy = self.levelPanel.transform.sx

         self.levelPanel.display:updateCanvasTransform(self.levelPanel.transform)
      end
   end

   local progression_component = game.curActor:getComponent(components.Progression)
   if
      self.keybinds[keypress] == "classAbility"
      and progression_component
      and progression_component.classAbility
   then
      local classAbility = progression_component.classAbility
      if classAbility:getNumTargets() == 0 then
         game.interface:reset()
         game.interface:setAction(classAbility(game.curActor))
      else
         game.interface:push(Selector(self.display, self, classAbility))
      end
   end

   -- we're dealing with a directional command here
   if self.movementTranslation[keypress] and game.curActor:hasComponent(components.Move) then
      if self.movementTranslation[keypress] == "wait" then
         return self:setAction(game.curActor:getAction(actions.Wait)(game.curActor))
      end

      local targetPosition = game.curActor.position + self.movementTranslation[keypress]

      local sight_component = game.curActor:getComponent(components.Sight)
      local enemy

      for k, actor in pairs(sight_component.seenActors) do
         for vec in game.level:eachActorTile(actor) do
            if vec == targetPosition then enemy = actor end
         end
      end

      if enemy then
         local enemy_passable = enemy:hasComponent(components.Collideable)
         if
            enemy:hasComponent(components.Usable)
            and enemy.defaultUseAction
            and enemy.defaultUseAction:validateTarget(1, game.curActor, enemy)
            and not love.keyboard.isDown "lctrl"
         then
            if enemy_passable or love.keyboard.isDown "lshift" then
               return self:setAction(enemy.defaultUseAction(game.curActor, { enemy }))
            end
         end

         if
            game.curActor:hasComponent(components.Attacker) and enemy:hasComponent(components.Stats)
         then
            if enemy_passable or love.keyboard.isDown "lctrl" then
               return self:setAction(game.curActor:getAction(actions.Attack)(game.curActor, enemy))
            end
         end
      end

      return self:setAction(
         game.curActor:getAction(actions.Move)(game.curActor, self.movementTranslation[keypress])
      )
   end
end

function Interface:setAction(action) self.action = action end

function Interface:getAction()
   local action = self.action
   self.action = nil
   return action
end

function Interface:push(panel) table.insert(self.stack, panel) end

function Interface:pop()
   local panel = self.stack[#self.stack]
   self.stack[#self.stack] = nil
   return panel
end

function Interface:peek() return self.stack[#self.stack] end

function Interface:reset()
   for i = 1, #self.stack do
      self.stack[i] = nil
   end
end

return Interface
