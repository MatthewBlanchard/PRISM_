local GameState = require "gamestates.gamestate"
local MapDebugger = require "panels.map_debugger"

local GameState = GameState:extend()

function GameState:load(level)
  local map = require "maps.new.tunnel_gen"(true)
  self.panel = MapDebugger(game.display, nil, map)
end

function GameState:draw()
  game.display:clear()
  self.panel:draw()
  game.display:draw("UI")
end

function GameState:keypressed(key, scancode)
  self.panel:handleKeyPress(key)
end

return GameState
