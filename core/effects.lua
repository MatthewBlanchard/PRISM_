local Tiles = require "display.tiles"
local Color = require "math.color"
local Bresenham = require "math.bresenham"

local effects = {}

effects.HealEffect = function(actor, heal)
  local t = 0
  local lastflip = 9
  return function(dt, interface)
    t = t + dt

    local color = { .1, 1, .1, 1 }
    interface:effectWriteOffset(actor.char, actor.position.x, actor.position.y, color)
    interface:effectWriteOffset(tostring(heal), actor.position.x + 1, actor.position.y, color)
    if t > 0.4 then return true end
  end
end

effects.PoisonEffect = function(actor, damage)
  local t = 0
  return function(dt, interface)
    t = t + dt

    local color = { .1, .7, .1, 1 }
    interface:effectWriteOffset(Tiles["pointy_poof"], actor.position.x, actor.position.y, color)
    interface:effectWriteOffset(tostring(damage), actor.position.x + 1, actor.position.y, color)
    if t > 0.2 then return true end
  end
end

effects.OpenEffect = function(actor, totalTime)
  local t = 0
  local lastflip = 9
  return function(dt, interface)
    t = t + dt

    local color = { 1, 1, .1, 1 }
    if t < .5 then
      local c = Color.mul(color, t / 0.5)
      interface:effectWriteOffset(Tiles["pointy_poof"], actor.position.x, actor.position.y, c)
    elseif t < .8 then
      interface:effectWriteOffset(Tiles["chest_open"], actor.position.x, actor.position.y, actor.color)
    else
      return true
    end
  end
end

effects.tryMoveDebug = function(actor, cells)
  local t = 0
  local lastflip = 9
  return function(dt, interface)
    t = t + dt

    for _, cell in ipairs(cells) do
      interface:effectWriteOffset(Tiles["pointy_poof"], cell.x, cell.y, { 1, 1, 1, 1 })
    end
    
    if t > 1 then return true end
  end
end

effects.CritEffect = function(actor, totalTime)
  local t = 0
  local lastflip = 9
  return function(dt, interface)
    t = t + dt

    local color = { 1, 1, .1, 1 }
    if t < .5 then
      local c = Color.mul(color, t / 0.5)
      interface:effectWriteOffset(actor.char, actor.position.x, actor.position.y, c)
    else
      return true
    end
  end
end

effects.DamageEffect = function(source, actor, dmg, hit)
  local position = actor.position
  local t = 0
  local char = actor.char

  return function(dt, interface)
    local color
    if hit == false then
      color = { .6, .6, .6, 1 }
    else
      color = { 1, .1, .1, 1 }
    end

    local dmgstring = tostring(dmg)
    local dmglen = string.len(dmgstring)

    for vec in game.level:eachActorTile(actor) do
      interface:effectWriteOffset(char, vec.x, vec.y, color)
    end

    if hit then
      interface:effectWriteOffsetUI(Tiles['181'], position.x, position.y, 1, -1, color)
      interface:effectWriteOffsetUI(dmgstring, position.x, position.y, 2, -1, { 1, 1, 1 }, color)
    end

    t = t + dt
    if t > 0.3 then return true end
  end
end

local function wrap(str, limit)
  local Lines, here, limit = {}, 1, limit or 72
  Lines[1] = string.sub(str,1,str:find("(%s+)()(%S+)()")-1)  -- Put the first word of the string in the first index of the table.

  str:gsub("(%s+)()(%S+)()",
        function(sp, st, word, fi)  -- Function gets called once for every space found.
          if fi-here > limit then
                here = st
                Lines[#Lines+1] = word                                             -- If at the end of a line, start a new table index...
          else Lines[#Lines] = Lines[#Lines].." "..word end  -- ... otherwise add to the current table index.
        end)

  return Lines
end

effects.SpeakEffect = function(actor, text, color)
  local position = actor.position
  local t = 0
  local char = actor.char
  local strings = wrap(text, 25)
  

  return function(dt, interface)

    for i, string in ipairs(strings) do
      interface:effectWriteOffsetUI(Tiles['181'], position.x, position.y, 1, -1, color)
      interface:effectWriteOffsetUI(string, position.x, position.y, 2, -1 + i - 1, { 1, 1, 1 }, color)
    end

    t = t + dt
    if t > 5 then
      return true
    end
  end
end

effects.throw = function(thrown, thrower, location)
  local line, valid = Bresenham.line(thrower.position.x, thrower.position.y, location.x, location.y)
  local lineIndex = 1
  local t = 0

  return function(dt, interface)
    local index = math.floor(t / 0.1) + 1
    interface:effectWriteOffset(thrown.char, line[index][1], line[index][2], thrown.color)

    t = t + dt
    if index == #line then return true end
  end
end

local zapchars = {
  Tiles.projectile1,
  Tiles.projectile2,
  Tiles.projectile3,
}
effects.Zap = function(wand, zapper, location)
  local color = wand.color or wand
  local line, valid = Bresenham.line(zapper.position.x, zapper.position.y, location.x, location.y)
  local lineIndex = 1
  local t = 0

  return function(dt, interface)
    local index = math.floor(t / 0.033) + 1
    local index2 = math.max(index - 1, 1)
    local index3 = math.max(index - 2, 1)

    if line[index3] then
      interface:effectWriteOffset(zapchars[3], line[index3][1], line[index3][2], color)
    end

    if line[index2] then
      interface:effectWriteOffset(zapchars[2], line[index2][1], line[index2][2], color)
    end

    if line[index] then
      interface:effectWriteOffset(zapchars[1], line[index][1], line[index][2], color)
    end

    t = t + dt
    if index == #line then return true end
  end
end

effects.ExplosionEffect = function(fov, origin, range, colors)
  local t = 0
  local duration = .6
  local chars = {}

  -- let's define ourselves a little gradient
  chars[0] = Tiles.grad6
  chars[1] = Tiles.grad5
  chars[2] = Tiles.grad4
  chars[3] = Tiles.grad3
  chars[4] = Tiles.grad2
  chars[5] = Tiles.grad1

  local color = colors or { 0.8666, 0.4509, 0.0862 }
  return function(dt, interface)
    t = t + dt

    for x, yt in pairs(fov) do
      for y, _ in pairs(yt) do
        local distFactor = math.sqrt(math.pow(origin.x - x, 2) + math.pow(origin.y - y, 2)) /
            (t / (duration / 6) * range
            )
        local fadeFactor = math.min(t / duration, 1)
        local fade = math.max(distFactor, fadeFactor)
        local fade = math.min(fade + love.math.noise(x + t, y + t) / 2, 1)
        local char = chars[math.floor(fade * 5)]

        if fade < 0.5 then
          local yellow = { 0.8, 0.8, 0.1 }
          yellow = Color.lerp(yellow, color, fade)
          interface:effectWriteOffset(char, x, y, yellow)
        elseif fade > .95 then
        elseif fade > .75 then
          local grey = { 0.3, 0.3, 0.3 }
          grey = Color.lerp(color, grey, math.min(fade * 3, 1))
          interface:effectWriteOffset(char, x, y, grey)
        elseif fade < .75 then
          interface:effectWriteOffset(char, x, y, color)
        end
      end
    end

    if t > duration then return true end
    return false
  end
end

effects.LightEffect = function(x, y, duration, color, intensity)
  intensity = intensity or 1
  local t = 0
  return function(dt)
    t = t + dt
    if t > duration then return false end
    return x, y, Color.mul(Color.mul(color, intensity), (1 - t / duration))
  end
end

effects.Character = function(x, y, char, color, duration)
  local t = 0
  return function(dt, interface)
    t = t + dt
    if t > duration then return true end

    interface:effectWriteOffset(char, x, y, color)
  end
end

effects.CharacterDynamic = function(actor, x, y, char, color, duration)
  local t = 0
  return function(dt, interface)
    t = t + dt
    if t > duration then return true end

    interface:effectWriteOffset(char, actor.position.x + x, actor.position.y + y, color)
  end
end

return effects
