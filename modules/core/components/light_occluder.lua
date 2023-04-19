local Component = require "core.component"

local LightOccluder = Component:extend()
LightOccluder.name = "LightOccluder"

function LightOccluder:__new(occlusion) self.reduction = occlusion or 1 end

return LightOccluder
