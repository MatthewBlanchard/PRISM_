local Component = require "core.component"
local LightColor = require "structures.lighting.lightcolor"

local function randBiDirectional()
  return (math.random() - .5) * 2
end

local function flicker(baseColor, period, intensity)
  local t = 0
  local color = baseColor:clone()
  return function(dt)
    t = t + dt

    if t > period then
      t = 0
      local r = randBiDirectional() * intensity
      color = baseColor - baseColor * r
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
  local color = baseColor:clone()
  return function(dt)
    t = t + dt

    local r = math.sin(t / period) * intensity
    color = baseColor + baseColor * r
    
    return color
  end
end

local function colorSwap(baseColor, secondaryColor, period, intensity)
  local t = 0
  return function(dt)
    t = t + dt

    local r = math.sin(t / ( period * 2))
    local clerped = baseColor:lerp(secondaryColor, math.abs(r))
    
    r = math.sin(t / (period / 2)) * intensity
    clerped = clerped + clerped * r

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
  assert(options.intensity == nil)

  self.color = options.color
  if options.effect then
    self.effect = options.effect[1](self.color, unpack(options.effect[2]))
  end
  self.falloff = options.falloff or 0.4
end

function Light:initialize(actor)
  self.color = LightColor(self.color.r, self.color.g, self.color.b)
end

return Light
