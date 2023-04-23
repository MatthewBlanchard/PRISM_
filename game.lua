local Object = require "object"
local Display = require "display.display"
local Level = require "core.level"

local Game = Object:extend()

-- We feed a list of modules into the game object. These modules can be found
-- in the modules directory. Each module should contain subfolders full of
-- game objects. The game object will load all of the game objects in the
-- modules and export them to the global namespace.
function Game:__new(...)
   self.modules = { ... }
   self:export()

   local scale = 1
   local w, h = math.floor(81 / scale), math.floor(49 / scale)
   local w2, h2 = math.floor(81 / 2), math.floor(49 / 2)
   local display = Display(w, h, scale, nil, { 1, 1, 1, 0 }, nil, nil, true)
   local viewDisplay2x = Display(w2, h2, 2, nil, { 0.09, 0.09, 0.09 }, nil, nil, false)
   local viewDisplay1x = Display(w, h, 1, nil, { 0.09, 0.09, 0.09 }, nil, nil, false)

   self.music = MusicManager()
   self.display = display
   self.viewDisplay1x = viewDisplay1x
   self.viewDisplay2x = viewDisplay2x
   self.viewDisplay = viewDisplay2x
   self.Player = actors.Player()
end

function Game:export()
   self:__initializeExports()
   for _, module in ipairs(self.modules) do
      self:__exportModule(module)
   end
end

function Game:generateLevel(depth)
   -- TODO: The module should be able to specify the level generator and populater
   -- to use. And which generators to use on which depth somehow.

   --local map, populater = ROT.Map.Brogue(50, 50), require "populater" -- Brogue Gen
   --local map, populater = require "maps.new.planar_gen"(), require "maps.new.populater" -- Dim Gen
   local map, populater = require "maps.new.tunnel_gen"(), require "maps.new.populater"
   local level = Level(map, populater)
   level:addSystem(systems.Message())
   level:addSystem(systems.Inventory())
   level:addSystem(systems.Effects())
   level:addSystem(systems.Lighting())
   level:addSystem(systems.Sight())
   level:addSystem(systems.Equipment())
   level:addSystem(systems.Weapon())
   level:addSystem(systems.Lose_condition())
   level:addSystem(systems.Projectile())
   level:addSystem(systems.Animate())
   return level
end

-- This exports the game objects found in the listed modules to the global namespace.
-- ex: actors.Player, components.Sight, etc.
function Game:__exportModule(name)
   self:__initializeExports()

   -- TODO: these should be moved to the modular loading system like the rest of the game
   -- objects
   effects = require "core.effects"
   -- TODO: Same as effects. This should be moved to the modular loading system.
   targets = require "core.target"

   local module_path = "modules/" .. name
   self:__loadItems(module_path .. "/actions", actions, false)
   self:__loadItems(module_path .. "/actions/reactions", reactions, true)
   self:__loadItems(module_path .. "/components", components, true)
   self:__loadItems(module_path .. "/conditions", conditions, true)
   self:__loadItems(module_path .. "/actors", actors, true)
   self:__loadItems(module_path .. "/cells", cells, true)
   self:__loadItems(module_path .. "/systems", systems, true)

   Loot = require "loot"
end

function Game:__loadItems(directoryName, items, recurse)
   local info = {}

   for k, item in pairs(love.filesystem.getDirectoryItems(directoryName)) do
      local fileName = directoryName .. "/" .. item
      love.filesystem.getInfo(fileName, info)
      if info.type == "file" then
         fileName = string.gsub(fileName, ".lua", "")
         fileName = string.gsub(fileName, "/", ".")
         local name = string.gsub(item:sub(1, 1):upper() .. item:sub(2), ".lua", "")

         if name == "Attack" then print(name, fileName) end
         if items[name] then error("Duplicate item name: " .. name) end

         items[name] = require(fileName)
      elseif info.type == "directory" and recurse then
         self:__loadItems(fileName, items, recurse)
      end
   end
end

function Game:__initializeExports()
   if systems then return end

   systems = {}
   conditions = {}
   reactions = {}
   actions = {}
   components = {}
   actors = {}
   cells = {}
end

return Game
