local Object = require "object"
local LightColor = require "lighting.lightcolor"

local LightBuffer = Object:extend()

function LightBuffer:__new(w, h)
    self.w = w
    self.h = h

    self.r = Grid(w, h, 0)
    self.g = Grid(w, h, 0)
    self.b = Grid(w, h, 0)
end

function LightBuffer:getChannel(channel)
    return self[channel]
end

function LightBuffer:clear()
    self.r:fill(0)
    self.g:fill(0)
    self.b:fill(0)
end

function LightBuffer:getColor(x, y)
    return LightColor(self.r:get(x, y), self.g:get(x, y), self.b:get(x, y))
end

function LightBuffer:getLight(x, y)
    return self:getColor(x, y)
end

function LightBuffer:set(x, y, r, g, b)
    self.r:set(x, y, r)
    self.g:set(x, y, g)
    self.b:set(x, y, b)
end

function LightBuffer:accumulate_buffer(x, y, buffer)
    for i = 0, buffer.w - 1 do
        for j = 0, buffer.h - 1 do
            if not (x + i < 1 or x + i > self.w or y + j < 1 or y + j > self.h) then
                local r = math.max(0, math.min(31, self.r:get(x + i, y + j) + buffer.r:get(i + 1, j + 1)))
                local g = math.max(0, math.min(31, self.g:get(x + i, y + j) + buffer.g:get(i + 1, j + 1)))
                local b = math.max(0, math.min(31, self.b:get(x + i, y + j) + buffer.b:get(i + 1, j + 1)))

                self.r:set(x + i, y + j, r)
                self.g:set(x + i, y + j, g)
                self.b:set(x + i, y + j, b)
            end
        end
    end
end

function LightBuffer:fill(r, g, b)
    self.r:fill(r)
    self.g:fill(g)
    self.b:fill(b)
end

return LightBuffer