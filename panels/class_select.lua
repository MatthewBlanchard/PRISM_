local Panel = require("panels.panel")
local SwirlPanel = require("panels.swirl")
local Colors = require("math.colors")

local ClassSelectPanel = Panel:extend()

function ClassSelectPanel:__new(display, parent)
	local halfx = display:getWidth() / 2 - 33 / 2
	local halfy = display:getHeight() / 2 - 27 / 2
	Panel.__new(self, display, parent, math.floor(halfx) + 1, math.floor(halfy), 33, 27)

	self.classes = {
		components.Fighter,
		components.Rogue,
		components.Wizard,
	}

	self.SwirlPanel = SwirlPanel(display, parent)
end

function ClassSelectPanel:update(dt)
	self.SwirlPanel:update(dt)
end

function ClassSelectPanel:draw()
	self.SwirlPanel:draw()

	self:darken(" ", nil, { 0.2, 0.2, 0.2, 0.7 })
	self:drawBorders()

	local msgLen = math.floor(string.len("Gaze upon uncomfortable truths!") / 2)
	self:write("Gaze upon terrible truths!", math.floor(self.w / 2) - msgLen + 1, 2)

	local descHeight = 0
	local extra = 0

	for k, class in pairs(self.classes) do
		self:writeFormatted({ Colors.YELLOW, k .. ") " .. class.name }, 2, k * 2 + 3 + extra + descHeight)
		self:writeText("%b{black}" .. class.description, 5, k * 2 + 4 + extra + descHeight, self.w - 5)
		descHeight = descHeight + math.ceil(#class.description / (self.w - 5))
		extra = extra + 1
	end
end

function ClassSelectPanel:handleKeyPress(keypress)
	local class = self.classes[tonumber(keypress)]
	if class then
		game.music:changeSong(game.music.mainmusic)
		game.interface:setAction(actions.Choose_class(game.curActor, class))
		game.interface:reset()
	end
end

return ClassSelectPanel
