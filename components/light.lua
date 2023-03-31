local Component = require "component"
local LightColor = require "lighting.lightcolor"

local function randBiDirectional()
  return (math.random() - .5) * 2
end

local function flicker(baseColor, period, intensity)
  local t = 0
  local color = baseColor:clone()
  return function(dt)
    print("FLICKER", dt)
    t = t + dt

    if t > period then
      t = 0
      local r = randBiDirectional() * intensity
      color = baseColor - baseColor * r
    end

    print(color)
    return color
  end
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

local Light = Component:extend()
Light.name = "Light"

Light.effects = {
  flicker = flicker,
  pulse = pulse
}

function Light:__new(options)
  assert(options.intensity == nil)

  self.color = options.color
  if options.effect then
    print("YEET", self.color)
    self.effect = options.effect[1](self.color, unpack(options.effect[2]))
  end
  self.falloff = options.falloff or 0.4
end

function Light:initialize(actor)
  self.color = LightColor(self.color.r, self.color.g, self.color.b)
end

return Light
