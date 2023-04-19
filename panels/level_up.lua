<<<<<<< HEAD
local Panel = require "panels.panel"
local Colors = require "math.colors"
local FeatsPanel = require "panels.feats"

local LevelUpPanel = Panel:extend()

function LevelUpPanel:__new(display, parent) Panel.__new(self, display, parent, 23, 15, 27, 17) end

function LevelUpPanel:draw()
   self:clear()
   self:drawBorders()
end

function LevelUpPanel:handleKeyPress(keypress)
   local feat = self.options[keypress]
   --[[
=======
local Panel = require("panels.panel")
local Colors = require("math.colors")
local FeatsPanel = require("panels.feats")

local LevelUpPanel = Panel:extend()

function LevelUpPanel:__new(display, parent)
	Panel.__new(self, display, parent, 23, 15, 27, 17)
end

function LevelUpPanel:draw()
	self:clear()
	self:drawBorders()
end

function LevelUpPanel:handleKeyPress(keypress)
	local feat = self.options[keypress]
	--[[
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
  if stat then
    local statLevel = game.curActor.levels[stat] + 1
    local feats = self.feats[stat][statLevel]

    game.interface:pop()

    if feats then
      game.interface:push(FeatsPanel(self.display, self.parent, stat, feats))
    else
      game.level:performAction(actions.Level(game.curActor, stat))
    end
  end
  ]]
<<<<<<< HEAD
   --
=======
	--
>>>>>>> fbe4a4adf3bf1fc96ecb985cb65c5a009faf5ebc
end

return LevelUpPanel
