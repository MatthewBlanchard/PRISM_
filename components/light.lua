local Component = require "component"
local LightColor = require "lighting.lightcolor"

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

local Light = Component:extend()
Light.name = "Light"

Light.effects = {
  flicker = flicker,
  pulse = pulse
}

function Light:__new(options)
  assert(
    options.color and options.color.is and options.color:is(LightColor),
    "Light color must be a LightColor object"
  )

  assert(options.intensity == nil)

  self.color = options.color
  self.effect = options.effect
  self.falloff = options.falloff or 0.4
end

function Light:initialize(actor)
  self.color = LightColor(self.color.r, self.color.g, self.color.b)
end

return Light
