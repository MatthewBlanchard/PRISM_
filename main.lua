-- require is not smart so we are going to wrap it to warn us if we include
-- a file using /s instead of .s
local _require = require
require = function(path)
  if path:find("/") and not path:find("rot") then
    print("WARNING: require(" .. path .. ") uses / instead of .")
  end

  if string.lower(path) ~= path and not path:find("rot") then
    print("WARNING: require(" .. path .. ") uses uppercase letters")
  end

  return _require(path)
end

-- TODO: Refactor this! We need a World object that holds all of the loaded actors, actions, etc. and the current level.
ROT = require 'lib.rot.rot'
MusicManager = require "musicmanager"
vector22 = require "vector"
Actor = require "actor"

require "lib.batteries":export()

systems = {}
conditions = {}
reactions = {}
actions = {}
components = {}
actors = {}
effects = require "effects"

love.graphics.setDefaultFilter("nearest", "nearest")
local function loadItems(directoryName, items, recurse)
  local info = {}

  for k, item in pairs(love.filesystem.getDirectoryItems(directoryName)) do
    local fileName = directoryName .. "/" .. item
    love.filesystem.getInfo(fileName, info)
    if info.type == "file" then
      fileName = string.gsub(fileName, ".lua", "")
      fileName = string.gsub(fileName, "/", ".")
      local name = string.gsub(item:sub(1, 1):upper() .. item:sub(2), ".lua", "")

      items[name] = require(fileName)
    elseif info.type == "directory" and recurse then
      loadItems(fileName, items, recurse)
    end
  end
end

targets = require "target"
loadItems("actions", actions, false)
loadItems("actions/reactions", reactions, true)
loadItems("components", components, true)
loadItems("conditions", conditions, true)
loadItems("actors", actors, true)
loadItems("systems", systems, true)
Loot = require "loot"

local Level = require "level"
local Interface = require "interface"
local Display = require "display.display"
local Start = require "panels.start"

for _, actor in ipairs(actors) do
  for i, component in ipairs(actor.components) do
    actor.component[i] = component:extend()
  end
end
------
-- Global

game = {}

local function createLevel()
  local map, populater = ROT.Map.Brogue(50, 50), require "populater" -- Brogue Gen
  --local map, populater = require "maps.new.level_gen"(), require "maps.new.populater" -- Dim Gen
  local level = Level(map, populater)
  level:addSystem(systems.Message())
  level:addSystem(systems.Inventory())
  level:addSystem(systems.Effects())
  level:addSystem(systems.Lighting())
  level:addSystem(systems.Sight())
  level:addSystem(systems.Equipment())
  level:addSystem(systems.Weapon())
  level:addSystem(systems.Lose_condition())
  return level
end

function love.load()
  min_dt = 1 / 30 --fps
  next_time = love.timer.getTime()

  local scale = 1
  local w, h = math.floor(81 / scale), math.floor(49 / scale)
  local w2, h2 = math.floor(81 / 2), math.floor(49 / 2)
  local display = Display:new(w, h, scale, nil, { 1, 1, 1, 0 }, nil, nil, true)
  local viewDisplay2x = Display:new(w2, h2, 2, nil, { .09, .09, .09 }, nil, nil, false)
  local viewDisplay1x = Display:new(w, h, 1, nil, { .09, .09, .09 }, nil, nil, false)

  game.music = MusicManager()
  game.display = display
  game.viewDisplay1x = viewDisplay1x
  game.viewDisplay2x = viewDisplay2x
  game.viewDisplay = viewDisplay2x
  game.Player = actors.Player()

  local interface = Interface(display)
  interface:push(Start(display, interface))

  game.level = createLevel()
  game.interface = interface

  local player = game.Player
  game.curActor = player

  local torch = actors.Torch()
  table.insert(player:getComponent(components.Inventory).inventory, torch)

  love.keyboard.setKeyRepeat(true)
end

function love.draw()
  if not game.display then return end
  game.viewDisplay:clear()
  game.display:clear()
  game.interface:draw(game.display)
  game.viewDisplay:draw()
  game.display:draw("UI")
end

local storedKeypress
local updateCoroutine
game.waiting = false
local skipAnimation = false
function love.update(dt)
  local effects = game.level:getSystem("Effects")

  game.music:update(dt)
  game.interface:update(dt, game.level)

  if not updateCoroutine then
    updateCoroutine = coroutine.create(game.level.run)
  end

  local awaitedAction = game.interface:getAction()
  
  -- we're waiting and there's no input so stop advancing
  if game.waiting and not awaitedAction then return end
  game.waiting = false

  -- don't advance game state while we're rendering effects please
  if effects and #effects.effects ~= 0 then
    return
  end

  local success, ret
  -- when we press a key during animations we want to skip them
  repeat
    success, ret = coroutine.resume(updateCoroutine, game.level, awaitedAction)
    if success == false then
      error(ret .. "\n" .. debug.traceback(updateCoroutine))
    end
  until not (ret == "effect" and skipAnimation)


  local coroutine_status = coroutine.status(updateCoroutine)
  if coroutine_status == "suspended" and ret.is and ret:is(Actor) then
    -- if level update returns a table we know we've got out guy so we set
    -- curActor to let the interface know to unlock input
    assert(ret:is(Actor))
    game.curActor = ret
    game.waiting = true
    skipAnimation = false
    if storedKeypress then
      love.keypressed(storedKeypress[1], storedKeypress[2])
    end

    effects.effects = {}
  elseif coroutine_status == "dead" then
    -- The coroutine has not stopped running and returned "descend".
    -- It's time for us to load a new level.
    if ret == "descend" then
      game.level = createLevel()
      updateCoroutine = coroutine.create(game.level.run)
    else
      love.event.quit( 0 )
    end
  end
end

function love.keypressed(key, scancode)
  local effects = game.level:getSystem("Effects")

  if not game.waiting then
    effects.effects = {}
    skipAnimation = true
    storedKeypress = { key, scancode }
    return
  end

  storedKeypress = nil
  -- if there is no current actor than we freeze input
  game.interface:handleKeyPress(key, scancode)
end
