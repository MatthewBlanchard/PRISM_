local Object = require "object"
local LightColor = require "lighting.lightcolor"
local ffi = require "ffi"

local LightBuffer = Object:extend()

function LightBuffer:__new(w, h)
    self.w = w
    self.h = h

    self.buffer = ffi.new("LightColor[?]", w * h)
end

function LightBuffer:getIndex(x, y)
    return (y - 1) * self.w + (x - 1)
end

function LightBuffer:getChannel(channel, x, y)
    return self.buffer[self:getIndex(x, y)][channel]
end

function LightBuffer:clear()
    ffi.fill(self.buffer, ffi.sizeof("LightColor") * self.w * self.h)
end

function LightBuffer:getColor(x, y)
    local color = self.buffer[self:getIndex(x, y)]
    return LightColor(color.r, color.g, color.b)
end

function LightBuffer:getLight(x, y)
    return self:getColor(x, y)
end

function LightBuffer:set(x, y, r, g, b)
    local color = self.buffer[self:getIndex(x, y)]
    color.r, color.g, color.b = r, g, b
end

-- Function to set the color in the LightBuffer
function LightBuffer:setWithFFIStruct(x, y, color)
    local index = self:getIndex(x, y)
    ffi.copy(self.buffer[index], color, ffi.sizeof("LightColor"))
end

function LightBuffer:accumulate_buffer(x, y, buffer)
    for i = 0, buffer.w - 1 do
        for j = 0, buffer.h - 1 do
            if not (x + i - 1 < 0 or x + i - 1 >= self.w or y + j - 1 < 0 or y + j - 1 >= self.h) then
                local index = self:getIndex(x + i, y + j)
                local bufIndex = buffer:getIndex(i + 1, j + 1)

                local r = math.max(0, math.min(31, self.buffer[index].r + buffer.buffer[bufIndex].r))
                local g = math.max(0, math.min(31, self.buffer[index].g + buffer.buffer[bufIndex].g))
                local b = math.max(0, math.min(31, self.buffer[index].b + buffer.buffer[bufIndex].b))

                self.buffer[index].r = r
                self.buffer[index].g = g
                self.buffer[index].b = b
            end
        end
    end
end

function LightBuffer:fill(r, g, b)
    for i = 0, self.w * self.h - 1 do
        self.buffer[i].r = r
        self.buffer[i].g = g
        self.buffer[i].b = b
    end
end

return LightBuffer