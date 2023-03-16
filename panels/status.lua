local Panel = require "panel"
local Colors = require "colors"

local StatusPanel = Panel:extend()

function StatusPanel:__new(display, parent)
  local x, y = game.display:getWidth() - 20, game.display:getHeight()
  Panel.__new(self, display, parent, x, 1, 21, 9)
end

function StatusPanel:draw()
  self:clear()
  self:drawBorders()
  local hpPercentage = game.curActor.HP / game.curActor:getMaxHP()
  local barLength = math.floor(19 * hpPercentage)
  local hpString = tostring(game.curActor.HP) .. "/" .. tostring(game.curActor:getMaxHP()) .. " HP"

  for i = 1, 19 do
    local c = string.sub(hpString, i, i)
    c = c == "" and " " or c

    local bg = barLength >= i and { .3, .3, .3, 1 } or { .2, .1, .1, 1 }
    self:write(c, i + 1, 2, { .75, .75, .75, 1 }, bg)
  end

  local attacker = game.curActor:getComponent(components.Attacker)
  if attacker then
    local statbonus = game.curActor:getStatBonus(attacker.wielded.stat)
    local wielded_name_truncated = string.sub(attacker.wielded.name, 1, 21-7)

    if wielded_name_truncated ~= attacker.wielded.name then
      wielded_name_truncated = wielded_name_truncated .. "..."
    end

    self:write(wielded_name_truncated, 2, 3, { .75, .75, .75, 1 })
    self:write("AC: " .. game.curActor:getAC(), 2, 4, { .75, .75, .75, 1 })
    self:write("ATK: " .. game.curActor:getStat("ATK"), 2, 5, { .75, .75, .75, 1 })
    self:write("MGK: " .. game.curActor:getStat("MGK"), 2, 6, { .75, .75, .75, 1 })
    local wizard_component = game.curActor:getComponent(components.Wizard)
    if wizard_component then
      self:write("Blast: " .. wizard_component.charges, 2, 7, {.75, .75, .75, 1})
    end
    local rogue_component = game.curActor:getComponent(components.Rogue)
    if rogue_component then
      self:write("Invisibility: " .. rogue_component.charges, 2, 7, {.75, .75, .75, 1})
    end
    local fighter_component = game.curActor:getComponent(components.Fighter)
    if fighter_component then
      self:write("Second Wind: " .. fighter_component.charges, 2, 7, {.75, .75, .75, 1})
    end

    local i = 8
    local wallet_component = game.curActor:getComponent(components.Wallet)
    if wallet_component then
      for k, v in pairs(wallet_component.wallet) do
        self:write(k.name .. "s: ", 2, i, k.color)
        self:write(k.char, 2 + #k.name + 3, i, k.color)
        self:write(tostring(v), #k.name + 4, i, k.color)
        i = i + 1
      end
    end
  end
end

function StatusPanel:statsToString(actor)
  local ATK = actor:getStat("ATK")
  local MGK = actor:getStat("MGK")
  local PR = actor:getStat("PR")
  local MR = actor:getStat("MR")

  return self:statToString(ATK) .. " " .. self:statToString(MGK) .. " " ..
      self:statToString(PR) .. " " .. self:statToString(MR)
end

function StatusPanel:statToString(stat)
  local s = tostring(stat)

  if #s == 1 then return "  " .. s end
  if #s == 2 then return " " .. s end
  return s
end

return StatusPanel
