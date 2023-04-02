require "export_lib"

love.graphics.setDefaultFilter("nearest", "nearest")

local Game = require "game"

-- This accepts a list of modules to load. Each module should contain subfolders
-- full of game objects. The game object will load all of the game objects in the
-- modules and export them to the global namespace. TODO: In the future modules
-- should be able to define what other modules they depend on.

-- Modules can include the following subfolders:
-- actions, actors, cells, components, conditions, systems
game = Game("core")

local StateManager = require "gamestates.statemanager"
local LevelState = require "gamestates.levelstate"

local manager = StateManager()

function love.load()
    manager:push(LevelState(game:generateLevel(1)))
end

function love.draw()
    manager:draw()
end


function love.update(dt)
    manager:update(dt)
end

function love.keypressed(key, scancode)
    manager:keypressed(key, scancode)
end
