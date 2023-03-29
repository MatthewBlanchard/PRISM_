local Component = require "component"

local function randBiDirectional()
  return (math.random() - .5) * 2
end

local function flicker(baseColor, period, intensity)
  local t = 0
  local color = {baseColor[1], baseColor[2], baseColor[3], baseColor[4]}
  return function(dt)
    t = t + dt

    if t > period then
      t = 0
      local r = randBiDirectional() * intensity
      color[1] = baseColor[1] - baseColor[1] * r
      color[2] = baseColor[2] - baseColor[2] * r
      color[3] = baseColor[3] - baseColor[3] * r
    end

    return color
  end
end

local function clerp(start, finish, t)
  local c = {}
  for i = 1, 4 do
    if not start[i] or not finish[i] then break end
    c[i] = (1 - t) * start[i] + t * finish[i]
  end

  return c
end

local function pulse(baseColor, period, intensity)
  local t = 0
  local color = {baseColor[1], baseColor[2], baseColor[3], baseColor[4]}
  return function(dt)
    t = t + dt

    local r = math.sin(t / period) * intensity
    color[1] = baseColor[1] + baseColor[1] * r
    color[2] = baseColor[2] + baseColor[2] * r
    color[3] = baseColor[3] + baseColor[3] * r

    return color
  end
end

local function colorSwap(baseColor, secondaryColor, period, intensity)
  local t = 0
  return function(dt)
    t = t + dt

    local r = math.sin(t / ( period * 2))
    local clerped = clerp(baseColor, secondaryColor, math.abs(r)) 
    
    r = math.sin(t / (period / 2)) * intensity
    clerped[1] = clerped[1] + clerped[1] * r
    clerped[2] = clerped[2] + clerped[2] * r
    clerped[3] = clerped[3] + clerped[3] * r
    return clerped
  end
end

local Light = Component:extend()
Light.name = "Light"

Light.effects = {
  flicker = flicker,
  pulse = pulse,
  colorSwap = colorSwap
}

function Light:__new(options)
  self.color = options.color
  self.intensity = options.intensity
  self.effect = options.effect
end

function Light:initialize(actor)
  -- We clone the color table so that we can modify it without affecting the
  -- original table in the parent object.
  local color = {}

  for k, v in pairs(self.color) do
    color[k] = v
  end

  self.color = color
end

return Light
