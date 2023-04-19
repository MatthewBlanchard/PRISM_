<<<<<<< HEAD
require "prelude"
=======
require("prelude")
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

love.graphics.setDefaultFilter("nearest", "nearest")
math.randomseed(os.time())
math.random()
math.random()
math.random()

love.audio.setVolume(0.2)

<<<<<<< HEAD
local Game = require "game"
=======
local Game = require("game")
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc

-- This accepts a list of modules to load. Each module should contain subfolders
-- full of game objects. The game object will load all of the game objects in the
-- modules and export them to the global namespace. TODO: In the future modules
-- should be able to define what other modules they depend on.

-- Modules can include the following subfolders:
-- actions, actors, cells, components, conditions, systems
<<<<<<< HEAD
game = Game "core"

local StateManager = require "gamestates.statemanager"
local LevelState = require "gamestates.levelstate"
local MapDebuggerState = require "gamestates.mapdebuggerstate"

local manager = StateManager()

function love.load() manager:push(LevelState(game:generateLevel(1), 1)) end

function love.draw()
   manager:draw()
   local stats = love.graphics.getStats()

   love.graphics.print("Draw Calls:" .. stats.drawcalls, 10, 30)
end

function love.update(dt) manager:update(dt) end

function love.keypressed(key, scancode) manager:keypressed(key, scancode) end
=======
game = Game("core")

local StateManager = require("gamestates.statemanager")
local LevelState = require("gamestates.levelstate")
local MapDebuggerState = require("gamestates.mapdebuggerstate")

local manager = StateManager()

function love.load()
	manager:push(LevelState(game:generateLevel(1), 1))
end

function love.draw()
	manager:draw()
	local stats = love.graphics.getStats()

	love.graphics.print("Draw Calls:" .. stats.drawcalls, 10, 30)
end

function love.update(dt)
	manager:update(dt)
end

function love.keypressed(key, scancode)
	manager:keypressed(key, scancode)
end
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
