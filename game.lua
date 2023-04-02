local Object = require 'object'

local Game = Object:extend()

function Game:__new(...)
end

-- This exports the game objects found in the listed modules to the global namespace.
-- ex: actors.Player, components.Sight, etc.
function Game:loadItems()
end