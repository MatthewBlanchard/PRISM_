--- The 'Reaction' class represents an action that's performed in response to another action.
-- It is a subclass of 'Action' and sets a flag indicating that it is a reaction.
-- @classmod Reaction

local Action = require "core.action"

local Reaction = Action:extend()

--- Flag indicating that this Action is a Reaction.
-- @tfield boolean reaction
Reaction.reaction = true

return Reaction