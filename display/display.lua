local Object = require "object"

local Tiles = require "display.tiles"
local json = require "lib.json"

local Display = Object:extend()
Display.defaultTileset = "display/atlas"

function Display:__new(w, h, transform, dfg, dbg, fullOrFlags, tilesetInfo, _)
   local tilesetInfo = tilesetInfo or self.defaultTileset
   
   self.widthInChars = w or DISPLAY_WIDTH
   self.heightInChars = h or DISPLAY_HEIGHT
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

   self.camera_transform = love.math.newTransform()
   
   self.graphics_objects = {}
   self.batch = love.graphics.newSpriteBatch(self.glyphSprite)
   
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

local i = 0

function Display:write_plain(drawable, x, y, fg, bg, shader)
   local x, y = x - 1, y - 1

   local scale = 1
   if type(drawable) == "string" then
      for i, v in ipairs(drawable:split()) do
         local x, y = (x+i-1)*15, y*15
         local object = {
            drawable = Tiles[tostring(v:byte())],
            transform = love.math.newTransform(
               x, y
            ),
            colors = {fg = fg, bg = bg},
            shader_callback = shader
         }
         table.insert(self.graphics_objects, object)
      end
   else
      local x, y = x*15*scale, y*15*scale
      local object = {
         drawable = drawable,
         transform = love.math.newTransform(
            x, y
         ),
         colors = {fg = fg, bg = bg},
         shader_callback = shader
      }
      table.insert(self.graphics_objects, object)
   end
end

function Display:write_object(graphics_object)
   graphics_object:update_transform()
   table.insert(self.graphics_objects, graphics_object)
end

function Display:write_batch(drawable, x, y, fg, bg)
   local x, y = x - 1, y - 1

   if type(drawable) == "string" then
      for i, v in ipairs(drawable:split()) do
         local x, y = (x+i-1)*15, y*15

         if bg and bg[4] ~= 0 then
            self.batch:setColor(bg)
            self.batch:add(self.glyphs[Tiles["grad6"]], x, y)
         end
   
         self.batch:setColor(fg or self.defaultForegroundColor)
         self.batch:add(self.glyphs[Tiles[tostring(v:byte())]], x, y)
      end
   else
      local x, y = x*15, y*15
      if bg and bg[4] ~= 0 then
         self.batch:setColor(bg)
         self.batch:add(self.glyphs[Tiles["grad6"]], x, y)
      end

      self.batch:setColor(fg)
      self.batch:add(self.glyphs[drawable], x, y)
   end
end
--Display.write_plain = Display.write_batch

function Display:writeCenter(s, y, fg, bg)
   local x = math.floor((self.widthInChars - #s) / 2)
   y = y and y or math.floor((self:getHeightInChars() - 1) / 2)

   self:write_plain(s, x, y, fg, bg)
end
function Display:writeFormatted(s, x, y, bg)
   assert(type(s) == "table", "Display:writeFormatted() must have table as param")

   local currentX = x
   local currentFg = nil
   for i = 1, #s do
      if type(s[i]) == "string" then
         self:write_plain(s[i], currentX, y, currentFg, nil, bg)
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
      self:write_plain(v, x+x_format, y+y_format)
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
         self:write_plain(c, x, y, fg, bg)
      end
   end
end

function Display:draw_object(object)
   local x, y = (self.camera_transform * object.transform):transformPoint(0, 0)
   if x < 0 or y < 0 or x/15 > self.widthInChars or y/15 > self.heightInChars then
      print("clipped") return
   end

   local drawable = object.drawable
   local transform = object.transform
   local color = object.colors
   local shader_callback = object.shader_callback

   local quad = self.glyphs[drawable]
   if type(shader_callback) == "function" then
      shader_callback(object, quad)
   end

   if color.bg then
      love.graphics.setColor(color.bg)
      love.graphics.draw(self.glyphSprite, self.glyphs[Tiles["grad6"]], transform)
   end

   love.graphics.setColor(color.fg or self.defaultForegroundColor)
   love.graphics.draw(self.glyphSprite, quad, transform)
   love.graphics.setShader()
end

function Display:draw()
   i = 0
   love.graphics.push()
      love.graphics.applyTransform(self.camera_transform)

      love.graphics.setCanvas(self.canvas)
         love.graphics.clear()

         love.graphics.draw(self.batch)
         for _, v in ipairs(self.graphics_objects) do
            self:draw_object(v)
         end

      love.graphics.setCanvas()

   love.graphics.pop()
   
   self.batch:clear()
   self.graphics_objects = {}

   love.graphics.setColor(1, 1, 1, 1)
   love.graphics.draw(self.canvas, self.canvas_transform)
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