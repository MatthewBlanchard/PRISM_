local Object = require "object"
local Tiles = require "display.tiles"
local Display = require "display.display"

local Panel = Object:extend()
Panel.borderColor = { 0.5, 0.5, 0.6, 1 }
Panel.defaultForegroundColor = { 1, 1, 1 }
Panel.defaultBackgroundColor = { 0.09, 0.09, 0.09, 1 }

function Panel:__new(display, parent, x, y, w, h)
   self.x = x or 1
   self.y = y or 1
   self.w = w or DISPLAY_WIDTH
   self.h = h or DISPLAY_HEIGHT
   self.canvas_transform = {
      x = (self.x-1)*15, y = (self.y-1)*15,
      r = 0,
      sx = 1, sy = 1,
      ox = 0, oy = 0,
      kx = 0, ky = 0
   }
   self.camera_transform = {
      x = (self.x-1)*15, y = (self.y-1)*15,
      r = 0,
      sx = 1, sy = 1,
      ox = 0, oy = 0,
      kx = 0, ky = 0
   }

   do
      local display = display or Display(self.w, self.h, self.canvas_transform, nil, { 1, 1, 1, 0 }, nil, nil, false)
      self.display = display
   end

   local display = self.display
   self.parent = parent
   self.x = x or 1
   self.y = y or 1
   self.defaultBackgroundColor = Panel.defaultBackgroundColor

   self.panels = {}


end

function Panel:getRoot()
   local parent = self.parent
   local prev = self
   while parent do
      prev = parent
      parent = parent.parent
   end
   return prev
end

function Panel:draw(x, y) end

function Panel:write_plain(char, x, y, fg, bg)
   self.display:write_plain(char, x, y, fg, bg)
end

function Panel:write_object(graphics_object)
   self.display:write_object(graphics_object)
end

function Panel:clear(c, fg, bg)
   self.display:clear(
      c or Tiles["grad6"],
      1,
      1,
      self.w-1,
      self.h-1,
      fg,
      bg or self.defaultBackgroundColor
   )
end

function Panel:darken(c, _, bg)
   for x = 1, self.w - 1 do
      for y = 1, self.h - 1 do
         local bg = self.display:getBackgroundColor(x, y)
         bg = ROT.Color.multiplyScalar(bg, 0.15)
         self:write_plain(Tiles["grad6"], x, y, bg)
      end
   end
end

function Panel:drawBorders(width, height)
   local w = width or self.w
   local h = height or self.h
   local half_width = (w - 3) / 2
   local half_height = (h - 3) / 2

   -- Top border
   self:write_plain(Tiles["b_top_left_corner"], 1, 1, Panel.borderColor, Panel.defaultBackgroundColor)
   self:drawHorizontal(Tiles["b_top_left"], 1, half_width, 1)
   self:write_plain(Tiles["b_top_middle"], half_width + 2, 1, Panel.borderColor, Panel.defaultBackgroundColor)
   self:drawHorizontal(Tiles["b_top_right"], half_width + 2, half_width * 2 + 1, 1)
   self:write_plain(Tiles["b_top_right_corner"], w, 1, Panel.borderColor, Panel.defaultBackgroundColor)

   -- Bottom border
   self:write_plain(Tiles["b_left_bottom_corner"], 1, h, Panel.borderColor, Panel.defaultBackgroundColor)
   self:drawHorizontal(Tiles["b_bottom_left"], 1, half_width, h)
   self:write_plain(Tiles["b_bottom_middle"], half_width + 2, h, Panel.borderColor, Panel.defaultBackgroundColor)
   self:drawHorizontal(Tiles["b_bottom_right"], half_width + 2, half_width * 2 + 1, h)
   self:write_plain(Tiles["b_bottom_right_corner"], w, h, Panel.borderColor, Panel.defaultBackgroundColor)

   -- Left border
   self:drawVertical(Tiles["b_left_top"], 1, half_height, 1)
   self:write_plain(Tiles["b_left_middle"], 1, half_height + 2, Panel.borderColor, Panel.defaultBackgroundColor)
   self:drawVertical(Tiles["b_left_bottom"], half_height + 2, half_height * 2 + 1, 1)

   -- Right border
   self:drawVertical(Tiles["b_right_top"], 1, half_height, w)
   self:write_plain(Tiles["b_right_middle"], w, half_height + 2, Panel.borderColor, Panel.defaultBackgroundColor)
   self:drawVertical(Tiles["b_right_bottom"], half_height + 2, half_height * 2 + 1, w)
end

function Panel:effectWriteOffset(toWrite, x, y, fg, bg)

   local sight_component = game.curActor:getComponent(components.Sight)
   if not sight_component.fov:get(x, y) then
      self.effectWrite = false
      return
   end

   self.effectWrite = true
   self._curEffectDone = false
   self:write_plain(toWrite, x, y, fg, bg)
end

function Panel:effectWriteOffsetUI(toWrite, x, y, ofx, ofy, fg, bg)
   local sight_component = game.curActor:getComponent(components.Sight)
   if not sight_component.fov:get(x, y) then return end

   self.effectWrite = true
   local scale = self.display.scale
   self._curEffectDone = false
   self:write_plain(toWrite, x + ofx, y + ofy, fg, bg)
end

function Panel:writeOffsetBG(x, y, bg)
   local interface = game.interface
   local mx = (x - (game.curActor.position.x - interface.viewX)) + 1
   local my = (y - (game.curActor.position.y - interface.viewY)) + 1

   self:writeBG(mx, my, bg)
end

function Panel:drawHorizontal(c, first, last, y)
   for i = first, last do
      self:write_plain(c, 1 + i, y, Panel.borderColor, Panel.defaultBackgroundColor)
   end
end

function Panel:drawVertical(c, first, last, x)
   for i = first, last do
      self:write_plain(c, x, 1 + i, Panel.borderColor, Panel.defaultBackgroundColor)
   end
end

function Panel:update(dt) end

function Panel:writeBG(x, y, bg)
   self.display:writeBG(x, y, bg)
end
function Panel:writeFormatted(s, x, y, bg)
   self.display:writeFormatted(s, x, y, bg or self.defaultBackgroundColor)
end

function Panel:writeText(s, x, y, maxWidth)

   self.display:drawText(x, y, s, maxWidth)
end

function Panel:correctWidth(s, w)
   if string.len(s) < w then
      return s .. string.rep(" ", w - string.len(s))
   elseif string.len(s) > w then
      return string.sub(s, 1, w)
   else
      return s
   end
end

function Panel:correctHeight(h)
   if h % 2 == 0 then
      return h + 1
   else
      return h
   end
end

function Panel:handleKeyPress(keypress)
   if keypress == "backspace" then game.interface:pop() end
end

return Panel
