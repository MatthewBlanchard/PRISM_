local Component = require "core.component"

local Tripper = Component:extend()

Tripper.actions = {
    actions.Trip
}

return Tripper
