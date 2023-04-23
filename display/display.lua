local Object = require "object"
local terminal_display = require "display.terminal_display"

local Tiles = require "display.tiles"
local json = require "lib.json"

local Display = Object:extend()
Display.defaultTileset = "display/atlas"

function Display:__new(w, h, scale, dfg, dbg, fullOrFlags, tilesetInfo, window)
   local tilesetInfo = tilesetInfo or self.defaultTileset
   
   self.widthInChars = w and w or 80
   self.heightInChars = h and h or 24
   self.scale = scale or 1
   self.glyphs = {}
   
   self:setTileset(tilesetInfo)

   if window then
      love.window.setMode(
         self.charWidth * self.widthInChars,
         self.charHeight * self.heightInChars,
         { vsync = false }
      )
   end

   self.defaultForegroundColor = dfg or {1,1,1,1}
   self.defaultBackgroundColor = dbg or {0,0,0,1}
   
   self.canvas = love.graphics.newCanvas(self.charWidth * self.widthInChars+15, self.charHeight * self.heightInChars+15)
   self.canvas_transform = love.math.newTransform(0, 0, 0, self.scale, self.scale)
   
   self.graphics_objects = {}
   
   
   return self
end

function Display:setTileset(tilesetInfo)
   local atlas = json.decode(love.filesystem.read(tilesetInfo .. ".json"))
   
   self.imageCharWidth = atlas.grid_width
   self.imageCharHeight = atlas.grid_height
   self.charWidth = self.imageCharWidth * self.scale
   self.charHeight = self.imageCharHeight * self.scale
   self.glyphSprite = love.graphics.newImage(tilesetInfo .. ".png")
   
   local sorted = {}
   for i, v in ipairs(atlas.regions) do
      sorted[v.idx] = v
   end
   
   for i = 0, #sorted do
      local v = sorted[i]
      local x, y = v.rect[1], v.rect[2]
      local width, height = v.rect[3], v.rect[4]
      
      self.glyphs[i] = love.graphics.newQuad(x, y, width, height, atlas.width, atlas.height)
   end
   
   self.tilesetChanged = true
end

function Display:clear(c, x, y, w, h, fg, bg)
   c = c or Tiles["grad6"]
   x = x or 1
   y = y or 1
   w = w or self.widthInChars
   h = h or self.heightInChars - y + 1
   --fg = {0,0,0,0.2}--fg or self.defaultForegroundColor
   --bg = {0,0,0,1}--bg or self.defaultBackgroundColor

   for x = x, x+w do
      for y = y, y+h do
         --self:write(c, x, y, fg, bg)
      end
   end
end
function Display:write(drawable, x, y, fg, bg)
   local x, y = x - 1, y - 1

   local scale = 1
   if type(drawable) == "string" then

      for i, v in ipairs(drawable:split()) do
         local x, y = (x+i-1)*15, y*15
         table.insert(self.graphics_objects, {
            drawable = Tiles[tostring(v:byte())],
            transform = love.math.newTransform(x, y),
            color = {fg = fg, bg = bg}
         })
      end
   else
      local x, y = x*15*scale, y*15*scale
      table.insert(self.graphics_objects, {
         drawable = drawable,
         transform = love.math.newTransform(x, y),
         color = {fg = fg, bg = bg}
      })
   end
end
function Display:writeCenter(s, y, fg, bg)
   local x = math.floor((self.widthInChars - #s) / 2)
   y = y and y or math.floor((self:getHeightInChars() - 1) / 2)

   self:write(s, x, y, fg, bg)
end
function Display:writeFormatted(s, x, y, bg)
   assert(type(s) == "table", "Display:writeFormatted() must have table as param")

   local currentX = x
   local currentFg = nil
   for i = 1, #s do
      if type(s[i]) == "string" then
         self:write(s[i], currentX, y, currentFg, nil, bg)
         currentX = currentX + #s[i]
      elseif type(s[i]) == "table" then
         currentFg = s[i]
      end
   end
end

function Display:draw()
   
   love.graphics.setCanvas(self.canvas)
   love.graphics.clear()
   for _, object in ipairs(self.graphics_objects) do
      local drawable = object.drawable
      local transform = object.transform
      local color = object.color

      love.graphics.setColor(color.fg or self.defaultForegroundColor)
      if type(drawable) == "number" then
         local quad = self.glyphs[drawable]
         love.graphics.draw(self.glyphSprite, quad, transform)
      else
         love.graphics.draw(drawable, transform)
      end
   end
   love.graphics.setCanvas()

   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.draw(self.canvas, self.canvas_transform)
   love.graphics.setColor(1, 0, 0, 1)
   self.graphics_objects = {}
end
function Display:drawText(x, y, text, maxWidth)
   local x_format, y_format = 0, 0
   for _, v in ipairs(text:split(" ")) do
      if x_format+string.len(v) > maxWidth then
         x_format = 0
         y_format = y_format + 1
      end
      v = v..' '
      self:write(v, x+x_format, y+y_format)
      x_format = x_format + string.len(v)
   end
end
function Display:getWidth() return self.widthInChars end
function Display:getHeight() return self.heightInChars end
function Display:getBackgroundColor()
   return self.defaultBackgroundColor
end

for k, v in pairs(terminal_display) do
   --Display[k] = v
end



return Display