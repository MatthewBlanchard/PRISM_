local Object = require("object")
local ffi = require("ffi")

local LightColor = {}

ffi.cdef([[
typedef struct {
    uint8_t r;
    uint8_t g;
    uint8_t b;
} LightColor;
]])

LightColor.__index = LightColor

-- Constructor
function LightColor:__call(r, g, b)
	assert(type(r) == "number" and r >= 0 and r <= 31, "Red component must be an integer between 0 and 31.")
	assert(type(g) == "number" and g >= 0 and g <= 31, "Green component must be an integer between 0 and 31.")
	assert(type(b) == "number" and b >= 0 and b <= 31, "Blue component must be an integer between 0 and 31.")

	local self = ffi.new("LightColor")
	self.r = r
	self.g = g
	self.b = b
	return self
end

function LightColor:clone()
	return LightColor:__call(self.r, self.g, self.b)
end

function LightColor:perceived_brightness()
	local r = self.r / 31
	local g = self.g / 31
	local b = self.b / 31

	local luminance = 0.299 * r + 0.587 * g + 0.114 * b
	return luminance
end

function LightColor:average_brightness()
	local avg = (self.r + self.g + self.b) / 3
	return avg
end

function LightColor:to_rgb()
	return { self.r / 31, self.g / 31, self.b / 31 }
end

function LightColor:subtract_scalar(scalar)
	local r = math.floor(math.min(31, math.max(self.r - scalar, 0)))
	local g = math.floor(math.min(31, math.max(self.g - scalar, 0)))
	local b = math.floor(math.min(31, math.max(self.b - scalar, 0)))

	return LightColor:__call(r, g, b)
end

-- Helper function to clamp values
local function clamp(x, min, max)
	return x < min and min or (x > max and max or x)
end

function LightColor:lerp(otherColor, t)
	local r = math.floor(clamp((1 - t) * self.r + t * otherColor.r, 0, 31))
	local g = math.floor(clamp((1 - t) * self.g + t * otherColor.g, 0, 31))
	local b = math.floor(clamp((1 - t) * self.b + t * otherColor.b, 0, 31))

	return LightColor:__call(r, g, b)
end

-- Addition
function LightColor.__add(a, b)
	local r = clamp(a.r + b.r, 0, 31)
	local g = clamp(a.g + b.g, 0, 31)
	local b = clamp(a.b + b.b, 0, 31)
	return LightColor:__call(r, g, b)
end

-- Subtraction
function LightColor.__sub(a, b)
	local r = clamp(a.r - b.r, 0, 31)
	local g = clamp(a.g - b.g, 0, 31)
	local b = clamp(a.b - b.b, 0, 31)
	return LightColor:__call(r, g, b)
end

-- Multiplication
function LightColor.__mul(a, scalar)
	assert(type(scalar) == "number", "Scalar must be a number.")
	local r = math.floor(clamp(a.r * scalar, 0, 31))
	local g = math.floor(clamp(a.g * scalar, 0, 31))
	local b = math.floor(clamp(a.b * scalar, 0, 31))
	return LightColor:__call(r, g, b)
end

-- Multiplication
function LightColor.__div(a, scalar)
	assert(type(scalar) == "number", "Scalar must be a number.")
	local r = math.floor(clamp(a.r / scalar, 0, 31))
	local g = math.floor(clamp(a.g / scalar, 0, 31))
	local b = math.floor(clamp(a.b / scalar, 0, 31))
	return LightColor:__call(r, g, b)
end

-- Equality
function LightColor.__eq(a, b)
	return a.r == b.r and a.g == b.g and a.b == b.b
end

-- String representation
function LightColor.__tostring(a)
	return string.format("LightColor(%d, %d, %d)", a.r, a.g, a.b)
end

return ffi.metatype("LightColor", LightColor)
