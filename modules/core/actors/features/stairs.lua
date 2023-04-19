local Actor = require "core.actor"
local Action = require "core.action"
local Tiles = require "display.tiles"

local targetStair = targets.Actor:extend()

function targetStair:validate(owner, actor) return actor:is(actors.Stairs) end

local Exit = Action:extend()
Exit.name = "descend"
Exit.targets = { targetStair }

function Exit:perform(level) level.exit = true end

local Stairs = Actor:extend()

Stairs.char = Tiles["stairs"]
Stairs.name = "stairs"
Stairs.remembered = true

Stairs.components = {
	components.Collideable_box(),
	components.Usable({ Exit }, Exit),
}

return Stairs
