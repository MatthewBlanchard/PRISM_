local Actor = require "actor"
local Action = require "action"
local Tiles = require "tiles"
local FeatsPanel = require "panels.feats"
local SwirlPanel = require "panels.swirl"
local ClassSelectPanel = require "panels.class_select"
local LightColor = require "lighting.lightcolor"

local Gaze = Action:extend()
Gaze.name = "gaze"
Gaze.targets = {targets.Item}
Gaze.silent = true
Gaze.time = 0

local feats = {
  conditions.Baffled_brute,
  conditions.Chemical_curiosity,
  conditions.Coupon_clipper,
  conditions.Critical_eye,
  conditions.Delver,
  conditions.Fast_hands,
  conditions.Good_lookin,
  conditions.Midfight_snack,
  conditions.Nutritious_magic,
  conditions.Quick_reader,
  conditions.Spell_slinger,
  conditions.Swift,
  conditions.Tough
}
function Gaze:perform(level)
  level:removeActor(self:getTarget(1))

  local message_system = level:getSystem("Message")
  if message_system then
    message_system:add(level, "You gaze into the prism. It shatters!", self.owner)
  end

  -- TODO: Better way to do this
  local progression_component = self.owner:getComponent(components.Progression)
  if progression_component.level == 0 then
    game.music:changeSong(game.music.ominousmusic, true)
    game.interface:push(SwirlPanel(game.interface.display, game.interface))
    game.interface:push(ClassSelectPanel(game.interface.display, game.interface))
  else
    local feat1 = table.remove(feats, love.math.random(1, #feats))
    local feat2 = table.remove(feats, love.math.random(1, #feats))
    local feat3 = table.remove(feats, love.math.random(1, #feats))

    game.music:changeSong(game.music.ominousmusic, true)
    game.interface:push(SwirlPanel(game.interface.display, game.interface))
    game.interface:push(FeatsPanel(game.interface.display, game.interface, {feat1, feat2, feat3}))
  end

  self.owner.maxHP = self.owner.maxHP + 5
  self.owner.HP = self.owner.HP + 5
  progression_component.level = progression_component.level + 1
end

local Prism = Actor:extend()
Prism.name = "Prism of Enlightenment"
Prism.color = {0.67, 0.78, 0.9, 1}
Prism.emissive = true
Prism.char = Tiles["prism"]

Prism.components = {
  components.Light{
    color = LightColor(16, 16, 26),
    effect = {components.Light.effects.pulse, {0.2, 0.4}},
    falloff = 0.2
  },
  components.Item(),
  components.Usable{Gaze}
}

return Prism
