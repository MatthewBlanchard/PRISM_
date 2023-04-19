local Object = require "object"

local GameState = Object:extend()

function GameState:load()
   -- implement your own load logic here
end

function GameState:unload()
   -- implement your own unload logic here
end

function GameState:update(dt)
   -- implement your own update logic here
end

function GameState:draw()
   -- implement your own draw logic here
end

function GameState:keypressed(key, scancode)
   -- handle keypresses here
end

function GameState:getManager() return self.manager end

return GameState
