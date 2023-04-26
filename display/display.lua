local Object = require "object"

local Tiles = require "display.tiles"
local json = require "lib.json"

local Display = Object:extend()
Display.defaultTileset = "display/atlas"

function Display:__new(w, h, transform, dfg, dbg, fullOrFlags, tilesetInfo, _)
   local tilesetInfo = tilesetInfo or self.defaultTileset
   
   self.widthInChars = w or 81
   self.heightInChars = h or 24
   self.glyphs = {}
   
   self:setTileset(tilesetInfo)

   self.defaultForegroundColor = dfg or {1,1,1,1}
   self.defaultBackgroundColor = dbg or {0,0,0,1}
   
   self.canvas = love.graphics.newCanvas(self.charWidth * self.widthInChars, self.charHeight * self.heightInChars)
   self.canvas_transform = love.math.newTransform(
      transform.x, transform.y,
      transform.r,
      transform.sx, transform.sy,
      transform.ox, transform.oy,
      transform.kx, transform.ky
   )
   
   self.graphics_objects = {}
   
   return self
end

function Display:setTileset(tilesetInfo)
   local atlas = json.decode(love.filesystem.read(tilesetInfo .. ".json"))
   
   self.imageCharWidth = atlas.grid_width
   self.imageCharHeight = atlas.grid_height
   self.charWidth = self.imageCharWidth
   self.charHeight = self.imageCharHeight
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

function Display:write(drawable, x, y, fg, bg)
   local x, y = x - 1, y - 1

   local scale = 1
   if type(drawable) == "string" then
      for i, v in ipairs(drawable:split()) do
         local x, y = (x+i-1)*15, y*15
         local object = {
            drawable = Tiles[tostring(v:byte())],
            transform = love.math.newTransform(x, y),
            color = {fg = fg, bg = bg}
         }
         table.insert(self.graphics_objects, object)
      end
   else
      local x, y = x*15*scale, y*15*scale
      local object = {
         drawable = drawable,
         transform = love.math.newTransform(x, y),
         color = {fg = fg, bg = bg}
      }
      table.insert(self.graphics_objects, object)
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
function Display:clear(c, x, y, w, h, fg, bg)
   c = c or Tiles["grad6"]
   x = x or 1
   y = y or 1
   w = w or self.widthInChars
   h = h or self.heightInChars - y + 1
   fg = fg or {0,0,0,0}

   for x = x, x+w do
      for y = y, y+h-1 do
         self:write(c, x, y, fg, bg)
      end
   end
end


function Display:draw_object(object)
   local drawable = object.drawable
   local transform = object.transform
   local color = object.color

   if type(drawable) == "number" then

      if color.bg then
         love.graphics.setColor(color.bg)
         love.graphics.draw(self.glyphSprite, self.glyphs[Tiles["grad6"]], transform)
      end

      love.graphics.setColor(color.fg or self.defaultForegroundColor)
      local quad = self.glyphs[drawable]
      love.graphics.draw(self.glyphSprite, quad, transform)
   else
      love.graphics.draw(drawable, transform)
   end
end

local upscale_shader = love.graphics.newShader("display/upscale_shader.glsl")

function Display:draw()
   love.graphics.setCanvas(self.canvas)
   love.graphics.clear()
   for _, v in ipairs(self.graphics_objects) do
      self:draw_object(v)
   end
   love.graphics.setCanvas()
   self.graphics_objects = {}

   love.graphics.setShader(upscale_shader)
   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.draw(self.canvas, self.canvas_transform)
   love.graphics.setColor(1, 0, 0, 1)
   love.graphics.setShader()
end

function Display:updateCanvasTransform(t)
   self.canvas_transform:setTransformation(
      t.x, t.y,
      t.r,
      t.sx, t.sy,
      t.ox, t.oy,
      t.kx, t.ky
   )
end

function Display:getWidth() return self.widthInChars end
function Display:getHeight() return self.heightInChars end
function Display:getBackgroundColor() return self.defaultBackgroundColor end



return Display